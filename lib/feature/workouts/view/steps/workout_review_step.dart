import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_track/core/constants/enums/days.dart';
import 'package:gym_track/feature/workouts/state/create_workout_bloc.dart';
import 'package:gym_track/feature/workouts/state/create_workout_state.dart';

/// Step 5: Review and save workout
class WorkoutReviewStep extends StatelessWidget {
  const WorkoutReviewStep({super.key});

  // Dark theme colors
  static const Color background = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF151A21);
  static const Color surfaceHighlight = Color(0xFF1E252E);
  static const Color primary = Color(0xFF00D9FF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8F98);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateWorkoutBloc, CreateWorkoutState>(
      builder: (context, state) {
        final sortedDays = state.selectedDays.toList()
          ..sort((a, b) => a.index.compareTo(b.index));

        return Container(
          color: background,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Success Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00D9FF), Color(0xFF00B8D4)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: background,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Center(
                child: Text(
                  'Plan Hazır!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Center(
                child: Text(
                  'Planınızı gözden geçirin ve kaydedin',
                  style: TextStyle(
                    fontSize: 15,
                    color: textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Workout Name Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF151A21), Color(0xFF12161C)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: surfaceHighlight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Plan Adı',
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.workoutName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.calendar_today,
                      label: 'Gün',
                      value: '${state.selectedDays.length}',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.fitness_center,
                      label: 'Egzersiz',
                      value: '${state.totalExercises}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Day by Day Breakdown
              const Text(
                'Günlük Detaylar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              ...sortedDays.map((day) {
                final exercises = state.getExercisesForDay(day);
                return _DayReviewCard(
                  day: day,
                  exerciseCount: exercises.length,
                  exercises: exercises,
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  static const Color surface = Color(0xFF151A21);
  static const Color surfaceHighlight = Color(0xFF1E252E);
  static const Color primary = Color(0xFF00D9FF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8F98);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF151A21), Color(0xFF12161C)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: surfaceHighlight),
      ),
      child: Column(
        children: [
          Icon(icon, color: primary, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayReviewCard extends StatelessWidget {
  final Days day;
  final int exerciseCount;
  final List exercises;

  const _DayReviewCard({
    required this.day,
    required this.exerciseCount,
    required this.exercises,
  });

  static const Color surface = Color(0xFF151A21);
  static const Color surfaceHighlight = Color(0xFF1E252E);
  static const Color primary = Color(0xFF00D9FF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8F98);

  String get _dayName {
    switch (day) {
      case Days.monday:
        return 'Pazartesi';
      case Days.tuesday:
        return 'Salı';
      case Days.wednesday:
        return 'Çarşamba';
      case Days.thursday:
        return 'Perşembe';
      case Days.friday:
        return 'Cuma';
      case Days.saturday:
        return 'Cumartesi';
      case Days.sunday:
        return 'Pazar';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF151A21), Color(0xFF12161C)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: surfaceHighlight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _dayName,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$exerciseCount egzersiz',
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Exercise List
          ...exercises.map((exercise) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      exercise.name ?? 'Unknown',
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '${exercise.sets}x${exercise.reps}',
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
