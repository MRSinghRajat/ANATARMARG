-- Add 'planning' mode to user_pregnancy_journey CHECK constraint
ALTER TABLE user_pregnancy_journey
  DROP CONSTRAINT IF EXISTS user_pregnancy_journey_mode_check;

ALTER TABLE user_pregnancy_journey
  ADD CONSTRAINT user_pregnancy_journey_mode_check
  CHECK (mode IN ('planning', 'prenatal', 'postnatal', 'completed'));

-- Allow delete for users so they can remove their journey
DROP POLICY IF EXISTS "Users can delete own journey" ON user_pregnancy_journey;
CREATE POLICY "Users can delete own journey"
  ON user_pregnancy_journey FOR DELETE
  USING (auth.uid() = user_id);
