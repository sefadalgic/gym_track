import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_track/core/base/base_view.dart';
import 'package:gym_track/feature/exercices/state/exercises_bloc.dart';
import 'package:gym_track/feature/exercices/state/exercises_event.dart';
import 'package:gym_track/feature/exercices/state/exercises_state.dart';
import 'package:gym_track/feature/exercices/theme/exercises_theme.dart';
import 'package:gym_track/feature/exercices/widgets/exercise_card.dart';
import 'package:gym_track/feature/exercices/widgets/filter_bar.dart';
import 'package:gym_track/feature/exercices/view/exercise_detail_view.dart';
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
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        slivers: [
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _buildSearchBar(),
            ),
          ),

          // Filter Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: FilterBar(
                isMuscleGroupActive: state.selectedMuscleGroup != null,
                onMuscleGroupTap: () => _showMuscleGroupFilter(context, state),
              ),
            ),
          ),

          // Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular Exercises',
                    style: ExercisesTheme.sectionTitle,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        color: ExercisesTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Exercise List
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ExerciseDetailView(exercise: exercise),
                        ),
                      );
                    },
                  );
                },
                childCount: state.filteredExercises.length,
              ),
            ),

          // Bottom Spacer
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
      ),
      title: const Text('Exercise Library', style: ExercisesTheme.title),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            decoration: BoxDecoration(
              color: ExercisesTheme.surface,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon:
                  const Icon(Icons.tune_rounded, color: ExercisesTheme.primary),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: ExercisesTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ExercisesTheme.surfaceHighlight.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search for exercises, muscles...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withValues(alpha: 0.5),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
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
