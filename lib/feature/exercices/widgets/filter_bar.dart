import 'package:flutter/material.dart';
import 'package:gym_track/feature/exercices/theme/exercises_theme.dart';

class FilterBar extends StatelessWidget {
  final VoidCallback? onMuscleGroupTap;
  final VoidCallback? onEquipmentTap;
  final VoidCallback? onDifficultyTap;
  final bool isMuscleGroupActive;

  const FilterBar({
    super.key,
    this.onMuscleGroupTap,
    this.onEquipmentTap,
    this.onDifficultyTap,
    this.isMuscleGroupActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _BuildFilterChip(
            label: 'Muscle Group',
            isActive: isMuscleGroupActive,
            onTap: onMuscleGroupTap,
            icon: Icons.accessibility_new_rounded,
          ),
          const SizedBox(width: 12),
          _BuildFilterChip(
            label: 'Equipment',
            isActive: false, // Placeholder for future implementation
            onTap: onEquipmentTap,
            icon: Icons.fitness_center_rounded,
          ),
          const SizedBox(width: 12),
          _BuildFilterChip(
            label: 'Difficulty',
            isActive: false, // Placeholder for future implementation
            onTap: onDifficultyTap,
            icon: Icons.speed_rounded,
          ),
          const SizedBox(width: 12),
          _BuildFilterChip(
            label: 'Movement',
            isActive: false, // Placeholder for future implementation
            onTap: () {},
            icon: Icons.compare_arrows_rounded,
          ),
        ],
      ),
    );
  }
}

class _BuildFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  final IconData? icon;

  const _BuildFilterChip({
    required this.label,
    required this.isActive,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? null : ExercisesTheme.surfaceHighlight,
          gradient: isActive ? ExercisesTheme.activeChipGradient : null,
          borderRadius: BorderRadius.circular(ExercisesTheme.chipRadius),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : ExercisesTheme.secondary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : ExercisesTheme.textSecondary,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : ExercisesTheme.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              )
            ] else
              const Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: ExercisesTheme.textSecondary,
              )
          ],
        ),
      ),
    );
  }
}
