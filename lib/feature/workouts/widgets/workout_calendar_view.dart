import 'package:flutter/material.dart';
import 'package:gym_track/core/base/base_widget_mixin.dart';
import 'package:gym_track/core/constants/enums/days.dart';
import 'package:gym_track/core/thene/app_theme.dart';
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

class _WorkoutCalendarViewState extends State<WorkoutCalendarView>
    with BaseWidgetMixin {
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  // Month sessions map: day number → session for that day
  Map<int, WorkoutSessionModel> _sessionsByDay = {};

  // Modern dark theme colors
  static const Color background = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF151A21);
  static const Color surfaceHighlight = Color(0xFF1E252E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8F98);

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _selectedDate = DateTime.now();
    _checkActiveSession();
    _loadMonthSessions();
  }

  // Firestore service
  final FirestoreService _firestoreService = FirestoreService.instance;
  WorkoutSessionModel? _activeSession;
  bool _isCheckingSession = false;

  /// Load all sessions for the current month (for dot indicators)
  Future<void> _loadMonthSessions() async {
    try {
      final sessions =
          await _firestoreService.getSessionsForMonth(_currentMonth);
      if (mounted) {
        setState(() {
          _sessionsByDay = sessions;
        });
      }
    } catch (_) {}
  }

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
      setState(() {
        _isCheckingSession = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: Container(
          margin: padding.only(context, left: 6),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primary.withValues(alpha: 0.1),
          ),
          child: IconButton(
            icon: const Icon(Icons.chevron_left_outlined,
                color: AppTheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Monthly Progress',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        color: background,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalendarHeader(),
              _buildWeekdayLabels(),
              _buildCalendarGrid(),
              _buildSelectedDayDetails(),
            ],
          ),
        ),
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
      width: double.infinity,
      decoration: const BoxDecoration(
        color: background,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              color: AppTheme.primary,
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
                  color: AppTheme.primary,
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
    final startingWeekday = firstDayOfMonth.weekday;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.25,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: daysInMonth + startingWeekday - 1,
      itemBuilder: (context, index) {
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
      backgroundColor = AppTheme.primary.withValues(alpha: 0.15);
      borderColor = AppTheme.primary;
    }

    if (!_isInCurrentMonth(date)) {
      textColor = textSecondary.withValues(alpha: 0.4);
    }

    // Determine dot indicator status
    final session = _sessionsByDay[date.day];
    final isInCurrentMonth = _isInCurrentMonth(date);
    final isPast =
        date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    _DotStatus dotStatus = _DotStatus.none;
    if (hasWorkout && isInCurrentMonth) {
      if (session != null && session.isCompleted) {
        dotStatus = _DotStatus.completed;
      } else if (session != null && !session.isCompleted) {
        dotStatus = _DotStatus.inProgress;
      } else if (isPast) {
        dotStatus = _DotStatus.missed;
      } else {
        dotStatus = _DotStatus.planned;
      }
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
            Text(
              '$day',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            _buildDotIndicator(dotStatus),
          ],
        ),
      ),
    );
  }

  /// Dot indicator widget based on day status
  Widget _buildDotIndicator(_DotStatus status) {
    switch (status) {
      case _DotStatus.completed:
        // Filled success dot
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppTheme.success,
            shape: BoxShape.circle,
          ),
        );
      case _DotStatus.inProgress:
        // Outlined primary dot (in-progress)
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primary,
              width: 1.5,
            ),
          ),
        );
      case _DotStatus.missed:
        // Red dot for missed workout
        return Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: Color(0xFFFF6B6B),
            shape: BoxShape.circle,
          ),
        );
      case _DotStatus.planned:
        // Filled primary dot for upcoming workout
        return Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
        );
      case _DotStatus.none:
        return const SizedBox(height: 6);
    }
  }

  /// Selected day details panel
  Widget _buildSelectedDayDetails() {
    if (_selectedDate == null) return const SizedBox.shrink();

    final exercises = _getExercisesForDate(_selectedDate!);
    final formattedDate = _formatFullDate(_selectedDate!);
    final isCompleted = _activeSession != null && _activeSession!.isCompleted;
    final hasActiveSession =
        _activeSession != null && !_activeSession!.isCompleted;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          top: BorderSide(color: surfaceHighlight, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.success
                        : exercises.isNotEmpty
                            ? AppTheme.primary
                            : textSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF88).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.success.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 14, color: AppTheme.success),
                        SizedBox(width: 4),
                        Text(
                          'Tamamlandı',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (exercises.isEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: surfaceHighlight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Dinlenme günü',
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Start / Continue button ──────────────────────────────────
          if (exercises.isNotEmpty && !isCompleted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _isCheckingSession
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () => _startOrContinueWorkout(exercises),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: const Color(0xFF0A0E14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: Icon(
                          hasActiveSession
                              ? Icons.play_arrow_rounded
                              : Icons.fitness_center_rounded,
                          size: 20,
                        ),
                        label: Text(
                          hasActiveSession
                              ? 'Antrenmana Devam Et'
                              : 'Antrenmana Başla',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),

          const SizedBox(height: 8),

          // ── Exercise list (no inner scroll) ──────────────────────────
          if (_isCheckingSession)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (exercises.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.self_improvement_rounded,
                        size: 36, color: textSecondary.withValues(alpha: 0.4)),
                    const SizedBox(height: 8),
                    Text(
                      'Bu gün için antrenman planlanmamış',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else if (isCompleted)
            _buildCompletedSessionList()
          else
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: surfaceHighlight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 11,
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
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${exercise.sets}×${exercise.reps}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Build completed session list with actual data
  Widget _buildCompletedSessionList() {
    if (_activeSession == null) return const SizedBox.shrink();

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
                  color: AppTheme.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.success.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.success,
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
                  color: AppTheme.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${exercise.completionPercentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.success,
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
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.success.withValues(alpha: 0.2),
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
                          color: AppTheme.success,
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
    _loadMonthSessions();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadMonthSessions();
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
            // Refresh active session + month indicators when returning
            _checkActiveSession();
            _loadMonthSessions();
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

/// Day status for calendar dot indicator
enum _DotStatus {
  none, // No workout scheduled
  planned, // Workout scheduled, future/today
  inProgress, // Session exists but not completed
  completed, // Session completed
  missed, // Workout scheduled, past day, no session
}
