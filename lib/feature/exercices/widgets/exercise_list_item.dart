import 'package:flutter/material.dart';
import 'package:gym_track/product/model/exercise_model.dart';

/// Widget for displaying an exercise in a list
class ExerciseListItem extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback? onTap;

  const ExerciseListItem({
    super.key,
    required this.exercise,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise icon/image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getMuscleGroupColor(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getEquipmentIcon(),
                  size: 32,
                  color: _getMuscleGroupColor(context),
                ),
              ),
              const SizedBox(width: 16),
              // Exercise details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise name
                    Text(
                      exercise.name!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    // Description
                    if (exercise.description != null)
                      Text(
                        exercise.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    // Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (exercise.primaryMuscles != null &&
                            exercise.primaryMuscles!.isNotEmpty)
                          _buildTag(
                            context,
                            exercise.primaryMuscles!.first.displayName,
                            _getMuscleGroupColor(context),
                          ),
                        if (exercise.equipment != null)
                          _buildTag(
                            context,
                            exercise.equipment!,
                            Colors.blue,
                          ),
                        if (exercise.level != null)
                          _buildTag(
                            context,
                            exercise.level!,
                            _getDifficultyColor(),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow icon
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a tag widget
  Widget _buildTag(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Get color based on muscle group
  Color _getMuscleGroupColor(BuildContext context) {
    if (exercise.primaryMuscles == null || exercise.primaryMuscles!.isEmpty) {
      return Colors.grey;
    }

    switch (exercise.primaryMuscles!.first.name) {
      case 'chest':
        return Colors.red;
      case 'back':
      case 'lats':
        return Colors.blue;
      case 'legs':
      case 'quadriceps':
      case 'hamstrings':
      case 'calves':
        return Colors.green;
      case 'shoulders':
        return Colors.orange;
      case 'biceps':
      case 'triceps':
      case 'forearms':
        return Colors.purple;
      case 'abs':
      case 'core':
        return Colors.teal;
      case 'glutes':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  /// Get icon based on equipment type
  IconData _getEquipmentIcon() {
    if (exercise.equipment == null) return Icons.fitness_center;

    switch (exercise.equipment!) {
      case 'barbell':
        return Icons.fitness_center;
      case 'dumbbell':
        return Icons.fitness_center;
      case 'machine':
        return Icons.settings;
      case 'bodyweight':
        return Icons.accessibility_new;
      case 'cable':
        return Icons.cable;
      case 'kettlebell':
        return Icons.sports_martial_arts;
      default:
        return Icons.fitness_center;
    }
  }

  /// Get color based on difficulty
  Color _getDifficultyColor() {
    if (exercise.level == null) return Colors.grey;

    final difficulty = exercise.level!.toLowerCase();
    if (difficulty.contains('beginner') || difficulty.contains('easy')) {
      return Colors.green;
    } else if (difficulty.contains('intermediate') ||
        difficulty.contains('medium')) {
      return Colors.orange;
    } else if (difficulty.contains('advanced') || difficulty.contains('hard')) {
      return Colors.red;
    }
    return Colors.grey;
  }
}
