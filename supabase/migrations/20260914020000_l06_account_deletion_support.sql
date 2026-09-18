-- L06 durable deletion. Not deployed. Requires L07a and Apple-token migrations.
-- Tokens are moved into a restricted retry job BEFORE ordinary app cleanup.
-- Successful jobs contain no token; completed jobs expire after seven days.
-- Tombstones prevent late purchase events from recreating deleted accounts.
CREATE TABLE IF NOT EXISTS public.account_deletions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  deleted_user_id uuid NOT NULL UNIQUE,
  deleted_at timestamptz NOT NULL DEFAULT now(),
  source text NOT NULL DEFAULT 'app'
);
ALTER TABLE public.account_deletions ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.account_deletions FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, DELETE ON public.account_deletions TO service_role;

CREATE TABLE IF NOT EXISTS public.account_deletion_jobs (
  user_id uuid PRIMARY KEY,
  apple_refresh_token text,
  apple_status text NOT NULL CHECK (apple_status IN ('pending', 'revoked', 'not_applicable')),
  auth_removed boolean NOT NULL DEFAULT false,
  attempts integer NOT NULL DEFAULT 0,
  last_error text,
  lease_token uuid,
  lease_until timestamptz,
  next_attempt_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz
);
ALTER TABLE public.account_deletion_jobs ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.account_deletion_jobs FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.account_deletion_jobs TO service_role;

CREATE OR REPLACE FUNCTION public.store_apple_auth_token(p_user_id uuid, p_subject text, p_refresh_token text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  PERFORM pg_advisory_xact_lock(hashtextextended(p_user_id::text, 0));
  IF EXISTS (SELECT 1 FROM public.account_deletions WHERE deleted_user_id = p_user_id)
     OR NOT EXISTS (SELECT 1 FROM auth.identities WHERE user_id = p_user_id AND provider = 'apple' AND identity_data->>'sub' = p_subject)
     OR p_refresh_token IS NULL OR length(p_refresh_token) = 0 THEN
    RAISE EXCEPTION 'apple_identity_not_eligible';
  END IF;
  INSERT INTO public.apple_auth_tokens (user_id, refresh_token, apple_subject)
  VALUES (p_user_id, p_refresh_token, p_subject)
  ON CONFLICT (user_id) DO UPDATE SET refresh_token = EXCLUDED.refresh_token,
    apple_subject = EXCLUDED.apple_subject, created_at = now();
END $$;
REVOKE ALL ON FUNCTION public.store_apple_auth_token(uuid, text, text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.store_apple_auth_token(uuid, text, text) TO service_role;

CREATE OR REPLACE FUNCTION public.delete_own_account_data()
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  tid uuid := auth.uid();
  token text;
  apple_linked boolean;
BEGIN
  IF tid IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  PERFORM pg_advisory_xact_lock(hashtextextended(tid::text, 0));
  IF EXISTS (SELECT 1 FROM public.account_deletions WHERE deleted_user_id = tid) THEN
    RETURN jsonb_build_object('ok', true, 'accepted', true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = tid) THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  SELECT EXISTS (SELECT 1 FROM auth.identities WHERE user_id = tid AND provider = 'apple') INTO apple_linked;
  -- Old unbound credentials are never trusted. A native Apple reauthentication
  -- can bind a fresh credential without switching the current Supabase account.
  SELECT t.refresh_token INTO token FROM public.apple_auth_tokens t
    WHERE t.user_id = tid AND EXISTS (SELECT 1 FROM auth.identities i
      WHERE i.user_id = tid AND i.provider = 'apple' AND i.identity_data->>'sub' = t.apple_subject);
  IF apple_linked AND token IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', 'apple_reauthentication_required');
  END IF;
  INSERT INTO public.account_deletion_jobs (user_id, apple_refresh_token, apple_status)
    VALUES (tid, token, CASE WHEN token IS NULL THEN 'not_applicable' ELSE 'pending' END);
  INSERT INTO public.account_deletions (deleted_user_id) VALUES (tid);
  -- Fences any RevenueCat network request started before this transaction.
  DELETE FROM public.revenuecat_sync_leases WHERE user_id = tid;
  -- Child/completion tables first. Several of these are already covered by
  -- ON DELETE CASCADE from their parent below; explicit anyway (harmless
  -- and correct even if a cascade is ever changed).
  DELETE FROM public.user_journey_task_completions WHERE user_id = tid;
  DELETE FROM public.user_milestone_completions WHERE user_id = tid;
  DELETE FROM public.ls_user_habit_log WHERE user_id = tid;
  DELETE FROM public.user_habit_completions WHERE user_id = tid;
  DELETE FROM public.spiritual_chat_messages
    WHERE conversation_id IN (
      SELECT id FROM public.spiritual_chat_conversations WHERE user_id = tid
    );
  DELETE FROM public.spiritual_readings_archive WHERE user_id = tid;

  -- Top-level / entity tables (verified against live schema via
  -- information_schema.columns for column_name = 'user_id', public schema).
  DELETE FROM public.user_journeys WHERE user_id = tid;
  DELETE FROM public.user_custom_habits WHERE user_id = tid;
  DELETE FROM public.spiritual_chat_conversations WHERE user_id = tid;
  DELETE FROM public.spiritual_user_profiles WHERE user_id = tid;
  DELETE FROM public.user_consultation_usage WHERE user_id = tid;
  DELETE FROM public.user_guru_ai_weekly WHERE user_id = tid;
  DELETE FROM public.avatars WHERE user_id = tid;
  DELETE FROM public.sanctuary_customization WHERE user_id = tid;
  DELETE FROM public.push_tokens WHERE user_id = tid;
  DELETE FROM public.user_achievements WHERE user_id = tid;
  DELETE FROM public.user_audio_progress WHERE user_id = tid;
  DELETE FROM public.user_book_progress WHERE user_id = tid;
  DELETE FROM public.user_chapter_progress WHERE user_id = tid;
  DELETE FROM public.user_verse_progress WHERE user_id = tid;
  DELETE FROM public.user_verse_notes WHERE user_id = tid;
  DELETE FROM public.user_parva_progress WHERE user_id = tid;
  DELETE FROM public.user_progress WHERE user_id = tid;
  DELETE FROM public.user_presence WHERE user_id = tid;
  DELETE FROM public.user_daily_tasks WHERE user_id = tid;
  DELETE FROM public.user_daily_streak WHERE user_id = tid;
  DELETE FROM public.user_gratitude_entries WHERE user_id = tid;
  DELETE FROM public.user_task_progress WHERE user_id = tid;
  DELETE FROM public.user_spiritual_progress WHERE user_id = tid;
  DELETE FROM public.user_pregnancy_journey WHERE user_id = tid;
  DELETE FROM public.user_gs_content_progress WHERE user_id = tid;
  DELETE FROM public.baby_milestones WHERE user_id = tid;
  DELETE FROM public.user_samskara_completions WHERE user_id = tid;


  DELETE FROM public.user_entitlements WHERE user_id = tid;
  DELETE FROM public.apple_auth_tokens WHERE user_id = tid;
  DELETE FROM public.app_profiles WHERE user_id = tid;
  RETURN jsonb_build_object('ok', true, 'accepted', true);
END $$;
REVOKE ALL ON FUNCTION public.delete_own_account_data() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.delete_own_account_data() TO authenticated;

-- One short lease per job. A crashed request is recovered by the scheduled
-- worker; finishing an expired lease cannot overwrite its successor's result.
CREATE OR REPLACE FUNCTION public.claim_account_deletion_job(p_user_id uuid DEFAULT NULL)
RETURNS SETOF public.account_deletion_jobs LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE candidate uuid;
BEGIN
  SELECT user_id INTO candidate FROM public.account_deletion_jobs
    WHERE completed_at IS NULL AND next_attempt_at <= now()
      AND (lease_until IS NULL OR lease_until < now())
      AND (p_user_id IS NULL OR user_id = p_user_id)
    ORDER BY next_attempt_at FOR UPDATE SKIP LOCKED LIMIT 1;
  IF candidate IS NULL THEN RETURN; END IF;
  RETURN QUERY UPDATE public.account_deletion_jobs SET lease_token = gen_random_uuid(),
    lease_until = now() + interval '2 minutes', attempts = attempts + 1
    WHERE user_id = candidate RETURNING *;
END $$;
REVOKE ALL ON FUNCTION public.claim_account_deletion_job(uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.claim_account_deletion_job(uuid) TO service_role;

CREATE OR REPLACE FUNCTION public.finish_account_deletion_job(p_user_id uuid, p_lease_token uuid,
  p_apple_revoked boolean, p_auth_removed boolean, p_error text DEFAULT NULL)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE changed integer;
BEGIN
  UPDATE public.account_deletion_jobs SET
    apple_status = CASE WHEN p_apple_revoked THEN 'revoked' ELSE apple_status END,
    apple_refresh_token = CASE WHEN p_apple_revoked THEN NULL ELSE apple_refresh_token END,
    auth_removed = auth_removed OR p_auth_removed,
    completed_at = CASE WHEN (auth_removed OR p_auth_removed) AND
      (p_apple_revoked OR apple_status IN ('revoked', 'not_applicable')) THEN now() ELSE NULL END,
    last_error = left(p_error, 80), lease_token = NULL, lease_until = NULL,
    next_attempt_at = now() + make_interval(secs => LEAST(3600, 30 * power(2, LEAST(attempts, 7)))::integer)
  WHERE user_id = p_user_id AND lease_token = p_lease_token AND lease_until > now();
  GET DIAGNOSTICS changed = ROW_COUNT;
  RETURN changed = 1;
END $$;
REVOKE ALL ON FUNCTION public.finish_account_deletion_job(uuid, uuid, boolean, boolean, text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.finish_account_deletion_job(uuid, uuid, boolean, boolean, text) TO service_role;

-- Storage must be removed through its API, never by deleting storage.objects
-- metadata in SQL. Inventory is restricted to a claimed deletion job.
CREATE OR REPLACE FUNCTION public.list_account_deletion_objects(p_user_id uuid, p_lease_token uuid)
RETURNS TABLE (bucket_id text, name text) LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.account_deletion_jobs WHERE user_id = p_user_id
      AND lease_token = p_lease_token AND lease_until > now()) THEN RAISE EXCEPTION 'lease_lost'; END IF;
  RETURN QUERY SELECT o.bucket_id, o.name FROM storage.objects o
    WHERE coalesce(to_jsonb(o)->>'owner_id', to_jsonb(o)->>'owner') = p_user_id::text LIMIT 100;
END $$;
REVOKE ALL ON FUNCTION public.list_account_deletion_objects(uuid, uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.list_account_deletion_objects(uuid, uuid) TO service_role;

-- Retain failed jobs for recovery (alert operators, never silently discard a
-- still-valid Apple token). Successful jobs lose secrets immediately, disappear
-- after seven days; tombstones can expire after 90 days once Auth is gone.
CREATE OR REPLACE FUNCTION public.prune_account_deletion_records()
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  DELETE FROM public.account_deletion_jobs WHERE completed_at < now() - interval '7 days';
  DELETE FROM public.account_deletions d WHERE deleted_at < now() - interval '90 days'
    AND NOT EXISTS (SELECT 1 FROM auth.users WHERE id = d.deleted_user_id)
    AND NOT EXISTS (SELECT 1 FROM public.account_deletion_jobs WHERE user_id = d.deleted_user_id);
END $$;
REVOKE ALL ON FUNCTION public.prune_account_deletion_records() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.prune_account_deletion_records() TO service_role;

-- Access tokens can outlive Auth deletion. Prevent writes from resurrecting
-- app records while a job runs or an old access token remains on a device.
CREATE OR REPLACE FUNCTION public.guard_deleted_account_data()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  IF NEW.user_id IS NOT NULL THEN
    PERFORM pg_advisory_xact_lock(hashtextextended(NEW.user_id::text, 0));
    IF EXISTS (SELECT 1 FROM public.account_deletions WHERE deleted_user_id = NEW.user_id)
       OR NOT EXISTS (SELECT 1 FROM auth.users WHERE id = NEW.user_id) THEN
      RAISE EXCEPTION 'account_deleted';
    END IF;
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION public.guard_deleted_account_data() FROM PUBLIC, anon, authenticated;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'user_journey_task_completions','user_milestone_completions','ls_user_habit_log',
    'user_habit_completions','spiritual_readings_archive','user_journeys',
    'user_custom_habits','spiritual_chat_conversations','spiritual_user_profiles',
    'user_consultation_usage','user_guru_ai_weekly','avatars','sanctuary_customization',
    'push_tokens','user_achievements','user_audio_progress','user_book_progress',
    'user_chapter_progress','user_verse_progress','user_verse_notes','user_parva_progress',
    'user_progress','user_presence','user_daily_tasks','user_daily_streak',
    'user_gratitude_entries','user_task_progress','user_spiritual_progress',
    'user_pregnancy_journey','user_gs_content_progress','baby_milestones',
    'user_samskara_completions','app_profiles'
  ] LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS guard_deleted_account ON public.%I', t);
    EXECUTE format('CREATE TRIGGER guard_deleted_account BEFORE INSERT OR UPDATE ON public.%I FOR EACH ROW EXECUTE FUNCTION public.guard_deleted_account_data()', t);
  END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.account_allows_writes(uid uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT uid IS NOT NULL AND EXISTS (SELECT 1 FROM auth.users WHERE id = uid)
    AND NOT EXISTS (SELECT 1 FROM public.account_deletions WHERE deleted_user_id = uid);
$$;
REVOKE ALL ON FUNCTION public.account_allows_writes(uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.account_allows_writes(uuid) TO authenticated, service_role;
DROP POLICY IF EXISTS account_deletion_storage_guard ON storage.objects;
CREATE POLICY account_deletion_storage_guard ON storage.objects AS RESTRICTIVE FOR ALL TO authenticated
  USING (public.account_allows_writes(auth.uid()))
  WITH CHECK (public.account_allows_writes(auth.uid()));
