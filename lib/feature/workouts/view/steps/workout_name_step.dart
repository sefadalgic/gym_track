import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_track/feature/workouts/state/create_workout_bloc.dart';
import 'package:gym_track/feature/workouts/state/create_workout_event.dart';
import 'package:gym_track/feature/workouts/state/create_workout_state.dart';

/// Step 1: Workout name input
class WorkoutNameStep extends StatefulWidget {
  const WorkoutNameStep({super.key});

  @override
  State<WorkoutNameStep> createState() => _WorkoutNameStepState();
}

class _WorkoutNameStepState extends State<WorkoutNameStep> {
  final TextEditingController _controller = TextEditingController();

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
    final state = context.read<CreateWorkoutBloc>().state;
    _controller.text = state.workoutName;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                  Icons.edit_note_rounded,
                  size: 40,
                  color: background,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Plan Adını Girin',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              const Text(
                'Antrenman planınıza kolay hatırlayabileceğiniz bir isim verin',
                style: TextStyle(
                  fontSize: 15,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Text Field
              TextField(
                controller: _controller,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  hintText: 'örn: Kuvvet Antrenmanı',
                  hintStyle: TextStyle(
                    color: textSecondary.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: surfaceHighlight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: surfaceHighlight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
                onChanged: (value) {
                  context
                      .read<CreateWorkoutBloc>()
                      .add(WorkoutNameChanged(value));
                },
              ),
              const SizedBox(height: 16),

              // Character count
              Text(
                '${_controller.text.length}/50 karakter',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
