import 'package:flutter/material.dart';
import 'package:gym_track/core/thene/app_theme.dart';

class MonthlyProgressScreenV2 extends StatefulWidget {
  const MonthlyProgressScreenV2({super.key});

  @override
  State<MonthlyProgressScreenV2> createState() =>
      _MonthlyProgressScreenV2State();
}

class _MonthlyProgressScreenV2State extends State<MonthlyProgressScreenV2> {
  late MonthlyProgress progress;
  int selectedDay = 12;

  @override
  void initState() {
    super.initState();
    progress = WorkoutDataGenerator.getSeptember2023();
  }

  @override
  Widget build(BuildContext context) {
    final selectedWorkout = progress.getWorkout(selectedDay);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Monthly Progress',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: AppTheme.primary),
            onPressed: () {
              // Show month picker
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Month Header
            _buildMonthHeader(),

            // Calendar
            _buildCalendar(),

            const SizedBox(height: 24),

            // Workout Details (if available)
            if (selectedWorkout != null)
              _buildWorkoutDetailsCard(selectedWorkout)
            else
              _buildNoWorkoutCard(),

            const SizedBox(height: 16),

            // Insight Card
            _buildInsightCard(),

            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add workout
        },
        backgroundColor: AppTheme.primary,
        elevation: 4,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${progress.monthName} ${progress.year}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                progress.progressText,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.bar_chart,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    const weekDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Week day headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) {
              return SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary.withOpacity(0.6),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Calendar grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // September 2023 starts on Friday (index 4)
    final firstDayOffset = 4;
    final daysInMonth = 30;

    return Column(
      children: [
        for (int week = 0; week < 5; week++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int day = 0; day < 7; day++)
                  _buildDayCell(week * 7 + day, firstDayOffset, daysInMonth),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDayCell(int index, int offset, int daysInMonth) {
    final dayNumber = index - offset + 1;
    final isValidDay = dayNumber > 0 && dayNumber <= daysInMonth;
    final hasWorkout = isValidDay && progress.hasWorkoutOnDay(dayNumber);
    final isSelected = isValidDay && dayNumber == selectedDay;
    final workout = isValidDay ? progress.getWorkout(dayNumber) : null;

    if (!isValidDay) {
      return SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: Text(
            index < offset ? '${28 + index}' : '${dayNumber - daysInMonth}',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDay = dayNumber;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '$dayNumber',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            if (hasWorkout && workout != null)
              Positioned(
                bottom: 6,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: workout.exercises.map((exercise) {
                    final color = exercise.type == ExerciseType.cardio
                        ? AppTheme.primary
                        : AppTheme.secondary;
                    return Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutDetailsCard(Workout workout) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      color: AppTheme.primary,
                      size: 8,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      workout.formattedDate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (workout.isCompleted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('DURATION', '${workout.totalDuration}', 'min'),
                _buildStatItem('BURNED', '${workout.totalCalories}', 'kcal',
                    isHighlight: true),
                if (workout.heartRate != null)
                  _buildStatItem('HEART RATE', '${workout.heartRate}', 'bpm'),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(color: Color(0xFF2A2A2A), height: 1),
            const SizedBox(height: 20),

            // Exercise List
            ...workout.exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < workout.exercises.length - 1 ? 16 : 0,
                ),
                child: _buildExerciseItem(exercise),
              );
            }).toList(),

            const SizedBox(height: 20),

            // Add Activity Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '+ Log Additional Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoWorkoutCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.textSecondary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center,
              size: 48,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No workout logged',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to log an activity',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit,
      {bool isHighlight = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary.withOpacity(0.6),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppTheme.primary : AppTheme.textPrimary,
            ),
            children: [
              TextSpan(text: value),
              TextSpan(
                text: unit,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isHighlight ? AppTheme.primary : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseItem(Exercise exercise) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            exercise.icon,
            color: AppTheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                exercise.details,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Text(
          '${exercise.calories} kcal',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2414),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.secondary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFF1A1A1A),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Insight',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary.withOpacity(0.9),
                        height: 1.4,
                      ),
                      children: const [
                        TextSpan(text: 'You\'ve completed '),
                        TextSpan(
                          text: '15% more',
                          style: TextStyle(
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                            text:
                                ' cardio sessions than last month. Keep the momentum!'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        color: AppTheme.cardBackground,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', false),
              _buildNavItem(Icons.bar_chart, 'Progress', true),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(Icons.fitness_center, 'Workout', false),
              _buildNavItem(Icons.person_outline, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppTheme.primary : AppTheme.textSecondary,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? AppTheme.primary : AppTheme.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// Workout model for tracking exercises
class Workout {
  final String id;
  final DateTime date;
  final List<Exercise> exercises;
  final int totalDuration; // in minutes
  final int totalCalories;
  final int? heartRate;
  final bool isCompleted;

  Workout({
    required this.id,
    required this.date,
    required this.exercises,
    required this.totalDuration,
    required this.totalCalories,
    this.heartRate,
    this.isCompleted = false,
  });

  String get formattedDate {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}

/// Exercise model
class Exercise {
  final String name;
  final ExerciseType type;
  final int duration; // in minutes
  final int calories;
  final String? intensity;
  final int? sets;
  final int? reps;

  Exercise({
    required this.name,
    required this.type,
    required this.duration,
    required this.calories,
    this.intensity,
    this.sets,
    this.reps,
  });

  IconData get icon {
    switch (type) {
      case ExerciseType.cardio:
        return Icons.directions_run;
      case ExerciseType.strength:
        return Icons.fitness_center;
      case ExerciseType.yoga:
        return Icons.self_improvement;
      case ExerciseType.sports:
        return Icons.sports_basketball;
      case ExerciseType.other:
        return Icons.sports;
    }
  }

  String get details {
    if (intensity != null) {
      return '$duration minutes • $intensity';
    } else if (sets != null && reps != null) {
      return '$duration minutes • $sets×$reps';
    } else {
      return '$duration minutes';
    }
  }
}

enum ExerciseType {
  cardio,
  strength,
  yoga,
  sports,
  other,
}

/// Monthly progress model
class MonthlyProgress {
  final int year;
  final int month;
  final Map<int, Workout> workouts; // day -> workout
  final int activeDays;
  final int totalDays;

  MonthlyProgress({
    required this.year,
    required this.month,
    required this.workouts,
    required this.activeDays,
    required this.totalDays,
  });

  String get monthName {
    const months = [
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
    return months[month - 1];
  }

  String get progressText => '$activeDays/$totalDays Days active';

  bool hasWorkoutOnDay(int day) => workouts.containsKey(day);

  Workout? getWorkout(int day) => workouts[day];
}

/// Sample data generator
class WorkoutDataGenerator {
  static MonthlyProgress getSeptember2023() {
    final workouts = <int, Workout>{};

    // Sep 1
    workouts[1] = Workout(
      id: '1',
      date: DateTime(2023, 9, 1),
      exercises: [
        Exercise(
          name: 'Morning Run',
          type: ExerciseType.cardio,
          duration: 25,
          calories: 280,
          intensity: 'Moderate',
        ),
      ],
      totalDuration: 25,
      totalCalories: 280,
      heartRate: 135,
      isCompleted: true,
    );

    // Sep 2
    workouts[2] = Workout(
      id: '2',
      date: DateTime(2023, 9, 2),
      exercises: [
        Exercise(
          name: 'Leg Day',
          type: ExerciseType.strength,
          duration: 45,
          calories: 320,
          sets: 4,
          reps: 12,
        ),
      ],
      totalDuration: 45,
      totalCalories: 320,
      heartRate: 128,
      isCompleted: true,
    );

    // Sep 4
    workouts[4] = Workout(
      id: '4',
      date: DateTime(2023, 9, 4),
      exercises: [
        Exercise(
          name: 'HIIT Session',
          type: ExerciseType.cardio,
          duration: 30,
          calories: 350,
          intensity: 'High Intensity',
        ),
      ],
      totalDuration: 30,
      totalCalories: 350,
      heartRate: 152,
      isCompleted: true,
    );

    // Sep 5
    workouts[5] = Workout(
      id: '5',
      date: DateTime(2023, 9, 5),
      exercises: [
        Exercise(
          name: 'Yoga Flow',
          type: ExerciseType.yoga,
          duration: 40,
          calories: 150,
          intensity: 'Relaxing',
        ),
      ],
      totalDuration: 40,
      totalCalories: 150,
      heartRate: 95,
      isCompleted: true,
    );

    // Sep 7
    workouts[7] = Workout(
      id: '7',
      date: DateTime(2023, 9, 7),
      exercises: [
        Exercise(
          name: 'Cycling',
          type: ExerciseType.cardio,
          duration: 50,
          calories: 420,
          intensity: 'Moderate',
        ),
      ],
      totalDuration: 50,
      totalCalories: 420,
      heartRate: 140,
      isCompleted: true,
    );

    // Sep 8
    workouts[8] = Workout(
      id: '8',
      date: DateTime(2023, 9, 8),
      exercises: [
        Exercise(
          name: 'Swimming',
          type: ExerciseType.cardio,
          duration: 35,
          calories: 310,
          intensity: 'High Intensity',
        ),
      ],
      totalDuration: 35,
      totalCalories: 310,
      heartRate: 138,
      isCompleted: true,
    );

    // Sep 9
    workouts[9] = Workout(
      id: '9',
      date: DateTime(2023, 9, 9),
      exercises: [
        Exercise(
          name: 'Upper Body',
          type: ExerciseType.strength,
          duration: 40,
          calories: 280,
          sets: 3,
          reps: 15,
        ),
      ],
      totalDuration: 40,
      totalCalories: 280,
      heartRate: 125,
      isCompleted: true,
    );

    // Sep 12 (Featured day)
    workouts[12] = Workout(
      id: '12',
      date: DateTime(2023, 9, 12),
      exercises: [
        Exercise(
          name: 'Morning Cardio',
          type: ExerciseType.cardio,
          duration: 30,
          calories: 310,
          intensity: 'High Intensity',
        ),
        Exercise(
          name: 'Upper Body Routine',
          type: ExerciseType.strength,
          duration: 22,
          calories: 170,
          sets: 3,
          reps: 12,
        ),
      ],
      totalDuration: 52,
      totalCalories: 480,
      heartRate: 142,
      isCompleted: true,
    );

    return MonthlyProgress(
      year: 2023,
      month: 9,
      workouts: workouts,
      activeDays: 18,
      totalDays: 30,
    );
  }
}
