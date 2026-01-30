import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_track/core/constants/enums/days.dart';
import 'package:gym_track/feature/workouts/state/create_workout_bloc.dart';
import 'package:gym_track/feature/workouts/state/create_workout_event.dart';
import 'package:gym_track/feature/workouts/state/create_workout_state.dart';

/// Step 2: Day selection
class DaySelectionStep extends StatelessWidget {
  const DaySelectionStep({super.key});

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
        return Container(
          color: background,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(20),
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
                  Icons.calendar_today_rounded,
                  size: 40,
                  color: background,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Antrenman Günlerini Seçin',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Haftada ${state.selectedDays.length} gün seçildi',
                style: const TextStyle(
                  fontSize: 15,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Days Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: Days.values.length,
                  itemBuilder: (context, index) {
                    final day = Days.values[index];
                    final isSelected = state.selectedDays.contains(day);

                    return _DayCard(
                      day: day,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<CreateWorkoutBloc>().add(DayToggled(day));
                      },
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

class _DayCard extends StatelessWidget {
  final Days day;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayCard({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  static const Color surface = Color(0xFF151A21);
  static const Color surfaceHighlight = Color(0xFF1E252E);
  static const Color primary = Color(0xFF00D9FF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8F98);
  static const Color background = Color(0xFF0A0E14);

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

  String get _dayShort {
    switch (day) {
      case Days.monday:
        return 'Pzt';
      case Days.tuesday:
        return 'Sal';
      case Days.wednesday:
        return 'Çar';
      case Days.thursday:
        return 'Per';
      case Days.friday:
        return 'Cum';
      case Days.saturday:
        return 'Cmt';
      case Days.sunday:
        return 'Paz';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF00D9FF), Color(0xFF00B8D4)],
                  )
                : const LinearGradient(
                    colors: [Color(0xFF151A21), Color(0xFF12161C)],
                  ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? primary : surfaceHighlight,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _dayShort,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? background : textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _dayName,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected
                      ? background.withValues(alpha: 0.8)
                      : textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
