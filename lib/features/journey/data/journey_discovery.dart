import 'models/journey_type.dart';

/// Product scope for new discovery, not an access or editorial approval check.
/// Existing enrollments must continue to use the complete catalog.
bool isMvpJourneyCandidate(JourneyType type) =>
    type.isActive &&
    !type.isComingSoon &&
    const {
      // Keep starter + one approved paid program in discovery.
      // Hide specialist programs that contain unsupported physiological claims.
      'hanuman-chalisa-40',
      'daily-practice-7',
    }.contains(type.slug);
