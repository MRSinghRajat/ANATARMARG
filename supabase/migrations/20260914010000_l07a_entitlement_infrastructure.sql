-- L07a: infrastructure only. Apply L06 before running reconciliation.
-- Network fetches hold a bounded per-account lease. Application and deletion
-- share an advisory lock; expired lease tokens cannot apply stale snapshots.
CREATE TABLE public.user_entitlements (
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  entitlement_id text NOT NULL, is_active boolean NOT NULL DEFAULT false,
  expires_at timestamptz,
  environment text CHECK (environment IN ('PRODUCTION', 'SANDBOX', 'PROMOTIONAL')),
  updated_at timestamptz NOT NULL DEFAULT now(), PRIMARY KEY (user_id, entitlement_id)
);
ALTER TABLE public.user_entitlements ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.user_entitlements FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.user_entitlements TO authenticated;
GRANT ALL ON public.user_entitlements TO service_role;
CREATE POLICY user_entitlements_select_own ON public.user_entitlements
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
-- Minimal replay ledger: no raw payload, account IDs or subscriber attributes.
CREATE TABLE public.revenuecat_webhook_events (
  event_id text PRIMARY KEY, event_type text NOT NULL, received_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE public.revenuecat_sync_leases (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  lease_token uuid NOT NULL, lease_until timestamptz NOT NULL
);
ALTER TABLE public.revenuecat_webhook_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.revenuecat_sync_leases ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.revenuecat_webhook_events, public.revenuecat_sync_leases FROM PUBLIC, anon, authenticated;
GRANT ALL ON public.revenuecat_webhook_events, public.revenuecat_sync_leases TO service_role;
CREATE FUNCTION public.has_active_entitlement(uid uuid, required_entitlement_id text DEFAULT 'Antar marg Pro')
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT uid = auth.uid() AND EXISTS (
    SELECT 1 FROM public.user_entitlements WHERE user_id = uid
      AND entitlement_id = required_entitlement_id AND is_active
      AND (expires_at IS NULL OR expires_at > now())
  );
$$;
REVOKE ALL ON FUNCTION public.has_active_entitlement(uuid,text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.has_active_entitlement(uuid,text) TO anon, authenticated, service_role;

CREATE FUNCTION public.claim_revenuecat_sync(p_event_id text, p_user_ids uuid[])
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE uid uuid; token uuid := gen_random_uuid(); accepted uuid[] := '{}';
BEGIN
  IF p_event_id IS NULL OR length(p_event_id) NOT BETWEEN 1 AND 200
     OR p_user_ids IS NULL OR cardinality(p_user_ids) > 100 THEN
    RAISE EXCEPTION 'invalid_sync_request';
  END IF;
  IF EXISTS (SELECT 1 FROM public.revenuecat_webhook_events WHERE event_id = p_event_id) THEN
    RETURN jsonb_build_object('already_processed', true);
  END IF;
  FOR uid IN SELECT DISTINCT unnest(p_user_ids) ORDER BY 1 LOOP
    IF uid IS NULL THEN RAISE EXCEPTION 'invalid_user'; END IF;
    PERFORM pg_advisory_xact_lock(hashtextextended(uid::text, 0));
    IF EXISTS (SELECT 1 FROM public.account_deletions WHERE deleted_user_id = uid)
       OR NOT EXISTS (SELECT 1 FROM auth.users WHERE id = uid) THEN CONTINUE; END IF;
    IF EXISTS (SELECT 1 FROM public.revenuecat_sync_leases
               WHERE user_id = uid AND lease_until > clock_timestamp()) THEN
      RAISE EXCEPTION 'reconciliation_busy';
    END IF;
    INSERT INTO public.revenuecat_sync_leases VALUES(uid, token, clock_timestamp() + interval '90 seconds')
    ON CONFLICT (user_id) DO UPDATE SET lease_token = EXCLUDED.lease_token, lease_until = EXCLUDED.lease_until;
    accepted := array_append(accepted, uid);
  END LOOP;
  RETURN jsonb_build_object('already_processed', false, 'lease_token', token, 'user_ids', accepted);
END;
$$;
CREATE FUNCTION public.apply_revenuecat_event(
  p_event_id text, p_event_type text, p_lease_token uuid, p_user_ids uuid[], p_rows jsonb
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE uid uuid; r jsonb; affected integer := 0;
BEGIN
  IF p_event_id IS NULL OR length(p_event_id) NOT BETWEEN 1 AND 200
    OR p_event_type IS NULL OR length(p_event_type) NOT BETWEEN 1 AND 100
    OR p_user_ids IS NULL OR cardinality(p_user_ids) > 100
    OR p_rows IS NULL OR jsonb_typeof(p_rows) <> 'array'
    OR jsonb_array_length(p_rows) <> cardinality(p_user_ids) THEN
    RAISE EXCEPTION 'invalid_snapshot';
  END IF;
  FOR uid IN SELECT DISTINCT unnest(p_user_ids) ORDER BY 1 LOOP
    PERFORM pg_advisory_xact_lock(hashtextextended(uid::text, 0));
  END LOOP;
  IF EXISTS (SELECT 1 FROM public.revenuecat_webhook_events WHERE event_id = p_event_id) THEN
    RETURN jsonb_build_object('ok', true, 'already_processed', true);
  END IF;
  FOR uid IN SELECT DISTINCT unnest(p_user_ids) ORDER BY 1 LOOP
    IF EXISTS (SELECT 1 FROM public.account_deletions WHERE deleted_user_id = uid)
       OR NOT EXISTS (SELECT 1 FROM auth.users WHERE id = uid) THEN CONTINUE; END IF;
    IF NOT EXISTS (SELECT 1 FROM public.revenuecat_sync_leases
      WHERE user_id = uid AND lease_token = p_lease_token AND lease_until > clock_timestamp()) THEN
      RAISE EXCEPTION 'stale_sync_lease';
    END IF;
    IF (SELECT count(*) FROM jsonb_array_elements(p_rows) x WHERE x->>'user_id' = uid::text) <> 1 THEN
      RAISE EXCEPTION 'missing_or_duplicate_snapshot';
    END IF;
    SELECT x INTO r FROM jsonb_array_elements(p_rows) x WHERE x->>'user_id' = uid::text;
    IF r->>'entitlement_id' IS DISTINCT FROM 'Antar marg Pro'
       OR jsonb_typeof(r->'is_active') IS DISTINCT FROM 'boolean'
       OR NOT (r ? 'expires_at')
       OR ((r->>'is_active')::boolean AND r->>'environment' IS NULL) THEN
      RAISE EXCEPTION 'invalid_entitlement';
    END IF;
    -- Includes explicit inactive Pro when absent remotely; other tiers unaffected.
    INSERT INTO public.user_entitlements(user_id, entitlement_id, is_active, expires_at, environment)
    VALUES(uid, 'Antar marg Pro', (r->>'is_active')::boolean, (r->>'expires_at')::timestamptz, r->>'environment')
    ON CONFLICT (user_id, entitlement_id) DO UPDATE SET is_active = EXCLUDED.is_active,
      expires_at = EXCLUDED.expires_at, environment = EXCLUDED.environment, updated_at = now();
    DELETE FROM public.revenuecat_sync_leases WHERE user_id = uid AND lease_token = p_lease_token;
    affected := affected + 1;
  END LOOP;
  INSERT INTO public.revenuecat_webhook_events(event_id, event_type) VALUES(p_event_id, p_event_type)
    ON CONFLICT (event_id) DO NOTHING;
  RETURN jsonb_build_object('ok', true, 'affected_users', affected);
END;
$$;
CREATE FUNCTION public.release_revenuecat_sync(p_lease_token uuid)
RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path = '' AS $$
  DELETE FROM public.revenuecat_sync_leases WHERE lease_token = p_lease_token;
$$;
CREATE FUNCTION public.prune_revenuecat_events()
RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path = '' AS $$
  DELETE FROM public.revenuecat_webhook_events WHERE received_at < now() - interval '90 days';
$$;
REVOKE ALL ON FUNCTION public.claim_revenuecat_sync(text,uuid[]),
  public.apply_revenuecat_event(text,text,uuid,uuid[],jsonb), public.release_revenuecat_sync(uuid),
  public.prune_revenuecat_events() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.claim_revenuecat_sync(text,uuid[]),
  public.apply_revenuecat_event(text,text,uuid,uuid[],jsonb), public.release_revenuecat_sync(uuid),
  public.prune_revenuecat_events() TO service_role;
