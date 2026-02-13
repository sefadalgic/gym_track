import 'package:flutter/material.dart';
import 'package:gym_track/core/constants/enums/days.dart';
import 'package:gym_track/product/model/workout_model.dart';
import 'package:gym_track/product/model/workout_session_model.dart';
import 'package:gym_track/product/model/workout_session_exercise_model.dart';
import 'package:gym_track/product/service/firestore_service.dart';
import 'package:gym_track/feature/workouts/view/workout_session_screen.dart';

/// Modern calendar view for displaying workout plans
class WorkoutCalendarView extends StatefulWidget {
  final WorkoutModel workout;

  const WorkoutCalendarView({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutCalendarView> createState() => _WorkoutCalendarViewState();
}

class _WorkoutCalendarViewState extends State<WorkoutCalendarView> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  // Modern dark theme colors
  static const Color background = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF151A21);
  static const Color surfaceHighlight = Color(0xFF1E252E);
  static const Color primary = Color(0xFF00FF88); // Green accent
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8F98);

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _selectedDate = DateTime.now();
    _checkActiveSession();
  }

  // Firestore service
  final FirestoreService _firestoreService = FirestoreService.instance;
  WorkoutSessionModel? _activeSession;
  bool _isCheckingSession = false;

  /// Check if there's an active session for the selected date
  Future<void> _checkActiveSession() async {
    if (_selectedDate == null) return;

    setState(() {
      _isCheckingSession = true;
    });

    try {
      final sessions =
          await _firestoreService.getWorkoutSessionsForDate(_selectedDate!);
      setState(() {
        _activeSession = sessions.isNotEmpty ? sessions.first : null;
        _isCheckingSession = false;
      });
    } catch (e) {
      print('Error checking active session: $e');
      setState(() {
        _isCheckingSession = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      child: Column(
        children: [
          _buildCalendarHeader(),
          _buildWeekdayLabels(),
          Expanded(
            child: _buildCalendarGrid(),
          ),
          if (_selectedDate != null) _buildSelectedDayDetails(),
        ],
      ),
    );
  }

  /// Calendar header with month navigation
  Widget _buildCalendarHeader() {
    // Calculate active days in current month
    final activeDays = _getActiveDaysInMonth(_currentMonth);
    final totalDays = _getDaysInMonth(_currentMonth);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: background,
      ),
      child: Column(
        children: [
          Text(
            _formatMonthYear(_currentMonth),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$activeDays/$totalDays Days active',
            style: const TextStyle(
              fontSize: 14,
              color: primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Weekday labels (MON, TUE, WED, etc.)
  Widget _buildWeekdayLabels() {
    final weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const BoxDecoration(
        color: background,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Calendar grid with days
  Widget _buildCalendarGrid() {
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.8,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: daysInMonth + startingWeekday - 1,
      itemBuilder: (context, index) {
        // Empty cells before the first day of the month
        if (index < startingWeekday - 1) {
          return const SizedBox.shrink();
        }

        final day = index - startingWeekday + 2;
        final date = DateTime(_currentMonth.year, _currentMonth.month, day);
        final isToday = _isToday(date);
        final isSelected = _isSelected(date);
        final hasWorkout = _hasWorkoutOnDay(date);
        final exercises = _getExercisesForDate(date);

        return _buildCalendarDay(
          day,
          date,
          isToday: isToday,
          isSelected: isSelected,
          hasWorkout: hasWorkout,
          exerciseCount: exercises.length,
        );
      },
    );
  }

  /// Individual calendar day cell
  Widget _buildCalendarDay(
    int day,
    DateTime date, {
    required bool isToday,
    required bool isSelected,
    required bool hasWorkout,
    required int exerciseCount,
  }) {
    Color backgroundColor = Colors.transparent;
    Color? borderColor;
    Color textColor = textPrimary;

    if (isSelected) {
      backgroundColor = primary.withValues(alpha: 0.15);
      borderColor = primary;
    }

    if (!_isInCurrentMonth(date)) {
      textColor = textSecondary.withValues(alpha: 0.4);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
        _checkActiveSession();
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: borderColor != null
              ? Border.all(color: borderColor, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day number
            Text(
              '$day',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            // Workout indicator - small dot
            if (hasWorkout)
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  /// Selected day details panel
  Widget _buildSelectedDayDetails() {
    if (_selectedDate == null) return const SizedBox.shrink();

    final exercises = _getExercisesForDate(_selectedDate!);
    final formattedDate = _formatFullDate(_selectedDate!);

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF151A21), Color(0xFF12161C)],
        ),
        border: Border(
          top: BorderSide(color: surfaceHighlight, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Green dot indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ),
                // Completion badge
                if (_activeSession != null && _activeSession!.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 13,
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Start Workout Button (only show if there are exercises)
          if (exercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _isCheckingSession
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _startOrContinueWorkout(exercises),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: const Color(0xFF0A0E14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _activeSession != null &&
                                      !_activeSession!.isCompleted
                                  ? Icons.play_arrow_rounded
                                  : Icons.fitness_center_rounded,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _activeSession != null &&
                                      !_activeSession!.isCompleted
                                  ? 'Antrenmana Devam Et'
                                  : 'Antrenmana Başla',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          // Exercise list
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy_rounded,
                            size: 48,
                            color: textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Bu gün için antrenman yok',
                            style: TextStyle(
                              fontSize: 14,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _activeSession != null && _activeSession!.isCompleted
                    // Show completed session data
                    ? _buildCompletedSessionList()
                    // Show planned exercises
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = exercises[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: surfaceHighlight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: primary.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    exercise.name ?? 'Bilinmeyen Egzersiz',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        primary.withValues(alpha: 0.2),
                                        primary.withValues(alpha: 0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: primary.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    '${exercise.sets}×${exercise.reps}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  /// Build completed session list with actual data
  Widget _buildCompletedSessionList() {
    if (_activeSession == null) return const SizedBox.shrink();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _activeSession!.exercises.length,
      itemBuilder: (context, index) {
        final exercise = _activeSession!.exercises[index];
        final completedSets =
            exercise.completedSets.where((s) => s.isCompleted).toList();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF151A21), Color(0xFF12161C)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: surfaceHighlight),
          ),
          child: Theme(
            data: ThemeData(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              childrenPadding: const EdgeInsets.all(12),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF88).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF00FF88).withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF00FF88),
                  size: 20,
                ),
              ),
              title: Text(
                exercise.exerciseName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              subtitle: Text(
                '${completedSets.length} set tamamlandı',
                style: const TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF88).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${exercise.completionPercentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00FF88),
                  ),
                ),
              ),
              children: [
                // Header row
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const SizedBox(width: 40),
                      const Expanded(
                        child: Text(
                          'Set',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Kilo',
                          style: TextStyle(
                            fontSize: 11,
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
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                // Completed sets
                ...completedSets.map((set) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF88).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF00FF88).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00FF88),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${set.setNumber}',
                              style: const TextStyle(
                                color: Color(0xFF0A0E14),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Set ${set.setNumber}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${set.weight?.toStringAsFixed(1) ?? '-'} kg',
                            style: const TextStyle(
                              fontSize: 14,
                              color: textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${set.reps ?? '-'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF00FF88),
                          size: 20,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper methods
  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSelected(DateTime date) {
    if (_selectedDate == null) return false;
    return date.year == _selectedDate!.year &&
        date.month == _selectedDate!.month &&
        date.day == _selectedDate!.day;
  }

  bool _isInCurrentMonth(DateTime date) {
    return date.month == _currentMonth.month && date.year == _currentMonth.year;
  }

  bool _hasWorkoutOnDay(DateTime date) {
    return _getExercisesForDate(date).isNotEmpty;
  }

  int _getActiveDaysInMonth(DateTime month) {
    final daysInMonth = _getDaysInMonth(month);
    int activeDays = 0;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      if (_hasWorkoutOnDay(date)) {
        activeDays++;
      }
    }

    return activeDays;
  }

  Days _getDayOfWeek(DateTime date) {
    // DateTime.weekday: 1 = Monday, 7 = Sunday
    switch (date.weekday) {
      case 1:
        return Days.monday;
      case 2:
        return Days.tuesday;
      case 3:
        return Days.wednesday;
      case 4:
        return Days.thursday;
      case 5:
        return Days.friday;
      case 6:
        return Days.saturday;
      case 7:
        return Days.sunday;
      default:
        return Days.monday;
    }
  }

  List _getExercisesForDate(DateTime date) {
    final dayOfWeek = _getDayOfWeek(date);
    return widget.workout.exercises?[dayOfWeek] ?? [];
  }

  // Date formatting helpers
  String _formatMonthYear(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    final weekdays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar'
    ];
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '${date.day} $month ${date.year}, $weekday';
  }

  /// Start a new workout or continue an existing one
  Future<void> _startOrContinueWorkout(List exercises) async {
    if (_selectedDate == null) return;

    try {
      String sessionId;

      if (_activeSession != null && !_activeSession!.isCompleted) {
        // Continue existing session
        sessionId = _activeSession!.id!;
      } else {
        // Create new session
        final sessionExercises = exercises.map((exercise) {
          return WorkoutSessionExerciseModel(
            exerciseId: exercise.exerciseId ?? '',
            exerciseName: exercise.name ?? 'Unknown',
            plannedSets: exercise.sets ?? 3,
            plannedReps: exercise.reps ?? 10,
          );
        }).toList();

        final newSession = WorkoutSessionModel(
          workoutId: widget.workout.id ?? '',
          workoutName: widget.workout.name ?? 'Workout',
          date: _selectedDate!,
          startTime: DateTime.now(),
          exercises: sessionExercises,
        );

        sessionId = await _firestoreService.createWorkoutSession(newSession);
      }

      // Navigate to workout session screen
      if (mounted) {
        // Fetch the session to get the latest data
        final session = await _firestoreService.getWorkoutSession(sessionId);
        if (session != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutSessionScreen(
                sessionId: sessionId,
                session: session,
              ),
            ),
          ).then((_) {
            // Refresh active session when returning
            _checkActiveSession();
          });
        }
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
