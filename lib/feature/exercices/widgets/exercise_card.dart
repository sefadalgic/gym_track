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
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ExercisesTheme.cardRadius),
            gradient: ExercisesTheme.cardGradient,
            boxShadow: _isPressed ? [] : ExercisesTheme.cardShadow,
            border: Border.all(
              color: ExercisesTheme.surfaceHighlight,
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
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Illustration / Icon Placeholder
                    _buildIcon(context),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.exercise.name ?? 'Unknown Exercise',
                                  style: ExercisesTheme.cardTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _buildDifficultyBadge(),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getMuscleInfo(),
                            style: ExercisesTheme.cardSubtitle,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (widget.exercise.equipment != null)
                                _buildTag(
                                  widget.exercise.equipment!.toUpperCase(),
                                  ExercisesTheme.surfaceHighlight,
                                  ExercisesTheme.textSecondary,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: ExercisesTheme.secondary.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: ExercisesTheme.surfaceHighlight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.fitness_center_rounded,
          color: ExercisesTheme.primary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge() {
    Color color = ExercisesTheme.intermediate;
    String text = 'INT';

    final level = widget.exercise.level?.toLowerCase() ?? '';
    if (level.contains('beginner')) {
      color = ExercisesTheme.beginner;
      text = 'BEG';
    } else if (level.contains('advanced')) {
      color = ExercisesTheme.advanced;
      text = 'ADV';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getMuscleInfo() {
    if (widget.exercise.primaryMuscles == null ||
        widget.exercise.primaryMuscles!.isEmpty) {
      return 'General';
    }
    return widget.exercise.primaryMuscles!.map((m) => m.displayName).join(', ');
  }
}
