import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_track/core/constants/enums/days.dart';
import 'package:gym_track/feature/workouts/state/create_workout_bloc.dart';
import 'package:gym_track/feature/workouts/state/create_workout_event.dart';
import 'package:gym_track/feature/workouts/state/create_workout_state.dart';
import 'package:gym_track/product/model/workout_exercise_model.dart';

/// Step 4: Sets and reps configuration
class SetsRepsConfigurationStep extends StatelessWidget {
  const SetsRepsConfigurationStep({super.key});

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Set ve Tekrar Ayarla',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toplam ${state.totalExercises} egzersiz',
                      style: const TextStyle(
                        fontSize: 15,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Exercise List by Day
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: sortedDays.length,
                  itemBuilder: (context, index) {
                    final day = sortedDays[index];
                    final exercises = state.getExercisesForDay(day);

                    return _DayExercisesSection(
                      day: day,
                      exercises: exercises,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DayExercisesSection extends StatelessWidget {
  final Days day;
  final List<WorkoutExerciseModel> exercises;

  const _DayExercisesSection({
    required this.day,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day Header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${exercises.length} egzersiz',
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // Exercises
        ...exercises.map((exercise) {
          return _ExerciseConfigCard(
            day: day,
            exercise: exercise,
          );
        }),

        const SizedBox(height: 24),
      ],
    );
  }
}

class _ExerciseConfigCard extends StatelessWidget {
  final Days day;
  final WorkoutExerciseModel exercise;

  const _ExerciseConfigCard({
    required this.day,
    required this.exercise,
  });

  static const Color surface = Color(0xFF151A21);
  static const Color surfaceHighlight = Color(0xFF1E252E);
  static const Color primary = Color(0xFF00D9FF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8F98);

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
          // Exercise Name and Remove Button
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.name ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  context.read<CreateWorkoutBloc>().add(
                        ExerciseRemovedFromDay(
                          day: day,
                          exerciseId: exercise.exerciseId!,
                        ),
                      );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sets and Reps Controls
          Row(
            children: [
              // Sets
              Expanded(
                child: _NumberPicker(
                  label: 'Set',
                  value: exercise.sets ?? 3,
                  onChanged: (value) {
                    context.read<CreateWorkoutBloc>().add(
                          ExerciseSetsChanged(
                            day: day,
                            exerciseId: exercise.exerciseId!,
                            sets: value,
                          ),
                        );
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Reps
              Expanded(
                child: _NumberPicker(
                  label: 'Tekrar',
                  value: exercise.reps ?? 10,
                  onChanged: (value) {
                    context.read<CreateWorkoutBloc>().add(
                          ExerciseRepsChanged(
                            day: day,
                            exerciseId: exercise.exerciseId!,
                            reps: value,
                          ),
                        );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberPicker extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _NumberPicker({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  static const Color surface = Color(0xFF151A21);
  static const Color surfaceHighlight = Color(0xFF1E252E);
  static const Color primary = Color(0xFF00D9FF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8F98);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: surfaceHighlight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Decrease Button
              IconButton(
                icon: const Icon(Icons.remove, color: primary),
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
              ),

              // Value
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),

              // Increase Button
              IconButton(
                icon: const Icon(Icons.add, color: primary),
                onPressed: value < 99 ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
