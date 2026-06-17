import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/premium_service.dart';
import '../../../../core/utils/profile_pro_upgrade_nav.dart';
import '../../data/models/custom_habit_model.dart';
import '../../data/services/custom_habit_service.dart';
import '../widgets/add_habit_sheet.dart';

class HabitDetailScreen extends StatefulWidget {
  final CustomHabit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen>
    with SingleTickerProviderStateMixin {
  late CustomHabit _habit;
  final CustomHabitService _habitService = CustomHabitService.instance;
  late AnimationController _fadeController;
  bool _isPremium = false;
  StreamSubscription<bool>? _premiumSubscription;

  @override
  void initState() {
    super.initState();
    _habit = widget.habit;
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    PremiumService.instance.isPremium.then((v) {
      if (mounted) setState(() => _isPremium = v);
    });
    _premiumSubscription = PremiumService.instance.premiumStatusStream.listen((v) {
      if (mounted) setState(() => _isPremium = v);
    });
  }

  @override
  void dispose() {
    _premiumSubscription?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _editHabit() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddHabitSheet(
        editingHabit: _habit,
        onHabitAdded: () async {
          await _habitService.refresh();
          // Try to find the updated habit in the service
          final updated = _habitService.habits.where((h) => h.id == _habit.id).firstOrNull;
          if (updated != null && mounted) {
            setState(() => _habit = updated);
          }
        },
      ),
    );
  }

  Future<void> _deleteHabit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          'Delete Habit?',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          'This will permanently remove "${_habit.title}" and all its history.',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _habitService.deleteHabit(_habit.id);
      if (mounted) {
        Navigator.pop(context, true); // true = habit deleted
      }
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle;
      case 'water_drop':
        return Icons.water_drop;
      case 'menu_book':
        return Icons.menu_book;
      case 'favorite':
        return Icons.favorite;
      case 'accessibility_new':
        return Icons.accessibility_new;
      case 'phone_disabled':
        return Icons.phone_disabled;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'air':
        return Icons.air;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'bedtime':
        return Icons.bedtime;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'Habit Details',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _isPremium ? Icons.edit_outlined : Icons.lock_outline_rounded,
                      color: Colors.white54,
                    ),
                    onPressed: _isPremium
                        ? _editHabit
                        : () => navigateToProfileForProUpgrade(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: FadeTransition(
                opacity: _fadeController,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),

                      // Icon + Title header
                      _buildHeader(),

                      const SizedBox(height: 24),

                      // Description
                      if (_habit.description != null &&
                          _habit.description!.isNotEmpty)
                        _buildDescriptionCard(),

                      // Schedule info
                      _buildScheduleCard(),

                      const SizedBox(height: 16),

                      // Streak stats
                      _buildStreakStats(),

                      const SizedBox(height: 16),

                      // Meta info
                      _buildMetaInfo(),

                      const SizedBox(height: 32),

                      // Action buttons
                      _buildActions(),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getIconData(_habit.iconName),
              color: AppColors.primaryOrange,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _habit.title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _habit.isCompletedToday
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _habit.isCompletedToday
                  ? 'Completed Today'
                  : 'Pending Today',
              style: GoogleFonts.poppins(
                color: _habit.isCompletedToday
                    ? Colors.green
                    : Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D23),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notes,
                    color: Colors.white38, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Description',
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _habit.description!,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {
    String frequencyLabel;
    String frequencyDetail;
    IconData frequencyIcon;

    switch (_habit.frequency) {
      case HabitFrequency.daily:
        frequencyLabel = 'Daily';
        frequencyDetail = 'Every day';
        frequencyIcon = Icons.calendar_today;
        break;
      case HabitFrequency.weekly:
        frequencyLabel = 'Weekly';
        frequencyDetail = 'Every Sunday';
        frequencyIcon = Icons.date_range;
        break;
      case HabitFrequency.specificDays:
        frequencyLabel = 'Specific Days';
        frequencyDetail = _habit.scheduledDayNames.join(', ');
        frequencyIcon = Icons.event_note;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D23),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(frequencyIcon,
                  color: Colors.white38, size: 16),
              const SizedBox(width: 8),
              Text(
                'Schedule',
                style: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  frequencyLabel,
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                frequencyDetail,
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (_habit.frequency == HabitFrequency.specificDays &&
              _habit.specificDays != null) ...[
            const SizedBox(height: 12),
            _buildDayChips(),
          ],
        ],
      ),
    );
  }

  Widget _buildDayChips() {
    const allDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (i) {
        final isActive = _habit.specificDays?.contains(i) ?? false;
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.primaryOrange.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.04),
            border: Border.all(
              color: isActive
                  ? AppColors.primaryOrange.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            allDays[i][0],
            style: GoogleFonts.poppins(
              color: isActive
                  ? AppColors.primaryOrange
                  : Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStreakStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.local_fire_department,
            iconColor: Colors.orange,
            label: 'Current',
            value: '${_habit.currentStreak}',
            sublabel: 'day streak',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.emoji_events,
            iconColor: Colors.amber,
            label: 'Longest',
            value: '${_habit.longestStreak}',
            sublabel: 'day streak',
          ),
        ),
        if (_habit.targetStreak != null && _habit.targetStreak! > 0) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _statCard(
              icon: Icons.flag,
              iconColor: Colors.blue,
              label: 'Target',
              value: '${_habit.targetStreak}',
              sublabel: 'days',
            ),
          ),
        ],
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String sublabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D23),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            sublabel,
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaInfo() {
    final createdStr =
        DateFormat('MMM d, yyyy').format(_habit.createdAt);
    final lastCompleted = _habit.lastCompletedDate != null
        ? DateFormat('MMM d, yyyy').format(_habit.lastCompletedDate!)
        : 'Never';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D23),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          _metaRow(Icons.calendar_month, 'Created', createdStr),
          Divider(
              color: Colors.white.withValues(alpha: 0.06), height: 20),
          _metaRow(
              Icons.check_circle_outline, 'Last Completed', lastCompleted),
          Divider(
              color: Colors.white.withValues(alpha: 0.06), height: 20),
          _metaRow(Icons.category_outlined, 'Category',
              _habit.category.toUpperCase()),
        ],
      ),
    );
  }

  Widget _metaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white38,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    if (!_isPremium) {
      return SizedBox(
        height: 48,
        child: OutlinedButton.icon(
          onPressed: () => navigateToProfileForProUpgrade(context),
          icon: const Icon(Icons.workspace_premium_outlined, size: 18),
          label: Text(
            'Upgrade to Pro to edit or delete habits',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryOrange,
            side: BorderSide(
                color: AppColors.primaryOrange.withValues(alpha: 0.4)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _editHabit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(
              'Edit Habit',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryOrange,
              side: BorderSide(
                  color: AppColors.primaryOrange.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _deleteHabit,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text(
              'Delete Habit',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(
                  color: Colors.red.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}
