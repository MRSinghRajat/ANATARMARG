import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../../shared/widgets/animated_guide.dart';
import '../../../content/data/models/verse_model.dart';
import '../../data/models/parva_model.dart';
import '../../data/models/quest_stage_model.dart';
import '../../data/repositories/quest_stage_repository.dart';
import '../widgets/quest_path_painter.dart';

class ParvaQuestPathScreen extends ConsumerStatefulWidget {
  final ParvaModel parva;

  const ParvaQuestPathScreen({
    super.key,
    required this.parva,
  });

  @override
  ConsumerState<ParvaQuestPathScreen> createState() =>
      _ParvaQuestPathScreenState();
}

class _ParvaQuestPathScreenState extends ConsumerState<ParvaQuestPathScreen> {
  final QuestStageRepository _stageRepo = QuestStageRepository();
  final CoinService _coinService = CoinService();
  List<QuestStageModel> _stages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStages();
    _coinService.initialize();
  }

  Future<void> _loadStages() async {
    setState(() => _isLoading = true);
    try {
      final stages = await _stageRepo.getStagesForParva(widget.parva.id);
      setState(() {
        _stages = stages;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback: use repository's default stages
      final defaultStages = _stageRepo.getStagesForParvaSync(widget.parva.id);
      setState(() {
        _stages = defaultStages;
        _isLoading = false;
      });
    }
  }

  void _onStartQuest(QuestStageModel stage) {
    final verse = VerseContent(
      id: 'quest_${widget.parva.id}_${stage.id}',
      book: 'Mahabharata - ${widget.parva.name}',
      chapter: 'Stage ${stage.orderIndex}',
      verseNumber: null,
      title: stage.title,
      content: stage.content ?? stage.description,
      context: stage.description,
    );
    Navigator.pushNamed(
      context,
      AppRouter.reading,
      arguments: {
        'verse': verse,
        'taskId': 'quest_${widget.parva.id}_${stage.id}',
        'coinReward': 50,
        'taskType': null,
        'questStageKey': '${widget.parva.id}_${stage.id}',
      },
    ).then((_) {
      if (mounted) _loadStages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildPathContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.blue),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PARVA ${widget.parva.displayNumber}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                Text(
                  widget.parva.name.replaceAll(' PARVA', ' Parva'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E3A8A),
                      ),
                ),
              ],
            ),
          ),
          StreamBuilder<int>(
            stream: _coinService.coinStream,
            initialData: _coinService.currentBalance,
            builder: (context, snapshot) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.warmOrange, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${snapshot.data ?? 0}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPathContent(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F0E6),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              _buildBackgroundShapes(),
              _buildWindingPath(),
              _buildPathColumn(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundShapes() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _AmbientShapesPainter(),
      ),
    );
  }

  Widget _buildWindingPath() {
    return Positioned.fill(
      child: CustomPaint(
        painter: WindingPathPainter(
          nodeCount: _stages.length,
          segmentHeight: 140,
          windOffset: 56,
        ),
      ),
    );
  }

  Widget _buildPathColumn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < _stages.length; i++) ...[
            _buildPathNode(context, i, _stages[i]),
            if (i < _stages.length - 1) _buildPathConnector(),
          ],
        ],
      ),
    );
  }

  Widget _buildPathConnector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 3,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathNode(
      BuildContext context, int index, QuestStageModel stage) {
    final isLeft = index.isEven;

    if (stage.status == QuestStageStatus.completed) {
      return _buildCompletedNode(context, stage, isLeft);
    }
    if (stage.status == QuestStageStatus.current) {
      return _buildCurrentNode(context, stage);
    }
    return _buildLockedNode(context, stage, isLeft);
  }

  Widget _buildCompletedNode(
      BuildContext context, QuestStageModel stage, bool isLeft) {
    return Row(
      mainAxisAlignment:
          isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (!isLeft) const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade600.withOpacity(0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              stage.title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        if (isLeft) const Spacer(),
      ],
    );
  }

  Widget _buildCurrentNode(BuildContext context, QuestStageModel stage) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.warmOrange,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'YOU ARE HERE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warmOrange.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 56,
              height: 56,
              child: AnimatedGuide(width: 288, height: 288),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          stage.title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _buildCurrentQuestCard(context, stage),
      ],
    );
  }

  Widget _buildLockedNode(
      BuildContext context, QuestStageModel stage, bool isLeft) {
    return Row(
      mainAxisAlignment:
          isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (!isLeft) const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              stage.title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        if (isLeft) const Spacer(),
      ],
    );
  }

  Widget _buildCurrentQuestCard(BuildContext context, QuestStageModel stage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warmOrange, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stage.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3A8A),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '"${stage.description}"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _onStartQuest(stage),
              icon: const Icon(Icons.play_arrow, color: Colors.white, size: 22),
              label: const Text('START QUEST'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warmOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(size.width * 0.05, size.height)
      ..lineTo(size.width * 0.22, size.height * 0.55)
      ..lineTo(size.width * 0.38, size.height)
      ..close();
    canvas.drawPath(path1, paint);

    final path2 = Path()
      ..moveTo(size.width * 0.62, size.height)
      ..lineTo(size.width * 0.78, size.height * 0.6)
      ..lineTo(size.width * 0.95, size.height)
      ..close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
