import 'package:flutter/material.dart';
import 'package:gym_track/core/constants/enums/days.dart';
import 'package:gym_track/product/model/workout_model.dart';

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
  static const Color primary = Color(0xFF00D9FF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8F98);

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _selectedDate = DateTime.now();
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: primary),
            onPressed: _previousMonth,
          ),
          Column(
            children: [
              Text(
                _formatMonthYear(_currentMonth),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.workout.name ?? 'Antrenman Planı',
                style: const TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: primary),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  /// Weekday labels (Pzt, Sal, Çar, etc.)
  Widget _buildWeekdayLabels() {
    final weekdays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          bottom: BorderSide(color: surfaceHighlight),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
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
    Color backgroundColor = surface;
    Color borderColor = surfaceHighlight;
    Color textColor = textPrimary;

    if (isSelected) {
      backgroundColor = primary.withValues(alpha: 0.2);
      borderColor = primary;
    } else if (isToday) {
      borderColor = primary.withValues(alpha: 0.5);
    }

    if (!_isInCurrentMonth(date)) {
      textColor = textSecondary.withValues(alpha: 0.3);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day number
            Text(
              '$day',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            // Workout indicator
            if (hasWorkout) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$exerciseCount',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00D9FF), Color(0xFF00B8D4)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF0A0E14),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      if (exercises.isNotEmpty)
                        Text(
                          '${exercises.length} egzersiz',
                          style: const TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
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
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  // Turkish date formatting helpers
  String _formatMonthYear(DateTime date) {
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
}
