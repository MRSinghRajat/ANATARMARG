import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/profile_pro_upgrade_nav.dart';
import '../../../../shared/services/premium_service.dart';
import '../../data/models/journey_models.dart';
import '../providers/journey_providers.dart';

/// Whether this journey catalog entry requires Pro.
bool journeyTypeRequiresPremium(JourneyType type) => type.isPremium;

Future<bool> userCanAccessJourneyType(JourneyType type) async {
  if (!type.isPremium) return true;
  return PremiumService.instance.isPremium;
}

Future<JourneyType?> journeyTypeForUserJourney(WidgetRef ref, String userJourneyId) async {
  final userJourney = await ref.read(userJourneyProvider(userJourneyId).future);
  if (userJourney == null) return null;
  final types = await ref.read(journeyTypesProvider.future);
  for (final type in types) {
    if (type.id == userJourney.journeyTypeId) return type;
  }
  return null;
}

/// Blocks child until premium access is verified for [slug] or [userJourneyId].
class JourneyPremiumGate extends ConsumerStatefulWidget {
  const JourneyPremiumGate({
    super.key,
    this.slug,
    this.userJourneyId,
    required this.child,
  }) : assert(slug != null || userJourneyId != null);

  final String? slug;
  final String? userJourneyId;
  final Widget child;

  @override
  ConsumerState<JourneyPremiumGate> createState() => _JourneyPremiumGateState();
}

class _JourneyPremiumGateState extends ConsumerState<JourneyPremiumGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verifyAccess());
  }

  Future<void> _verifyAccess() async {
    JourneyType? type;
    if (widget.slug != null) {
      type = await ref.read(journeyTypeBySlugProvider(widget.slug!).future);
    } else if (widget.userJourneyId != null) {
      type = await journeyTypeForUserJourney(ref, widget.userJourneyId!);
    }

    if (!mounted) return;

    if (type != null &&
        type.isPremium &&
        !await PremiumService.instance.isPremium) {
      if (!mounted) return;
      navigateToProfileForProUpgrade(
        context,
        message: 'Spiritual journeys unlock with Pro. Open Profile to upgrade.',
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.child;
  }
}
