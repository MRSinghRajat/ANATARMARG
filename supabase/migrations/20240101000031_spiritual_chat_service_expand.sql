-- Allow AI Guru app service ids (SpiritualServiceType.name) on spiritual chat tables.

ALTER TABLE spiritual_chat_conversations
  DROP CONSTRAINT IF EXISTS spiritual_chat_conversations_service_check;

ALTER TABLE spiritual_chat_conversations
  ADD CONSTRAINT spiritual_chat_conversations_service_check
  CHECK (service IN (
    'askAnything',
    'upcomingEvents',
    'numerology',
    'kundli',
    'palmistry',
    'mantra',
    'tarot',
    'vastu',
    'gemstone',
    'muhurat',
    'dreamAnalysis',
    'kundliMatching'
  ));

ALTER TABLE spiritual_user_profiles
  DROP CONSTRAINT IF EXISTS spiritual_user_profiles_service_check;

ALTER TABLE spiritual_user_profiles
  ADD CONSTRAINT spiritual_user_profiles_service_check
  CHECK (service IN (
    'askAnything',
    'upcomingEvents',
    'numerology',
    'kundli',
    'palmistry',
    'mantra',
    'tarot',
    'vastu',
    'gemstone',
    'muhurat',
    'dreamAnalysis',
    'kundliMatching'
  ));
