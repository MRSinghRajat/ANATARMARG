-- Journey member counts for "Joined by X" in the Journey (Our Spiritual Circle) tab.
-- Returns counts from user_journeys; SECURITY DEFINER so anon/authenticated can read global stats.

CREATE OR REPLACE FUNCTION get_journey_type_member_counts()
RETURNS TABLE (journey_type_id uuid, member_count bigint)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT journey_type_id::uuid, COUNT(*)::bigint
  FROM user_journeys
  WHERE status IN ('active', 'paused')
  GROUP BY journey_type_id;
$$;

-- Allow anon and authenticated to call (for app display)
GRANT EXECUTE ON FUNCTION get_journey_type_member_counts() TO anon;
GRANT EXECUTE ON FUNCTION get_journey_type_member_counts() TO authenticated;

COMMENT ON FUNCTION get_journey_type_member_counts() IS 'Returns member count per journey type for Journey tab (Our Spiritual Circle) UI.';
