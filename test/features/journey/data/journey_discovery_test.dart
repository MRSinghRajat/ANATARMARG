import 'package:antarmarg/features/journey/data/journey_discovery.dart';
import 'package:antarmarg/features/journey/data/models/journey_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('discovery includes only active available launch candidates', () {
    const types = [
      JourneyType(id: '1', slug: 'hanuman-chalisa-40', title: 'Hanuman'),
      JourneyType(id: '2', slug: 'work-stress-21', title: 'Workday'),
      JourneyType(
          id: '3',
          slug: 'daily-practice-7',
          title: 'Starter',
          isComingSoon: true),
      JourneyType(id: '4', slug: 'garbh-sanskar', title: 'Deferred'),
      JourneyType(
          id: '5',
          slug: 'hanuman-chalisa-40',
          title: 'Inactive',
          isActive: false),
    ];
    expect(types.where(isMvpJourneyCandidate).map((t) => t.id), ['1', '2']);
    // Filtering does not mutate the catalog used to resolve existing journeys.
    expect(types.map((t) => t.id), ['1', '2', '3', '4', '5']);
  });
}
