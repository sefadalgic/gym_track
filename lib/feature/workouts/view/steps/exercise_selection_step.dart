import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_track/core/cache/services/exercise_cache_service.dart';
import 'package:gym_track/core/constants/enums/days.dart';
import 'package:gym_track/feature/workouts/state/create_workout_bloc.dart';
import 'package:gym_track/feature/workouts/state/create_workout_event.dart';
import 'package:gym_track/feature/workouts/state/create_workout_state.dart';
import 'package:gym_track/product/model/exercise_model.dart';
import 'package:gym_track/product/model/workout_exercise_model.dart';

/// Step 3: Exercise selection from cache
class ExerciseSelectionStep extends StatefulWidget {
  const ExerciseSelectionStep({super.key});

  @override
  State<ExerciseSelectionStep> createState() => _ExerciseSelectionStepState();
}

class _ExerciseSelectionStepState extends State<ExerciseSelectionStep>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<ExerciseModel> _allExercises = [];
  List<ExerciseModel> _filteredExercises = [];

  // Dark theme colors
  static const Color background = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF151A21);
  static const Color surfaceHighlight = Color(0xFF1E252E);
  static const Color primary = Color(0xFF00D9FF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8F98);

  @override
  void initState() {
    super.initState();
    _loadExercises();
    final state = context.read<CreateWorkoutBloc>().state;
    _tabController = TabController(
      length: state.selectedDays.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadExercises() {
    final cached = ExerciseCacheService.instance.getCachedExercises();
    if (cached != null) {
      setState(() {
        _allExercises = cached;
        _filteredExercises = cached;
      });
    }
  }

  void _filterExercises(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredExercises = _allExercises;
      } else {
        _filteredExercises = _allExercises
            .where((exercise) =>
                exercise.name?.toLowerCase().contains(query.toLowerCase()) ??
                false)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateWorkoutBloc, CreateWorkoutState>(
      builder: (context, state) {
        if (state.selectedDays.isEmpty) {
          return const Center(
            child: Text('Lütfen önce gün seçin'),
          );
        }

        final sortedDays = state.selectedDays.toList()
          ..sort((a, b) => a.index.compareTo(b.index));

        return Container(
          color: background,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Egzersiz Seçin',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Egzersiz ara...',
                        hintStyle: TextStyle(
                          color: textSecondary.withValues(alpha: 0.5),
                        ),
                        prefixIcon: const Icon(Icons.search, color: primary),
                        filled: true,
                        fillColor: surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: _filterExercises,
                    ),
                  ],
                ),
              ),

              // Tab Bar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: primary,
                labelColor: primary,
                unselectedLabelColor: textSecondary,
                tabs: sortedDays.map((day) {
                  final exerciseCount = state.getExercisesForDay(day).length;
                  return Tab(
                    child: Row(
                      children: [
                        Text(_getDayName(day)),
                        if (exerciseCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$exerciseCount',
                              style: const TextStyle(
                                color: background,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),

              // Exercise List
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: sortedDays.map((day) {
                    return _buildExerciseList(day, state);
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExerciseList(Days day, CreateWorkoutState state) {
    final addedExerciseIds =
        state.getExercisesForDay(day).map((e) => e.exerciseId).toSet();

    if (_filteredExercises.isEmpty) {
      return const Center(
        child: Text(
          'Cache\'te egzersiz bulunamadı',
          style: TextStyle(color: textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = _filteredExercises[index];
        final isAdded = addedExerciseIds.contains(exercise.id);

        return _ExerciseListItem(
          exercise: exercise,
          isAdded: isAdded,
          onTap: () {
            if (!isAdded) {
              context.read<CreateWorkoutBloc>().add(
                    ExerciseAddedToDay(
                      day: day,
                      exercise: WorkoutExerciseModel(
                        exerciseId: exercise.id,
                        name: exercise.name,
                        sets: 3,
                        reps: 10,
                      ),
                    ),
                  );
            } else {
              context.read<CreateWorkoutBloc>().add(
                    ExerciseRemovedFromDay(
                      day: day,
                      exerciseId: exercise.id!,
                    ),
                  );
            }
          },
        );
      },
    );
  }

  String _getDayName(Days day) {
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
}

class _ExerciseListItem extends StatelessWidget {
  final ExerciseModel exercise;
  final bool isAdded;
  final VoidCallback onTap;

  const _ExerciseListItem({
    required this.exercise,
    required this.isAdded,
    required this.onTap,
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF151A21), Color(0xFF12161C)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAdded ? primary : surfaceHighlight,
          width: isAdded ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Exercise Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Exercise Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      if (exercise.primaryMuscles != null &&
                          exercise.primaryMuscles!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          exercise.primaryMuscles!.first.name,
                          style: const TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Add/Remove Button
                Icon(
                  isAdded ? Icons.check_circle : Icons.add_circle_outline,
                  color: isAdded ? primary : textSecondary,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
