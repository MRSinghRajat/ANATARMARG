import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/coin_service.dart';
import '../../data/models/journey_models.dart';
import '../providers/journey_providers.dart';

class JourneyMilestoneDetailScreen extends ConsumerStatefulWidget {
  final String userJourneyId;
  final String milestoneId;

  const JourneyMilestoneDetailScreen({
    super.key,
    required this.userJourneyId,
    required this.milestoneId,
  });

  @override
  ConsumerState<JourneyMilestoneDetailScreen> createState() =>
      _JourneyMilestoneDetailScreenState();
}

class _JourneyMilestoneDetailScreenState
    extends ConsumerState<JourneyMilestoneDetailScreen> {
  JourneyMilestone? _milestone;
  bool _loading = true;
  bool _completed = false;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(journeyRepositoryProvider);
    final milestone = await repo.getMilestoneById(widget.milestoneId);
    setState(() {
      _milestone = milestone;
      _loading = false;
    });
  }

  Future<void> _complete() async {
    if (_milestone == null || _completed) return;
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    setState(() => _completed = true);
    final repo = ref.read(journeyRepositoryProvider);
    await repo.completeMilestone(
      userId: uid,
      userJourneyId: widget.userJourneyId,
      milestoneId: widget.milestoneId,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      coinsEarned: _milestone!.coinReward ?? 0,
    );
    if ((_milestone!.coinReward ?? 0) > 0) {
      CoinService().addCoins(_milestone!.coinReward!);
    }
    ref.invalidate(activeJourneyProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Milestone complete! +${_milestone!.coinReward ?? 0} coins')));
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        appBar: AppBar(title: const Text('Milestone')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_milestone == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        appBar: AppBar(title: const Text('Milestone')),
        body: const Center(child: Text('Milestone not found')),
      );
    }
    final m = _milestone!;
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text(m.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(m.icon ?? '🪔', style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(m.title,
                        style: Theme.of(context).textTheme.headlineSmall),
                    if (m.description != null) ...[
                      const SizedBox(height: 12),
                      Text(m.description!,
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ],
                ),
              ),
            ),
            if (m.allowNotes) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _completed ? null : _complete,
              child: Text(_completed ? 'Completed' : 'Mark complete'),
            ),
          ],
        ),
      ),
    );
  }
}
