import 'package:flutter/material.dart';
import 'package:gym_track/core/models/workout_summary_model.dart';
import 'package:gym_track/feature/profile/theme/profile_theme.dart';

/// List item for recent workout history
class WorkoutHistoryItem extends StatelessWidget {
  final WorkoutSummaryModel workout;
  final VoidCallback? onTap;

  const WorkoutHistoryItem({
    super.key,
    required this.workout,
    this.onTap,
  });

  Widget _buildStatusIcon() {
    switch (workout.status) {
      case WorkoutStatus.completed:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ProfileTheme.successGreen.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: ProfileTheme.successGreen,
            size: 24,
          ),
        );
      case WorkoutStatus.skipped:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ProfileTheme.secondaryText.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close,
            color: ProfileTheme.secondaryText.withOpacity(0.6),
            size: 24,
          ),
        );
      case WorkoutStatus.inProgress:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ProfileTheme.warningAmber.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow,
            color: ProfileTheme.warningAmber,
            size: 24,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ProfileTheme.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(ProfileTheme.elementSpacing),
        margin: const EdgeInsets.only(bottom: ProfileTheme.tightSpacing),
        decoration: BoxDecoration(
          color: ProfileTheme.cardBackground,
          borderRadius: BorderRadius.circular(ProfileTheme.cardRadius),
          border: Border.all(
            color: ProfileTheme.cardBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildStatusIcon(),
            const SizedBox(width: ProfileTheme.elementSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: ProfileTheme.bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    workout.subtitle,
                    style: ProfileTheme.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (workout.notes != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      workout.notes!,
                      style: ProfileTheme.caption.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: ProfileTheme.secondaryText.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }
}
