import 'package:flutter/material.dart';
import 'package:gym_track/core/models/user_goal_model.dart';
import 'package:gym_track/feature/profile/theme/profile_theme.dart';

/// Card showing current goal with progress bar and weekly target
class GoalProgressCard extends StatelessWidget {
  final UserGoalModel goal;
  final VoidCallback? onEditTap;

  const GoalProgressCard({
    super.key,
    required this.goal,
    this.onEditTap,
  });

  IconData _getGoalIcon() {
    switch (goal.goalType) {
      case GoalType.fatLoss:
        return Icons.trending_down;
      case GoalType.muscleGain:
        return Icons.fitness_center;
      case GoalType.strength:
        return Icons.bolt;
      case GoalType.endurance:
        return Icons.directions_run;
      case GoalType.general:
        return Icons.favorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and goal type
          Row(
            children: [
              Icon(
                _getGoalIcon(),
                color: ProfileTheme.accentCyan,
                size: ProfileTheme.sectionIconSize,
              ),
              const SizedBox(width: ProfileTheme.tightSpacing),
              Text(
                'Current Goal: ${goal.goalType.displayName}',
                style: ProfileTheme.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          if (goal.programName != null) ...[
            const SizedBox(height: ProfileTheme.elementSpacing),
            Text(
              goal.programName!,
              style: ProfileTheme.caption,
            ),
          ],

          // Program progress
          if (goal.programProgressPercent != null) ...[
            const SizedBox(height: ProfileTheme.elementSpacing),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: goal.programProgressPercent! / 100,
                      backgroundColor: ProfileTheme.cardBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        ProfileTheme.accentCyan,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: ProfileTheme.tightSpacing),
                Text(
                  '${goal.programProgressPercent}%',
                  style: ProfileTheme.caption.copyWith(
                    color: ProfileTheme.accentCyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              goal.formattedProgramProgress ?? '',
              style: ProfileTheme.caption,
            ),
          ],

          const SizedBox(height: ProfileTheme.elementSpacing),
          const Divider(color: ProfileTheme.cardBorder, height: 1),
          const SizedBox(height: ProfileTheme.elementSpacing),

          // Weekly target
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.formattedWeeklyProgress,
                    style: ProfileTheme.bodyText.copyWith(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'this week',
                    style: ProfileTheme.caption,
                  ),
                ],
              ),
              // Dot indicators
              Row(
                children: List.generate(
                  goal.weeklyTarget,
                  (index) => Container(
                    margin: const EdgeInsets.only(left: 4),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < goal.weeklyCompleted
                          ? (goal.onTrackWeekly
                              ? ProfileTheme.successGreen
                              : ProfileTheme.accentCyan)
                          : ProfileTheme.cardBorder,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Edit button
          if (onEditTap != null) ...[
            const SizedBox(height: ProfileTheme.elementSpacing),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onEditTap,
                icon: const Icon(
                  Icons.edit,
                  size: 16,
                  color: ProfileTheme.accentCyan,
                ),
                label: const Text(
                  'Edit Goals',
                  style: ProfileTheme.buttonText,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
