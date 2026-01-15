import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_track/core/base/base_view.dart';
import 'package:gym_track/feature/exercices/state/exercises_bloc.dart';
import 'package:gym_track/feature/exercices/state/exercises_event.dart';
import 'package:gym_track/feature/exercices/state/exercises_state.dart';
import 'package:gym_track/feature/exercices/widgets/exercise_list_item.dart';
import 'package:gym_track/product/model/muscle_group.dart';

/// View for displaying list of exercises
class ExercisesView extends BaseView<ExercisesBloc, ExercisesState> {
  const ExercisesView({super.key});

  @override
  ExercisesBloc createBloc(BuildContext context) {
    final bloc = ExercisesBloc();
    // Load exercises when view is created
    bloc.add(const ExercisesLoadRequested());
    return bloc;
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, ExercisesState state) {
    return AppBar(
      title: const Text('Exercises'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context
                .read<ExercisesBloc>()
                .add(const ExercisesRefreshRequested());
          },
        ),
      ],
    );
  }

  @override
  bool isLoading(ExercisesState state) => state.isLoading;

  @override
  String? getErrorMessage(ExercisesState state) => state.error;

  @override
  Widget buildView(BuildContext context, ExercisesState state) {
    return Column(
      children: [
        // Filter chips
        _buildFilterChips(context, state),
        // Exercises list
        Expanded(
          child: state.isEmpty
              ? _buildEmptyState(context)
              : state.isFilteredEmpty
                  ? _buildNoResultsState(context)
                  : _buildExercisesList(context, state),
        ),
      ],
    );
  }

  /// Build filter chips for muscle groups
  Widget _buildFilterChips(BuildContext context, ExercisesState state) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // All filter
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: state.selectedMuscleGroup == null,
              onSelected: (selected) {
                if (selected) {
                  context
                      .read<ExercisesBloc>()
                      .add(const ExercisesFilterChanged(null));
                }
              },
            ),
          ),
          // Muscle group filters
          ...MuscleGroup.values.map((muscleGroup) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(muscleGroup.displayName),
                selected: state.selectedMuscleGroup == muscleGroup,
                onSelected: (selected) {
                  context.read<ExercisesBloc>().add(
                      ExercisesFilterChanged(selected ? muscleGroup : null));
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Build exercises list
  Widget _buildExercisesList(BuildContext context, ExercisesState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ExercisesBloc>().add(const ExercisesRefreshRequested());
        // Wait a bit for the refresh to complete
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        itemCount: state.filteredExercises.length,
        itemBuilder: (context, index) {
          final exercise = state.filteredExercises[index];
          return ExerciseListItem(
            exercise: exercise,
            onTap: () {
              context.read<ExercisesBloc>().add(ExerciseSelected(exercise.id!));
              // TODO: Navigate to exercise detail page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected: ${exercise.name}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Build empty state when no exercises
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises available',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  /// Build no results state when filter returns empty
  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different filter',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }
}
