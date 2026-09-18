-- L06: Durable account deletion with Apple credential revocation job.
--
-- Goals:
-- - Store Apple refresh tokens server-side (never on client), no client read access.
-- - On delete request, move Apple refresh token into a durable deletion job BEFORE deleting Auth user.
-- - Allow worker retries after Auth removal; erase Apple token after successful revocation.
-- - Fail closed: no account deletion proceeds unless a durable job record exists.
--
-- NOTE: Edge Functions use the Supabase service role and can bypass RLS; we still enable RLS
-- and intentionally create no client policies for these tables.

CREATE TABLE IF NOT EXISTS public.apple_auth_store (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  apple_sub TEXT,
  refresh_token TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_apple_auth_store_updated_at ON public.apple_auth_store(updated_at);

ALTER TABLE public.apple_auth_store ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON public.apple_auth_store FROM anon, authenticated;

-- One durable record per user. This must survive auth deletion attempts and allow retries.
CREATE TABLE IF NOT EXISTS public.account_deletion_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE,
  state TEXT NOT NULL DEFAULT 'pending'
    CHECK (state IN ('pending', 'processing', 'complete', 'failed')),
  requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  auth_deleted_at TIMESTAMPTZ,

  -- Apple credential is moved here (durable) before deleting the source store.
  apple_sub TEXT,
  apple_refresh_token TEXT,
  apple_revoked_at TIMESTAMPTZ,

  attempt_count INTEGER NOT NULL DEFAULT 0,
  next_attempt_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  locked_at TIMESTAMPTZ,
  locked_by TEXT,
  last_error TEXT
);

CREATE INDEX IF NOT EXISTS idx_account_deletion_jobs_next_attempt
  ON public.account_deletion_jobs(state, next_attempt_at);

ALTER TABLE public.account_deletion_jobs ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.account_deletion_jobs FROM anon, authenticated;

ALTER TABLE public.app_profiles
  ADD COLUMN IF NOT EXISTS deletion_requested_at TIMESTAMPTZ;

-- Begin deletion: create durable job (and move Apple token if present) before Auth user removal.
CREATE OR REPLACE FUNCTION public.begin_account_deletion(p_user_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  existing_id UUID;
  tok RECORD;
  inserted_id UUID;
  already_requested BOOLEAN := FALSE;
BEGIN
  IF p_user_id IS NULL THEN
    RAISE EXCEPTION 'missing user id';
  END IF;

  -- Serialize per user.
  PERFORM pg_advisory_xact_lock((hashtext(p_user_id::text))::bigint);

  SELECT id INTO existing_id FROM public.account_deletion_jobs WHERE user_id = p_user_id;
  IF FOUND THEN
    already_requested := TRUE;
    -- Ensure source store is not retaining credentials after a deletion request.
    DELETE FROM public.apple_auth_store WHERE user_id = p_user_id;
    UPDATE public.app_profiles SET deletion_requested_at = COALESCE(deletion_requested_at, NOW())
      WHERE user_id = p_user_id;
    RETURN jsonb_build_object('ok', true, 'job_id', existing_id, 'already_requested', true);
  END IF;

  SELECT apple_sub, refresh_token
    INTO tok
    FROM public.apple_auth_store
    WHERE user_id = p_user_id;

  INSERT INTO public.account_deletion_jobs (
    user_id,
    state,
    requested_at,
    apple_sub,
    apple_refresh_token
  ) VALUES (
    p_user_id,
    'pending',
    NOW(),
    tok.apple_sub,
    tok.refresh_token
  )
  RETURNING id INTO inserted_id;

  -- Credential moved into durable job; erase the source store.
  DELETE FROM public.apple_auth_store WHERE user_id = p_user_id;

  UPDATE public.app_profiles SET deletion_requested_at = NOW() WHERE user_id = p_user_id;

  RETURN jsonb_build_object(
    'ok', true,
    'job_id', inserted_id,
    'already_requested', already_requested,
    'had_apple_credential', tok.refresh_token IS NOT NULL
  );
END;
$$;

REVOKE ALL ON FUNCTION public.begin_account_deletion(uuid) FROM PUBLIC, anon, authenticated;

-- Claim a batch of pending jobs for processing (FOR UPDATE SKIP LOCKED).
CREATE OR REPLACE FUNCTION public.claim_account_deletion_jobs(p_worker_id text, p_limit integer DEFAULT 5)
RETURNS SETOF public.account_deletion_jobs
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF p_worker_id IS NULL OR length(p_worker_id) < 1 THEN
    RAISE EXCEPTION 'missing worker id';
  END IF;

  RETURN QUERY
  WITH candidates AS (
    SELECT id
    FROM public.account_deletion_jobs
    WHERE state = 'pending'
      AND next_attempt_at <= NOW()
      AND (locked_at IS NULL OR locked_at < NOW() - INTERVAL '10 minutes')
    ORDER BY requested_at ASC
    LIMIT GREATEST(1, LEAST(p_limit, 25))
    FOR UPDATE SKIP LOCKED
  )
  UPDATE public.account_deletion_jobs j
  SET
    state = 'processing',
    locked_at = NOW(),
    locked_by = p_worker_id,
    last_started_at = NOW(),
    attempt_count = attempt_count + 1
  FROM candidates
  WHERE j.id = candidates.id
  RETURNING j.*;
END;
$$;

REVOKE ALL ON FUNCTION public.claim_account_deletion_jobs(text, integer) FROM PUBLIC, anon, authenticated;

