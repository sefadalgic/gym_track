import 'package:flutter/material.dart';
import 'package:gym_track/feature/exercices/theme/exercises_theme.dart';
import 'package:gym_track/product/model/exercise_model.dart';

class ExerciseCard extends StatefulWidget {
  final ExerciseModel exercise;
  final VoidCallback? onTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: ExercisesTheme.surface,
            borderRadius: BorderRadius.circular(ExercisesTheme.cardRadius),
            boxShadow: _isPressed ? [] : ExercisesTheme.cardShadow,
            border: Border.all(
              color: ExercisesTheme.surfaceHighlight.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              borderRadius: BorderRadius.circular(ExercisesTheme.cardRadius),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Exercise Image
                    _buildImage(),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.exercise.name ?? 'Unknown',
                                  style: ExercisesTheme.cardTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildDifficultyBadge(),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_getMuscleInfo()} • ${widget.exercise.category ?? 'Exercise'}',
                            style: ExercisesTheme.cardSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.fitness_center_rounded,
                                size: 14,
                                color: ExercisesTheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.exercise.equipment ?? 'Bodyweight',
                                style: ExercisesTheme.caption,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Add Button
                    _buildAddButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: ExercisesTheme.background,
        borderRadius: BorderRadius.circular(ExercisesTheme.imageRadius),
        image: const DecorationImage(
          image: NetworkImage(
              'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=200&h=200&fit=crop'), // Placeholder image
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge() {
    Color color = ExercisesTheme.intermediate;
    String text = 'Intermediate';

    final level = widget.exercise.level?.toLowerCase() ?? '';
    if (level.contains('beginner')) {
      color = ExercisesTheme.beginner;
      text = 'Beginner';
    } else if (level.contains('advanced')) {
      color = ExercisesTheme.advanced;
      text = 'Advanced';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: ExercisesTheme.surfaceHighlight.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  String _getMuscleInfo() {
    if (widget.exercise.primaryMuscles == null ||
        widget.exercise.primaryMuscles!.isEmpty) {
      return 'General';
    }
    return widget.exercise.primaryMuscles!.first.displayName;
  }
}
