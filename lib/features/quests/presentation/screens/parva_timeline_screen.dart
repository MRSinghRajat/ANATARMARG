import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/parva_model.dart';

class ParvaTimelineScreen extends ConsumerStatefulWidget {
  final ParvaModel parva;

  const ParvaTimelineScreen({
    super.key,
    required this.parva,
  });

  @override
  ConsumerState<ParvaTimelineScreen> createState() =>
      _ParvaTimelineScreenState();
}

class _ParvaTimelineScreenState extends ConsumerState<ParvaTimelineScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text(widget.parva.name),
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Parva Header Card
              _buildParvaHeader(),

              const SizedBox(height: 24),

              // Timeline Section
              Text(
                'Timeline',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
              ),
              const SizedBox(height: 16),

              // Timeline Events
              _buildTimeline(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParvaHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.warmOrange.withOpacity(0.1),
              AppColors.saffron.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.parva.status == ParvaStatus.completed
                        ? Colors.green.shade600
                        : widget.parva.status == ParvaStatus.active
                            ? AppColors.warmOrange
                            : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.parva.displayNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (widget.parva.status == ParvaStatus.completed)
                  const Icon(Icons.check_circle, color: Colors.green, size: 24)
                else if (widget.parva.status == ParvaStatus.active)
                  const Icon(Icons.play_circle_filled,
                      color: AppColors.warmOrange, size: 24)
                else
                  const Icon(Icons.lock, color: Colors.grey, size: 24),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.parva.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.parva.subtitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 16),
            // Description placeholder
            Text(
              _getParvaDescription(widget.parva.id),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.6,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final events = _getTimelineEvents(widget.parva.id);

    return Column(
      children: List.generate(events.length, (index) {
        final event = events[index];
        final isLast = index == events.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line and dot
            Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.warmOrange,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 80,
                    color: Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Event content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['title'] as String,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E3A8A),
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event['description'] as String,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade700,
                                    height: 1.5,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _getParvaDescription(int parvaId) {
    // Placeholder descriptions - replace with actual content from GPT API
    switch (parvaId) {
      case 1:
        return 'Adi Parva is the first book of the Mahabharata. It introduces the main characters, their origins, and sets the foundation for the epic tale. This parva covers the birth of the Pandavas and Kauravas, their early lives, and the events leading to the great war.';
      case 2:
        return 'Sabha Parva describes the great assembly hall built by the Pandavas and the famous dice game where Yudhishthira loses everything, leading to the exile of the Pandavas.';
      case 3:
        return 'Vana Parva narrates the twelve years of forest exile of the Pandavas. During this time, they face numerous challenges, meet sages, and learn valuable lessons about Dharma, duty, and righteousness.';
      default:
        return 'This parva contains important events from the Mahabharata, teaching valuable lessons about Dharma, duty, and the path of righteousness.';
    }
  }

  List<Map<String, String>> _getTimelineEvents(int parvaId) {
    // Placeholder timeline events - replace with actual content
    switch (parvaId) {
      case 1: // Adi Parva
        return [
          {
            'title': 'Birth of the Pandavas',
            'description':
                'The five Pandava brothers are born to Kunti and Madri through divine boons.',
          },
          {
            'title': 'Childhood in Hastinapur',
            'description':
                'The Pandavas and Kauravas grow up together, learning warfare and Dharma from their teachers.',
          },
          {
            'title': 'The House of Lac',
            'description':
                'Duryodhana plots to kill the Pandavas by setting fire to a house made of lac, but they escape.',
          },
          {
            'title': 'Marriage to Draupadi',
            'description':
                'Arjuna wins Draupadi in her swayamvara, and she becomes the wife of all five Pandavas.',
          },
        ];
      case 2: // Sabha Parva
        return [
          {
            'title': 'The Great Assembly Hall',
            'description':
                'The Pandavas build a magnificent assembly hall, inviting all kings and sages.',
          },
          {
            'title': 'The Dice Game',
            'description':
                'Yudhishthira is invited to play dice and loses everything, including his kingdom and brothers.',
          },
          {
            'title': 'Draupadi\'s Disrobing',
            'description':
                'Dushasana attempts to disrobe Draupadi, but Krishna protects her with infinite cloth.',
          },
          {
            'title': 'The Exile Begins',
            'description':
                'The Pandavas are forced into exile for 13 years, with 12 years in the forest and 1 year incognito.',
          },
        ];
      case 3: // Vana Parva
        return [
          {
            'title': 'Entering the Forest',
            'description':
                'The Pandavas begin their 12-year exile, living in various forests and learning from sages.',
          },
          {
            'title': 'Meeting with Sages',
            'description':
                'They meet many wise sages who share stories and teachings about Dharma and righteousness.',
          },
          {
            'title': 'Arjuna\'s Journey',
            'description':
                'Arjuna travels to the Himalayas to obtain divine weapons from Lord Shiva and Indra.',
          },
          {
            'title': 'Preparing for Return',
            'description':
                'As the exile nears its end, the Pandavas prepare for their year of incognito living.',
          },
        ];
      default:
        return [
          {
            'title': 'Beginning of the Journey',
            'description':
                'The journey through this parva begins with important events and teachings.',
          },
          {
            'title': 'Key Events',
            'description':
                'Various significant events unfold, teaching valuable lessons about Dharma and duty.',
          },
        ];
    }
  }
}
