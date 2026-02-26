import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gym_track/core/thene/app_theme.dart';
import 'package:gym_track/product/model/workout_session_model.dart';
import 'package:gym_track/product/model/workout_session_exercise_model.dart';
import 'package:gym_track/product/model/exercise_set_model.dart';
import 'package:gym_track/product/service/firestore_service.dart';

/// Workout session tracking screen
class WorkoutSessionScreen extends StatefulWidget {
  final String sessionId;
  final WorkoutSessionModel session;

  const WorkoutSessionScreen({
    super.key,
    required this.sessionId,
    required this.session,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late WorkoutSessionModel _session;
  final FirestoreService _firestoreService = FirestoreService.instance;

  // Colors
  static const Color background = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF13182A);
  static const Color surfaceHighlight = Color(0xFF1E2640);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF5A6480);
  static Color get primary => AppTheme.primary;

  // Rest timer
  int _restSeconds = 0;
  Timer? _restTimer;
  bool _restActive = false;

  // Track which exercise is currently focused (for progress)
  int get _currentExerciseIndex {
    for (int i = 0; i < _session.exercises.length; i++) {
      if (!_session.exercises[i].isFullyCompleted) return i;
    }
    return _session.exercises.length - 1;
  }

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _saveToFirestore();
        return true;
      },
      child: Scaffold(
        backgroundColor: background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildSessionProgress(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: _session.exercises.length,
                itemBuilder: (context, index) =>
                    _buildExerciseSection(_session.exercises[index], index),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: textPrimary),
        onPressed: () async {
          await _saveToFirestore();
          if (mounted) Navigator.pop(context);
        },
      ),
      title: Text(
        _session.workoutName,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.history_rounded, color: textSecondary),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: textSecondary),
          onPressed: () {},
        ),
      ],
    );
  }

  // ── Session Progress ───────────────────────────────────────────────────────
  Widget _buildSessionProgress() {
    final completed =
        _session.exercises.where((e) => e.isFullyCompleted).length;
    final total = _session.exercises.length;
    final progress = total > 0 ? completed / total : 0.0;
    final currentIdx = _currentExerciseIndex + 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SESSION PROGRESS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '$currentIdx of $total exercises',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: surfaceHighlight,
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
        ],
      ),
    );
  }

  // ── Exercise Section ───────────────────────────────────────────────────────
  Widget _buildExerciseSection(
      WorkoutSessionExerciseModel exercise, int exerciseIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise name row with RPE badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  exercise.exerciseName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: primary.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'RPE ${exercise.plannedSets + 5}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Column headers
          _buildColumnHeaders(),
          const SizedBox(height: 8),
          // Sets
          ...exercise.completedSets.asMap().entries.map((entry) {
            return _buildSetRow(
                exercise, exerciseIndex, entry.value, entry.key);
          }),
          const SizedBox(height: 8),
          // Add Set button
          _buildAddSetButton(exerciseIndex),
        ],
      ),
    );
  }

  Widget _buildColumnHeaders() {
    return Row(
      children: [
        _headerCell('SET', width: 36),
        _headerCell('PREVIOUS', flex: 2),
        _headerCell('WEIGHT (KG)', flex: 2),
        _headerCell('REPS', flex: 2),
        const SizedBox(width: 36),
      ],
    );
  }

  Widget _headerCell(String label, {double? width, int flex = 1}) {
    final child = Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: textSecondary,
        letterSpacing: 0.8,
      ),
    );
    if (width != null) {
      return SizedBox(width: width, child: child);
    }
    return Expanded(flex: flex, child: child);
  }

  // ── Set Row ────────────────────────────────────────────────────────────────
  Widget _buildSetRow(
    WorkoutSessionExerciseModel exercise,
    int exerciseIndex,
    ExerciseSetModel set,
    int setIndex,
  ) {
    final weightController =
        TextEditingController(text: set.weight?.toString() ?? '');
    final repsController =
        TextEditingController(text: set.reps?.toString() ?? '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Set number
          SizedBox(
            width: 36,
            child: Text(
              '${set.setNumber}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: set.isCompleted ? textSecondary : textPrimary,
              ),
            ),
          ),
          // Previous (placeholder — italic, secondary)
          Expanded(
            flex: 2,
            child: Text(
              '${exercise.plannedSets * 10}kg×${exercise.plannedReps}',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: textSecondary,
              ),
            ),
          ),
          // Weight input
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildInput(
                controller: weightController,
                hintText: '',
                isCompleted: set.isCompleted,
                isDecimal: true,
                onChanged: (v) => _updateSet(
                  exerciseIndex,
                  setIndex,
                  weight: double.tryParse(v),
                ),
                onEditingComplete: _saveToFirestore,
              ),
            ),
          ),
          // Reps input
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildInput(
                controller: repsController,
                hintText: '',
                isCompleted: set.isCompleted,
                isDecimal: false,
                onChanged: (v) => _updateSet(
                  exerciseIndex,
                  setIndex,
                  reps: int.tryParse(v),
                ),
                onEditingComplete: _saveToFirestore,
              ),
            ),
          ),
          // Completion toggle
          GestureDetector(
            onTap: () {
              _updateSet(
                exerciseIndex,
                setIndex,
                isCompleted: !set.isCompleted,
                saveImmediately: true,
              );
              if (!set.isCompleted) _startRestTimer();
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: set.isCompleted
                    ? AppTheme.success.withValues(alpha: 0.15)
                    : Colors.transparent,
                border: Border.all(
                  color: set.isCompleted ? AppTheme.success : textSecondary,
                  width: 2,
                ),
              ),
              child: set.isCompleted
                  ? Icon(Icons.check_rounded, size: 16, color: AppTheme.success)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hintText,
    required bool isCompleted,
    required bool isDecimal,
    required ValueChanged<String> onChanged,
    required VoidCallback onEditingComplete,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: isCompleted ? textSecondary : textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.5)),
        filled: true,
        fillColor: surfaceHighlight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        isDense: true,
      ),
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
    );
  }

  Widget _buildAddSetButton(int exerciseIndex) {
    return GestureDetector(
      onTap: () => _addSet(exerciseIndex),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: textSecondary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 16, color: textSecondary),
            const SizedBox(width: 6),
            Text(
              'Add Set',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Bar ─────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      color: background,
      child: Row(
        children: [
          // Rest timer
          GestureDetector(
            onTap: _toggleRestTimer,
            child: Container(
              width: 90,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: surfaceHighlight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_rounded,
                    color: _restActive ? primary : textSecondary,
                    size: 18,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rest',
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatRestTime(),
                    style: TextStyle(
                      fontSize: 11,
                      color: _restActive ? primary : textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Complete Workout button
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _completeWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.celebration_rounded, size: 20),
                label: const Text(
                  'Complete Workout',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Rest Timer ─────────────────────────────────────────────────────────────
  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _restSeconds = 90; // default 1:30
      _restActive = true;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_restSeconds <= 0) {
        t.cancel();
        if (mounted) setState(() => _restActive = false);
      } else {
        if (mounted) setState(() => _restSeconds--);
      }
    });
  }

  void _toggleRestTimer() {
    if (_restActive) {
      _restTimer?.cancel();
      setState(() {
        _restActive = false;
        _restSeconds = 0;
      });
    } else {
      _startRestTimer();
    }
  }

  String _formatRestTime() {
    if (_restSeconds <= 0) return '01:30';
    final m = _restSeconds ~/ 60;
    final s = _restSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ── Data Methods ───────────────────────────────────────────────────────────
  void _updateSet(
    int exerciseIndex,
    int setIndex, {
    double? weight,
    int? reps,
    bool? isCompleted,
    bool saveImmediately = false,
  }) {
    setState(() {
      final exercise = _session.exercises[exerciseIndex];
      final set = exercise.completedSets[setIndex];
      exercise.completedSets[setIndex] = set.copyWith(
        weight: weight ?? set.weight,
        reps: reps ?? set.reps,
        isCompleted: isCompleted ?? set.isCompleted,
        timestamp: (isCompleted == true && !set.isCompleted)
            ? DateTime.now()
            : set.timestamp,
      );
    });
    if (saveImmediately || isCompleted == true) {
      _saveToFirestore();
    }
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      final exercise = _session.exercises[exerciseIndex];
      final lastSet = exercise.lastCompletedSet;
      exercise.completedSets.add(ExerciseSetModel(
        setNumber: exercise.completedSets.length + 1,
        weight: lastSet?.weight,
        reps: lastSet?.reps ?? exercise.plannedReps,
      ));
    });
  }

  Future<void> _saveToFirestore() async {
    try {
      await _firestoreService.updateWorkoutSession(widget.sessionId, _session);
    } catch (e) {
      debugPrint('Background save failed: $e');
    }
  }

  Future<void> _completeWorkout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Complete Workout',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to finish this workout?',
          style: TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Finish'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestoreService.completeWorkoutSession(widget.sessionId);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Workout completed! 🎉'),
              backgroundColor: primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
