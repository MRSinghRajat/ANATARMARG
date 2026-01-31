import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  @override
  void initState() {
    super.initState();
    CoinService().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              // TODO: Navigate to leaderboard
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Section
              Text(
                'Overview',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Stats Grid
              const Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Books Completed',
                      value: 0,
                      icon: Icons.menu_book,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                      title: 'Chapters Read',
                      value: 0,
                      icon: Icons.library_books,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Daily Tasks',
                      value: 2,
                      icon: Icons.task_alt,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                      title: 'Custom Readings',
                      value: 0,
                      icon: Icons.bookmark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Monthly Activity
              Text(
                'Monthly Activity',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildCalendar(context),

              const SizedBox(height: 32),

              // Coins & Progress
              Text(
                'Progress',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              StreamBuilder<int>(
                stream: CoinService().coinStream,
                initialData: CoinService().currentBalance,
                builder: (context, snapshot) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.diamond,
                            size: 32,
                            color: AppColors.coinGreen,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Coins',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  '${snapshot.data ?? 0}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      // Bottom nav removed - handled by MainNavigationScreen
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startingWeekday = firstDay.weekday % 7;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Month Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_getMonthName(now.month)} ${now.year}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Weekday Headers
            Row(
              children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'].map((day) {
                return Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 8),

            // Calendar Grid
            ...List.generate(6, (weekIndex) {
              return Row(
                children: List.generate(7, (dayIndex) {
                  final dayNumber =
                      weekIndex * 7 + dayIndex - startingWeekday + 1;

                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const Expanded(child: SizedBox());
                  }

                  // Mock: Some days have activity (highlighted)
                  final hasActivity = dayNumber % 3 == 0;

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      height: 40,
                      decoration: BoxDecoration(
                        color: hasActivity
                            ? AppColors.warmOrange.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: dayNumber == now.day
                            ? Border.all(color: AppColors.warmOrange, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontWeight: dayNumber == now.day
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: hasActivity
                                ? AppColors.warmOrange
                                : AppColors.primaryText,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
