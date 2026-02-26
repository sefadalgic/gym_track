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
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _BuildFilterChip(
            label: 'All',
            isActive: !isMuscleGroupActive,
            onTap: () {
              // Reset filter logic would be here
            },
          ),
          const SizedBox(width: 12),
          _BuildFilterChip(
            label: 'Chest',
            isActive: isMuscleGroupActive,
            onTap: onMuscleGroupTap,
            hasDropdown: true,
          ),
          const SizedBox(width: 12),
          _BuildFilterChip(
            label: 'Equipment',
            isActive: false,
            onTap: onEquipmentTap,
            hasDropdown: true,
          ),
          const SizedBox(width: 12),
          _BuildFilterChip(
            label: 'Difficulty',
            isActive: false,
            onTap: onDifficultyTap,
            hasDropdown: true,
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
  final bool hasDropdown;

  const _BuildFilterChip({
    required this.label,
    required this.isActive,
    this.onTap,
    this.hasDropdown = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? ExercisesTheme.primary : ExercisesTheme.surface,
          borderRadius: BorderRadius.circular(ExercisesTheme.chipRadius),
          boxShadow: isActive ? ExercisesTheme.glowShadow : null,
          border: isActive
              ? null
              : Border.all(
                  color: ExercisesTheme.surfaceHighlight,
                  width: 1,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: ExercisesTheme.chipLabel.copyWith(
                color: isActive ? Colors.white : ExercisesTheme.textPrimary,
              ),
            ),
            if (hasDropdown) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: isActive ? Colors.white : ExercisesTheme.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
