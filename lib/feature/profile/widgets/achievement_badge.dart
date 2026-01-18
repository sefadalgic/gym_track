import 'package:flutter/material.dart';
import 'package:gym_track/core/models/achievement_model.dart';
import 'package:gym_track/feature/profile/theme/profile_theme.dart';

/// Achievement badge widget with locked/unlocked states
class AchievementBadge extends StatelessWidget {
  final AchievementModel achievement;
  final VoidCallback? onTap;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.onTap,
  });

  List<Color> _getGradientColors() {
    if (!achievement.unlocked) {
      return [Colors.grey.shade700, Colors.grey.shade800];
    }

    switch (achievement.tier) {
      case BadgeTier.bronze:
        return ProfileTheme.bronzeGradient;
      case BadgeTier.silver:
        return ProfileTheme.silverGradient;
      case BadgeTier.gold:
        return ProfileTheme.goldGradient;
    }
  }

  IconData _getIcon() {
    switch (achievement.iconName) {
      case 'fire':
        return Icons.local_fire_department;
      case 'trophy':
        return Icons.emoji_events;
      case 'lightning':
        return Icons.bolt;
      case 'dumbbell':
        return Icons.fitness_center;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getGradientColors(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: achievement.unlocked
                  ? [
                      BoxShadow(
                        color: _getGradientColors()[0].withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              _getIcon(),
              size: ProfileTheme.badgeIconSize,
              color: achievement.unlocked
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: ProfileTheme.tightSpacing),
          SizedBox(
            width: 80,
            child: Text(
              achievement.name,
              style: ProfileTheme.caption.copyWith(
                color: achievement.unlocked
                    ? ProfileTheme.secondaryText
                    : ProfileTheme.secondaryText.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
