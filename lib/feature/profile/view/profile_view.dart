import 'package:flutter/material.dart';
import 'package:gym_track/core/models/user_stats_model.dart';
import 'package:gym_track/core/models/achievement_model.dart';
import 'package:gym_track/core/models/user_goal_model.dart';
import 'package:gym_track/core/models/workout_summary_model.dart';
import 'package:gym_track/feature/profile/theme/profile_theme.dart';
import 'package:gym_track/feature/profile/widgets/metric_card.dart';
import 'package:gym_track/feature/profile/widgets/achievement_badge.dart';
import 'package:gym_track/feature/profile/widgets/goal_progress_card.dart';
import 'package:gym_track/feature/profile/widgets/workout_history_item.dart';

/// Profile view - A progress mirror showing user's discipline and commitment
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // Mock data - will be replaced with BLoC state management
  late UserStatsModel _stats;
  late List<AchievementModel> _achievements;
  late UserGoalModel _goal;
  late List<WorkoutSummaryModel> _recentWorkouts;

  @override
  void initState() {
    super.initState();
    print('Profile View Runned !');
    _loadMockData();
  }

  void _loadMockData() {
    _stats = UserStatsModel.mock();
    _achievements = AchievementModel.mockList();
    _goal = UserGoalModel.mock();
    _recentWorkouts = WorkoutSummaryModel.mockList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileTheme.darkBackground,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: ProfileTheme.accentCyan,
        backgroundColor: ProfileTheme.cardBackground,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: ProfileTheme.sectionSpacing),
                  _buildProgressSnapshot(),
                  const SizedBox(height: ProfileTheme.sectionSpacing),
                  _buildGoalsSection(),
                  const SizedBox(height: ProfileTheme.sectionSpacing),
                  _buildAchievementsSection(),
                  const SizedBox(height: ProfileTheme.sectionSpacing),
                  _buildPersonalStatsSection(),
                  const SizedBox(height: ProfileTheme.sectionSpacing),
                  _buildRecentActivitySection(),
                  const SizedBox(height: ProfileTheme.sectionSpacing),
                  _buildSettingsSection(),
                  const SizedBox(height: ProfileTheme.sectionSpacing),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: ProfileTheme.darkBackground,
      title: const Text(
        'Profile',
        style: TextStyle(color: ProfileTheme.primaryText),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          color: ProfileTheme.secondaryText,
          onPressed: () {
            _showSnackBar('Settings coming soon...');
          },
        ),
      ],
    );
  }

  /// Profile header with identity and status
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ProfileTheme.cardBackground,
            ProfileTheme.darkBackground,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ProfileTheme.accentCyan.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: ProfileTheme.accentCyan.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 38,
              backgroundColor: ProfileTheme.cardBorder,
              child: Icon(
                Icons.person,
                size: 40,
                color: ProfileTheme.secondaryText,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          const Text(
            'Alex Chen',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ProfileTheme.primaryText,
            ),
          ),
          const SizedBox(height: 4),

          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: ProfileTheme.accentCyan.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ProfileTheme.accentCyan.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Text(
              'Intermediate • Level 12',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ProfileTheme.accentCyan,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Active program
          if (_goal.programName != null)
            Text(
              _goal.programName!,
              style: ProfileTheme.caption.copyWith(fontSize: 14),
            ),
          const SizedBox(height: 8),

          // Streak badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_stats.streakDays} day streak',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Progress Snapshot - Most important section
  Widget _buildProgressSnapshot() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: ProfileTheme.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Snapshot',
            style: ProfileTheme.sectionHeader,
          ),
          const SizedBox(height: ProfileTheme.elementSpacing),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: ProfileTheme.elementSpacing,
            crossAxisSpacing: ProfileTheme.elementSpacing,
            childAspectRatio: 1.1,
            children: [
              MetricCard(
                icon: Icons.local_fire_department,
                value: '${_stats.streakDays}',
                label: 'Day Streak',
                iconColor: Colors.orange,
                onTap: () => _showSnackBar('Streak details coming soon...'),
              ),
              MetricCard(
                icon: Icons.fitness_center,
                value: '${_stats.totalWorkouts}',
                label: 'Workouts',
                iconColor: ProfileTheme.accentCyan,
                onTap: () => _showSnackBar('Workout history coming soon...'),
              ),
              MetricCard(
                icon: Icons.timer,
                value: _stats.formattedTotalTime,
                label: 'Total Time',
                iconColor: Colors.purple,
                onTap: () => _showSnackBar('Time breakdown coming soon...'),
              ),
              MetricCard(
                icon: Icons.trending_up,
                value: _stats.formattedMonthlyProgress,
                label: 'This Month',
                iconColor: ProfileTheme.successGreen,
                onTap: () => _showSnackBar('Monthly progress coming soon...'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Goals & Plan Section
  Widget _buildGoalsSection() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: ProfileTheme.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Goals & Plan',
            style: ProfileTheme.sectionHeader,
          ),
          const SizedBox(height: ProfileTheme.elementSpacing),
          GoalProgressCard(
            goal: _goal,
            onEditTap: () => _showSnackBar('Edit goals coming soon...'),
          ),
        ],
      ),
    );
  }

  /// Achievements & Milestones
  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: ProfileTheme.screenPadding),
          child: const Text(
            'Achievements',
            style: ProfileTheme.sectionHeader,
          ),
        ),
        const SizedBox(height: ProfileTheme.elementSpacing),
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
                horizontal: ProfileTheme.screenPadding),
            scrollDirection: Axis.horizontal,
            itemCount: _achievements.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return AchievementBadge(
                achievement: _achievements[index],
                onTap: () => _showAchievementDetails(_achievements[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Personal Statistics (Self-Comparison)
  Widget _buildPersonalStatsSection() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: ProfileTheme.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Statistics',
            style: ProfileTheme.sectionHeader,
          ),
          const SizedBox(height: ProfileTheme.elementSpacing),
          Container(
            padding: const EdgeInsets.all(ProfileTheme.cardPadding),
            decoration: BoxDecoration(
              color: ProfileTheme.cardBackground,
              borderRadius: BorderRadius.circular(ProfileTheme.cardRadius),
              border: Border.all(
                color: ProfileTheme.cardBorder,
                width: 1,
              ),
              boxShadow: [ProfileTheme.cardShadow],
            ),
            child: Column(
              children: [
                _buildStatRow(
                  Icons.fitness_center,
                  'Most Performed',
                  '${_stats.mostPerformedExercise} • ${_stats.mostPerformedCount} times',
                ),
                const Divider(color: ProfileTheme.cardBorder, height: 24),
                _buildStatRow(
                  Icons.timer,
                  'Avg Duration',
                  '${_stats.averageDurationMinutes} min per session',
                ),
                const Divider(color: ProfileTheme.cardBorder, height: 24),
                _buildStatRow(
                  _stats.trendDirection >= 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                  'Activity Trend',
                  '${_stats.formattedActivityTrend} vs last month',
                  iconColor: _stats.trendDirection >= 0
                      ? ProfileTheme.successGreen
                      : ProfileTheme.errorRed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value,
      {Color? iconColor}) {
    return Row(
      children: [
        Icon(
          icon,
          size: ProfileTheme.sectionIconSize,
          color: iconColor ?? ProfileTheme.accentCyan,
        ),
        const SizedBox(width: ProfileTheme.elementSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: ProfileTheme.caption,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: ProfileTheme.bodyText.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Recent Activity
  Widget _buildRecentActivitySection() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: ProfileTheme.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: ProfileTheme.sectionHeader,
          ),
          const SizedBox(height: ProfileTheme.elementSpacing),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentWorkouts.length,
            itemBuilder: (context, index) {
              return WorkoutHistoryItem(
                workout: _recentWorkouts[index],
                onTap: () => _showSnackBar('Workout details coming soon...'),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Settings (De-emphasized)
  Widget _buildSettingsSection() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: ProfileTheme.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ProfileTheme.secondaryText,
            ),
          ),
          const SizedBox(height: ProfileTheme.elementSpacing),
          Container(
            decoration: BoxDecoration(
              color: ProfileTheme.cardBackground,
              borderRadius: BorderRadius.circular(ProfileTheme.cardRadius),
              border: Border.all(
                color: ProfileTheme.cardBorder,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildSettingsItem(Icons.person_outline, 'Account'),
                const Divider(height: 1, color: ProfileTheme.cardBorder),
                _buildSettingsItem(
                    Icons.notifications_outlined, 'Notifications'),
                const Divider(height: 1, color: ProfileTheme.cardBorder),
                _buildSettingsItem(Icons.straighten, 'Units'),
                const Divider(height: 1, color: ProfileTheme.cardBorder),
                _buildSettingsItem(Icons.lock_outline, 'Privacy'),
                const Divider(height: 1, color: ProfileTheme.cardBorder),
                _buildSettingsItem(
                  Icons.logout,
                  'Logout',
                  textColor: ProfileTheme.errorRed,
                  onTap: _showLogoutDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title,
      {Color? textColor, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? ProfileTheme.secondaryText,
        size: 20,
      ),
      title: Text(
        title,
        style: ProfileTheme.bodyText.copyWith(
          fontSize: 14,
          color: textColor ?? ProfileTheme.primaryText,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: ProfileTheme.secondaryText.withOpacity(0.5),
        size: 20,
      ),
      onTap: onTap ?? () => _showSnackBar('$title coming soon...'),
    );
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _loadMockData();
    });
    _showSnackBar('Profile refreshed');
  }

  void _showAchievementDetails(AchievementModel achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ProfileTheme.cardBackground,
        title: Text(
          achievement.name,
          style: const TextStyle(color: ProfileTheme.primaryText),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: const TextStyle(color: ProfileTheme.secondaryText),
            ),
            if (!achievement.unlocked &&
                achievement.progressPercent != null) ...[
              const SizedBox(height: 16),
              Text(
                'Progress: ${achievement.progressCurrent}/${achievement.progressTarget}',
                style: const TextStyle(color: ProfileTheme.accentCyan),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: achievement.progressPercent! / 100,
                backgroundColor: ProfileTheme.cardBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    ProfileTheme.accentCyan),
              ),
            ],
            if (achievement.unlocked && achievement.unlockedAt != null) ...[
              const SizedBox(height: 16),
              Text(
                'Unlocked: ${achievement.unlockedAt!.toString().split(' ')[0]}',
                style: const TextStyle(color: ProfileTheme.successGreen),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: ProfileTheme.accentCyan),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ProfileTheme.cardBackground,
        title: const Text(
          'Logout',
          style: TextStyle(color: ProfileTheme.primaryText),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: ProfileTheme.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ProfileTheme.secondaryText),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Logout functionality coming soon...');
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: ProfileTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ProfileTheme.cardBackground,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
