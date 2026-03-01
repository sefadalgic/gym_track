import 'package:flutter/material.dart';
import 'package:gym_track/core/cache/services/exercise_cache_service.dart';
import 'package:gym_track/core/thene/app_theme.dart';
import 'package:gym_track/product/model/exercise_model.dart';
import 'package:gym_track/product/model/workout_session_exercise_model.dart';

class HomeExerciseSelectionScreen extends StatefulWidget {
  const HomeExerciseSelectionScreen({super.key});

  @override
  State<HomeExerciseSelectionScreen> createState() =>
      _HomeExerciseSelectionScreenState();
}

class _HomeExerciseSelectionScreenState
    extends State<HomeExerciseSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ExerciseModel> _allExercises = [];
  List<ExerciseModel> _filteredExercises = [];
  final Set<ExerciseModel> _selectedExercises = {};

  // Colors matching HomeView
  static const Color background = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF151A21);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8F98);

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
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
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        title: const Text(
          'Select Exercises',
          style: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selectedExercises.isNotEmpty)
            TextButton(
              onPressed: () {
                final sessionExercises = _selectedExercises.map((e) {
                  return WorkoutSessionExerciseModel(
                    exerciseId: e.id ?? '',
                    exerciseName: e.name ?? 'Unknown',
                    plannedSets: 3,
                    plannedReps: 10,
                  );
                }).toList();
                Navigator.pop(context, sessionExercises);
              },
              child: Text(
                'Done (${_selectedExercises.length})',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                hintStyle: TextStyle(
                  color: textSecondary.withValues(alpha: 0.5),
                ),
                prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
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
          ),

          // Exercise List
          Expanded(
            child: _filteredExercises.isEmpty
                ? const Center(
                    child: Text(
                      'No exercises found',
                      style: TextStyle(color: textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      final isSelected = _selectedExercises.contains(exercise);

                      return _ExerciseListItem(
                        exercise: exercise,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedExercises.remove(exercise);
                            } else {
                              _selectedExercises.add(exercise);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseListItem extends StatelessWidget {
  final ExerciseModel exercise;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExerciseListItem({
    required this.exercise,
    required this.isSelected,
    required this.onTap,
  });

  static const Color surface = Color(0xFF151A21);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8F98);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primary : surface,
          width: isSelected ? 2 : 1,
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
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
                Icon(
                  isSelected ? Icons.check_circle : Icons.add_circle_outline,
                  color: isSelected ? AppTheme.primary : textSecondary,
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
