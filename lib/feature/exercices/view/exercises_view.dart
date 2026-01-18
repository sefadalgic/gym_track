import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_track/core/base/base_view.dart';
import 'package:gym_track/feature/exercices/state/exercises_bloc.dart';
import 'package:gym_track/feature/exercices/state/exercises_event.dart';
import 'package:gym_track/feature/exercices/state/exercises_state.dart';
import 'package:gym_track/feature/exercices/theme/exercises_theme.dart';
import 'package:gym_track/feature/exercices/widgets/exercise_card.dart';
import 'package:gym_track/feature/exercices/widgets/filter_bar.dart';
import 'package:gym_track/product/model/muscle_group.dart';
 
/// View for displaying list of exercises with premium design
class ExercisesView extends BaseView<ExercisesBloc, ExercisesState> {
  const ExercisesView({super.key});

  @override
  ExercisesBloc createBloc(BuildContext context) {
    final bloc = ExercisesBloc();
    bloc.add(const ExercisesLoadRequested());
    return bloc;
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, ExercisesState state) {
    return null; // Using SliverAppBar inside CustomScrollView
  }

  @override
  bool isLoading(ExercisesState state) => state.isLoading;

  @override
  String? getErrorMessage(ExercisesState state) => state.error;

  @override
  Widget buildView(BuildContext context, ExercisesState state) {
    return Scaffold(
      backgroundColor: ExercisesTheme.background,
      body: CustomScrollView(
        slivers: [
          // Sticky Top Bar
          SliverAppBar(
            backgroundColor: ExercisesTheme.background.withValues(alpha: 0.95),
            title: const Text('Exercise Library', style: ExercisesTheme.title),
            centerTitle: false,
            pinned: true,
            elevation: 0,
            floating: true,
            snap: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: ExercisesTheme.primary),
                onPressed: () {
                  context
                      .read<ExercisesBloc>()
                      .add(const ExercisesRefreshRequested());
                },
              ),
            ],
          ),

          // Search Input
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search exercises...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  filled: true,
                  fillColor: ExercisesTheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                ),
                onChanged: (value) {
                  // TODO: Implement search in Bloc
                },
              ),
            ),
          ),

          // Filter Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FilterBar(
                isMuscleGroupActive: state.selectedMuscleGroup != null,
                onMuscleGroupTap: () => _showMuscleGroupFilter(context, state),
                onEquipmentTap: () {
                  // TODO: Implement equipment filter
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Equipment filter check')),
                  );
                },
                onDifficultyTap: () {
                  // TODO: Implement difficulty filter
                },
              ),
            ),
          ),

          // Content
          if (state.isEmpty || (state.isFilteredEmpty && !state.isLoading))
            SliverFillRemaining(
              child: _buildEmptyState(context, state.isFilteredEmpty),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final exercise = state.filteredExercises[index];
                  return ExerciseCard(
                    exercise: exercise,
                    onTap: () {
                      context.read<ExercisesBloc>().add(
                            ExerciseSelected(exercise.id!),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Selected: ${exercise.name}'),
                          duration: const Duration(milliseconds: 600),
                          backgroundColor: ExercisesTheme.surfaceHighlight,
                        ),
                      );
                    },
                  );
                },
                childCount: state.filteredExercises.length,
              ),
            ),

          // Bottom padding for scroll
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Future<void> _showMuscleGroupFilter(
      BuildContext context, ExercisesState state) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: ExercisesTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text('Select Muscle Group',
                    style: ExercisesTheme.cardTitle),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: const Text('All Muscles',
                          style: TextStyle(color: Colors.white)),
                      leading:
                          const Icon(Icons.apps, color: ExercisesTheme.primary),
                      selected: state.selectedMuscleGroup == null,
                      onTap: () {
                        context
                            .read<ExercisesBloc>()
                            .add(const ExercisesFilterChanged(null));
                        Navigator.pop(bottomSheetContext);
                      },
                    ),
                    const Divider(color: ExercisesTheme.surfaceHighlight),
                    ...MuscleGroup.values.map((muscle) {
                      final isSelected = state.selectedMuscleGroup == muscle;
                      return ListTile(
                        title: Text(muscle.displayName,
                            style: TextStyle(
                              color: isSelected
                                  ? ExercisesTheme.primary
                                  : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            )),
                        trailing: isSelected
                            ? const Icon(Icons.check,
                                color: ExercisesTheme.primary)
                            : null,
                        onTap: () {
                          context
                              .read<ExercisesBloc>()
                              .add(ExercisesFilterChanged(muscle));
                          Navigator.pop(bottomSheetContext);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isFiltered) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered ? Icons.search_off : Icons.fitness_center,
            size: 64,
            color: ExercisesTheme.secondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'No exercises found' : 'No exercises available',
            style: ExercisesTheme.cardTitle.copyWith(
              color: ExercisesTheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered ? 'Try adjusting your filters' : 'Pull to refresh',
            style: ExercisesTheme.caption,
          ),
        ],
      ),
    );
  }
}
