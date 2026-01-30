import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_track/feature/workouts/state/create_workout_bloc.dart';
import 'package:gym_track/feature/workouts/state/create_workout_event.dart';
import 'package:gym_track/feature/workouts/state/create_workout_state.dart';
import 'package:gym_track/feature/workouts/view/steps/workout_name_step.dart';
import 'package:gym_track/feature/workouts/view/steps/day_selection_step.dart';
import 'package:gym_track/feature/workouts/view/steps/exercise_selection_step.dart';
import 'package:gym_track/feature/workouts/view/steps/sets_reps_configuration_step.dart';
import 'package:gym_track/feature/workouts/view/steps/workout_review_step.dart';

/// Main coordinator for workout creation flow
class CreateWorkoutFlow extends StatelessWidget {
  const CreateWorkoutFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateWorkoutBloc(),
      child: const _CreateWorkoutFlowContent(),
    );
  }
}

class _CreateWorkoutFlowContent extends StatefulWidget {
  const _CreateWorkoutFlowContent();

  @override
  State<_CreateWorkoutFlowContent> createState() =>
      _CreateWorkoutFlowContentState();
}

class _CreateWorkoutFlowContentState extends State<_CreateWorkoutFlowContent> {
  final PageController _pageController = PageController();

  // Dark theme colors matching exercises view
  static const Color background = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF151A21);
  static const Color primary = Color(0xFF00D9FF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8F98);

  final List<String> _stepTitles = [
    'Plan Adı',
    'Günler',
    'Egzersizler',
    'Set & Tekrar',
    'Önizleme',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateWorkoutBloc, CreateWorkoutState>(
      listener: (context, state) {
        // Navigate to correct page when step changes
        if (_pageController.hasClients &&
            _pageController.page?.round() != state.currentStep) {
          _pageController.animateToPage(
            state.currentStep,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }

        // Show error if present
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        // Navigate back on successful save
        if (state.isSaved) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Plan başarıyla oluşturuldu!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: background,
          appBar: AppBar(
            backgroundColor: surface,
            elevation: 0,
            title: Text(
              'Yeni Plan Oluştur',
              style: TextStyle(
                color: textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close, color: primary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Column(
            children: [
              // Progress Indicator
              _buildProgressIndicator(state.currentStep),

              // Page View with Steps
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    WorkoutNameStep(),
                    DaySelectionStep(),
                    ExerciseSelectionStep(),
                    SetsRepsConfigurationStep(),
                    WorkoutReviewStep(),
                  ],
                ),
              ),

              // Navigation Buttons
              _buildNavigationButtons(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: surface,
      child: Row(
        children: List.generate(_stepTitles.length, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (index > 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted
                              ? primary
                              : textSecondary.withValues(alpha: 0.3),
                        ),
                      ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted || isCurrent
                            ? primary
                            : textSecondary.withValues(alpha: 0.3),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check,
                                color: background, size: 18)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isCurrent ? background : textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                    if (index < _stepTitles.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted
                              ? primary
                              : textSecondary.withValues(alpha: 0.3),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _stepTitles[index],
                  style: TextStyle(
                    color: isCurrent ? primary : textSecondary,
                    fontSize: 11,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationButtons(
      BuildContext context, CreateWorkoutState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          if (state.currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: state.isLoading
                    ? null
                    : () => context
                        .read<CreateWorkoutBloc>()
                        .add(const PreviousStepRequested()),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Geri',
                  style: TextStyle(
                    color: primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (state.currentStep > 0) const SizedBox(width: 16),

          // Next/Save Button
          Expanded(
            flex: state.currentStep == 0 ? 1 : 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D9FF), Color(0xFF00B8D4)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: state.isLoading
                      ? null
                      : () {
                          if (state.currentStep == 4) {
                            // Last step - save
                            context
                                .read<CreateWorkoutBloc>()
                                .add(const WorkoutSaveRequested());
                          } else {
                            // Next step
                            context
                                .read<CreateWorkoutBloc>()
                                .add(const NextStepRequested());
                          }
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: state.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: background,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              state.currentStep == 4 ? 'Kaydet' : 'İleri',
                              style: const TextStyle(
                                color: background,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
