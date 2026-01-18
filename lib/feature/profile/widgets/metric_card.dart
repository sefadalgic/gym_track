import 'package:flutter/material.dart';
import 'package:gym_track/feature/profile/theme/profile_theme.dart';

/// Reusable metric card for displaying progress statistics
class MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor = ProfileTheme.accentCyan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: ProfileTheme.metricIconSize,
              color: iconColor,
            ),
            const SizedBox(height: ProfileTheme.tightSpacing),
            Text(
              value,
              style: ProfileTheme.metricValue,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: ProfileTheme.metricLabel,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
