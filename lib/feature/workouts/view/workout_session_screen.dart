import 'package:flutter/material.dart';
import 'package:gym_track/product/model/workout_session_model.dart';
import 'package:gym_track/product/model/workout_session_exercise_model.dart';
import 'package:gym_track/product/model/exercise_set_model.dart';
import 'package:gym_track/product/service/firestore_service.dart';

/// Screen for tracking an active workout session
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
  bool _isSaving = false;

  // Modern dark theme colors
  static const Color background = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF151A21);
  static const Color surfaceHighlight = Color(0xFF1E252E);
  static const Color primary = Color(0xFF00D9FF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8F98);

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _saveSession();
        return true;
      },
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: surface,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _session.workoutName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              Text(
                _formatDuration(_session.duration ?? Duration.zero),
                style: const TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save, color: primary),
              onPressed: _saveSession,
            ),
          ],
        ),
        body: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _session.exercises.length,
                itemBuilder: (context, index) {
                  return _buildExerciseCard(_session.exercises[index], index);
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  /// Progress header showing completion status
  Widget _buildProgressHeader() {
    final percentage = _session.completionPercentage;
    final completedSets = _session.totalCompletedSets;
    final totalSets = _session.totalPlannedSets;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF151A21), Color(0xFF12161C)],
        ),
        border: Border(
          bottom: BorderSide(color: surfaceHighlight),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'İlerleme',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              Text(
                '$completedSets / $totalSets set',
                style: const TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: surfaceHighlight,
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${percentage.toStringAsFixed(0)}% Tamamlandı',
            style: TextStyle(
              fontSize: 13,
              color: primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Exercise card with sets
  Widget _buildExerciseCard(
      WorkoutSessionExerciseModel exercise, int exerciseIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF151A21), Color(0xFF12161C)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: surfaceHighlight),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: primary.withValues(alpha: 0.1),
          highlightColor: primary.withValues(alpha: 0.05),
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(10),
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
              size: 20,
            ),
          ),
          title: Text(
            exercise.exerciseName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          subtitle: Text(
            'Hedef: ${exercise.plannedSets}×${exercise.plannedReps}',
            style: const TextStyle(
              fontSize: 13,
              color: textSecondary,
            ),
          ),
          trailing: CircularProgressIndicator(
            value: exercise.completionPercentage / 100,
            backgroundColor: surfaceHighlight,
            valueColor: AlwaysStoppedAnimation<Color>(primary),
            strokeWidth: 3,
          ),
          children: [
            _buildSetsSection(exercise, exerciseIndex),
            const SizedBox(height: 12),
            _buildAddSetButton(exercise, exerciseIndex),
          ],
        ),
      ),
    );
  }

  /// Sets section for an exercise
  Widget _buildSetsSection(
      WorkoutSessionExerciseModel exercise, int exerciseIndex) {
    return Column(
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const SizedBox(width: 40),
              const Expanded(
                child: Text(
                  'Kilo (kg)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Expanded(
                child: Text(
                  'Tekrar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        // Sets
        ...exercise.completedSets.asMap().entries.map((entry) {
          final setIndex = entry.key;
          final set = entry.value;
          return _buildSetRow(exercise, exerciseIndex, set, setIndex);
        }),
      ],
    );
  }

  /// Individual set row with weight and reps input
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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            set.isCompleted ? primary.withValues(alpha: 0.1) : surfaceHighlight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: set.isCompleted ? primary : surfaceHighlight,
        ),
      ),
      child: Row(
        children: [
          // Set number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: set.isCompleted ? primary : primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${set.setNumber}',
                style: TextStyle(
                  color: set.isCompleted ? background : primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Weight input
          Expanded(
            child: TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: textSecondary),
                filled: true,
                fillColor: surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                _updateSet(
                  exerciseIndex,
                  setIndex,
                  weight: double.tryParse(value),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Reps input
          Expanded(
            child: TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: textSecondary),
                filled: true,
                fillColor: surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                _updateSet(
                  exerciseIndex,
                  setIndex,
                  reps: int.tryParse(value),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Checkbox
          Checkbox(
            value: set.isCompleted,
            activeColor: primary,
            checkColor: background,
            onChanged: (value) {
              _updateSet(
                exerciseIndex,
                setIndex,
                isCompleted: value ?? false,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Add set button
  Widget _buildAddSetButton(
      WorkoutSessionExerciseModel exercise, int exerciseIndex) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _addSet(exerciseIndex),
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Set Ekle'),
      ),
    );
  }

  /// Bottom bar with complete workout button
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          top: BorderSide(color: surfaceHighlight),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _completeWorkout,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Antrenmayı Bitir',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Update a set
  void _updateSet(
    int exerciseIndex,
    int setIndex, {
    double? weight,
    int? reps,
    bool? isCompleted,
  }) {
    setState(() {
      final exercise = _session.exercises[exerciseIndex];
      final set = exercise.completedSets[setIndex];

      final updatedSet = set.copyWith(
        weight: weight ?? set.weight,
        reps: reps ?? set.reps,
        isCompleted: isCompleted ?? set.isCompleted,
        timestamp: (isCompleted == true && !set.isCompleted)
            ? DateTime.now()
            : set.timestamp,
      );

      exercise.completedSets[setIndex] = updatedSet;
    });
  }

  /// Add a new set to an exercise
  void _addSet(int exerciseIndex) {
    setState(() {
      final exercise = _session.exercises[exerciseIndex];
      final lastSet = exercise.lastCompletedSet;

      final newSet = ExerciseSetModel(
        setNumber: exercise.completedSets.length + 1,
        weight: lastSet?.weight,
        reps: lastSet?.reps ?? exercise.plannedReps,
      );

      exercise.completedSets.add(newSet);
    });
  }

  /// Save session to Firestore
  Future<void> _saveSession() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestoreService.updateWorkoutSession(widget.sessionId, _session);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Antrenman kaydedildi'),
            backgroundColor: primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kaydetme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  /// Complete workout session
  Future<void> _completeWorkout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        title: const Text(
          'Antrenmayı Bitir',
          style: TextStyle(color: textPrimary),
        ),
        content: const Text(
          'Antrenmayı tamamlamak istediğinizden emin misiniz?',
          style: TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: background,
            ),
            child: const Text('Tamamla'),
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
              content: const Text('Antrenman tamamlandı! 🎉'),
              backgroundColor: primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}s ${minutes}dk';
    }
    return '${minutes}dk';
  }
}
