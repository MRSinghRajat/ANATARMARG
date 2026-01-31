import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/coin_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final List<Map<String, dynamic>> _leaderboardData = [
    {'name': 'Arjun', 'coins': 2500, 'avatar': Icons.person},
    {'name': 'Priya', 'coins': 2350, 'avatar': Icons.person_2},
    {'name': 'Rahul', 'coins': 2100, 'avatar': Icons.person_3},
    {'name': 'Ananya', 'coins': 1950, 'avatar': Icons.person_4},
    {'name': 'Vikram', 'coins': 1800, 'avatar': Icons.person},
    {'name': 'Sneha', 'coins': 1650, 'avatar': Icons.person_2},
    {'name': 'Rohan', 'coins': 1500, 'avatar': Icons.person_3},
    {'name': 'Meera', 'coins': 1350, 'avatar': Icons.person_4},
    {'name': 'Karan', 'coins': 1200, 'avatar': Icons.person},
    {'name': 'Nisha', 'coins': 1000, 'avatar': Icons.person_2},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top 3 Podium
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPodiumItem(
                  rank: 2,
                  name: _leaderboardData[1]['name'],
                  coins: _leaderboardData[1]['coins'],
                  avatar: _leaderboardData[1]['avatar'],
                  height: 120,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 16),
                _buildPodiumItem(
                  rank: 1,
                  name: _leaderboardData[0]['name'],
                  coins: _leaderboardData[0]['coins'],
                  avatar: _leaderboardData[0]['avatar'],
                  height: 150,
                  color: const Color(0xFFFFD700), // Gold
                  isWinner: true,
                ),
                const SizedBox(width: 16),
                _buildPodiumItem(
                  rank: 3,
                  name: _leaderboardData[2]['name'],
                  coins: _leaderboardData[2]['coins'],
                  avatar: _leaderboardData[2]['avatar'],
                  height: 100,
                  color: const Color(0xFFCD7F32), // Bronze
                ),
              ],
            ),
          ),

          // List of other users
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _leaderboardData.length - 3 + 1, // +1 for current user if not in top 3
                  itemBuilder: (context, index) {
                    // Show current user pinned at the top of the list or in the list
                    if (index == 0) {
                      return _buildCurrentUserTile();
                    }

                    final dataIndex = index + 2; // Offset for Top 3
                    if (dataIndex >= _leaderboardData.length) return const SizedBox.shrink();

                    final user = _leaderboardData[dataIndex];
                    return _buildLeaderboardTile(
                      rank: dataIndex + 1,
                      name: user['name'],
                      coins: user['coins'],
                      avatar: user['avatar'],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem({
    required int rank,
    required String name,
    required int coins,
    required IconData avatar,
    required double height,
    required Color color,
    bool isWinner = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(
          Icons.emoji_events,
          color: isWinner ? const Color(0xFFFFD700) : Colors.transparent,
          size: 24,
        ),
        const SizedBox(height: 4),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.secondaryBackground,
          child: Icon(avatar, color: AppColors.primaryText),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.diamond, size: 12, color: Colors.white),
                  Text(
                    ' $coins',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile({
    required int rank,
    required String name,
    required int coins,
    required IconData avatar,
    bool isCurrentUser = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.lightYellow : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser ? Border.all(color: AppColors.warmOrange) : null,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '$rank',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.secondaryText,
              ),
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: isCurrentUser ? AppColors.warmOrange : Colors.grey.shade200,
            child: Icon(
              avatar,
              color: isCurrentUser ? Colors.white : AppColors.primaryText,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isCurrentUser ? AppColors.primaryText : AppColors.secondaryText,
              ),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.diamond, size: 16, color: AppColors.coinGreen),
              const SizedBox(width: 4),
              Text(
                '$coins',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.coinGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserTile() {
    return StreamBuilder<int>(
      stream: CoinService().coinStream,
      initialData: CoinService().currentBalance,
      builder: (context, snapshot) {
        return Column(
          children: [
            _buildLeaderboardTile(
              rank: 42, // Mock rank for user
              name: 'You',
              coins: snapshot.data ?? 0,
              avatar: Icons.person,
              isCurrentUser: true,
            ),
            const Divider(height: 32),
          ],
        );
      },
    );
  }
}
