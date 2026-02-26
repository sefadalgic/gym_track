import 'package:flutter/material.dart';
import 'package:gym_track/core/constants/enums/days.dart';
import 'package:gym_track/core/thene/app_theme.dart';
import 'package:gym_track/product/model/workout_model.dart';
import 'package:gym_track/product/model/workout_session_model.dart';
import 'package:gym_track/product/model/workout_session_exercise_model.dart';
import 'package:gym_track/product/service/auth_service.dart';
import 'package:gym_track/product/service/firestore_service.dart';
import 'package:gym_track/feature/workouts/view/workout_session_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Home / Dashboard view
class HomeView extends StatefulWidget {
  final WorkoutModel? activeWorkout;

  const HomeView({super.key, this.activeWorkout});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Colors
  static const Color background = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF151A21);
  static const Color surfaceHighlight = Color(0xFF1E252E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8F98);

  final FirestoreService _firestoreService = FirestoreService.instance;
  final AuthService _authService = AuthService.instance;

  User? _user;
  int _totalVolume = 0;
  int _completedSets = 0;
  int _totalSets = 0;
  bool _isLoadingStats = true;
  bool _isStartingWorkout = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _authService.getCurrentUser();
    setState(() => _user = user);
    await _loadWeeklyStats();
  }

  /// Start or continue today's workout session
  Future<void> _startWorkout() async {
    final workout = widget.activeWorkout;
    if (workout == null || _isStartingWorkout) return;

    setState(() => _isStartingWorkout = true);

    try {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Check for existing session today
      final existingSessions =
          await _firestoreService.getWorkoutSessionsForDate(todayDate);
      final activeSession =
          existingSessions.where((s) => !s.isCompleted).isNotEmpty
              ? existingSessions.firstWhere((s) => !s.isCompleted)
              : null;

      String sessionId;

      if (activeSession != null) {
        sessionId = activeSession.id!;
      } else {
        // Build exercise list for today
        final dayEnum = _weekdayToEnum(today.weekday);
        final todayExercises = workout.exercises?[dayEnum] ?? [];

        final sessionExercises = todayExercises.map((exercise) {
          return WorkoutSessionExerciseModel(
            exerciseId: exercise.exerciseId ?? '',
            exerciseName: exercise.name ?? 'Unknown',
            plannedSets: exercise.sets ?? 3,
            plannedReps: exercise.reps ?? 10,
          );
        }).toList();

        final newSession = WorkoutSessionModel(
          workoutId: workout.id ?? '',
          workoutName: workout.name ?? 'Workout',
          date: todayDate,
          startTime: DateTime.now(),
          exercises: sessionExercises,
        );

        sessionId = await _firestoreService.createWorkoutSession(newSession);
      }

      if (!mounted) return;
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
        ).then((_) => _loadWeeklyStats());
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
    } finally {
      if (mounted) setState(() => _isStartingWorkout = false);
    }
  }

  Future<void> _loadWeeklyStats() async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final sessions = <WorkoutSessionModel>[];

      for (int i = 0; i < 7; i++) {
        final day = weekStart.add(Duration(days: i));
        final daySessions =
            await _firestoreService.getWorkoutSessionsForDate(day);
        sessions.addAll(daySessions);
      }

      int volume = 0;
      int completed = 0;
      int total = 0;

      for (final session in sessions) {
        for (final exercise in session.exercises) {
          for (final set in exercise.completedSets) {
            total++;
            if (set.isCompleted) {
              completed++;
              volume += ((set.weight ?? 0) * (set.reps ?? 0)).toInt();
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _totalVolume = volume;
          _completedSets = completed;
          _totalSets = total;
          _isLoadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _displayName() {
    // 1. Firebase displayName (Google Sign-In, etc.)
    if (_user?.displayName != null && _user!.displayName!.isNotEmpty) {
      return _user!.displayName!.split(' ').first;
    }
    // 2. Email başından kullanıcı adı (email/password auth)
    if (_user?.email != null && _user!.email!.isNotEmpty) {
      return _user!.email!.split('@').first;
    }
    return 'Athlete';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 28),
              _buildWeeklyProgress(),
              const SizedBox(height: 28),
              _buildTodaysFocus(),
              const SizedBox(height: 28),
              _buildPerformanceOverview(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        // Avatar
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primary.withValues(alpha: 0.15),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: _user?.photoURL != null
              ? ClipOval(
                  child: Image.network(
                    _user!.photoURL!,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
                  Icons.person_rounded,
                  color: AppTheme.primary,
                  size: 28,
                ),
        ),
        const SizedBox(width: 14),
        // Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()}, ${_displayName()}!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Let's crush your goals today.",
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Notification bell
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: surfaceHighlight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: textSecondary,
            size: 22,
          ),
        ),
      ],
    );
  }

  // ── Weekly Progress ────────────────────────────────────────────────────────
  Widget _buildWeeklyProgress() {
    final now = DateTime.now();
    // Build Sun..Sat from this week
    final weekStart = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final sunday = weekStart.subtract(const Duration(days: 1));
    final weekDays = [
      sunday,
      weekStart,
      weekStart.add(const Duration(days: 1)),
      weekStart.add(const Duration(days: 2)),
      weekStart.add(const Duration(days: 3)),
      weekStart.add(const Duration(days: 4)),
      weekStart.add(const Duration(days: 5)),
    ];

    final labels = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    final monthLabel = _monthName(now.month);
    final rangeLabel = '$monthLabel ${weekDays[0].day}-${weekDays[6].day}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Weekly Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            Text(
              rangeLabel,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final day = weekDays[i];
            final isToday = day.day == now.day &&
                day.month == now.month &&
                day.year == now.year;
            final isPast = day.isBefore(DateTime(now.year, now.month, now.day));
            return _buildWeekDay(labels[i], day.day, isToday, isPast);
          }),
        ),
      ],
    );
  }

  Widget _buildWeekDay(String label, int dayNum, bool isToday, bool isPast) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPast
                ? AppTheme.primary
                : isToday
                    ? Colors.transparent
                    : surfaceHighlight,
            border:
                isToday ? Border.all(color: AppTheme.primary, width: 2) : null,
          ),
          child: Center(
            child: isPast
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : Text(
                    '$dayNum',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isToday ? AppTheme.primary : textSecondary,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ── Today's Focus ──────────────────────────────────────────────────────────
  Widget _buildTodaysFocus() {
    final workout = widget.activeWorkout;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Focus",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Edit Plan',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: surfaceHighlight),
          ),
          child: workout == null
              ? _buildNoWorkoutContent()
              : _buildWorkoutContent(workout),
        ),
      ],
    );
  }

  Widget _buildNoWorkoutContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.fitness_center_rounded,
                size: 40, color: textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text(
              'No active workout plan',
              style: TextStyle(fontSize: 14, color: textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a plan to see your daily focus here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: textSecondary.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutContent(WorkoutModel workout) {
    // Get today's exercises using Days enum
    final today = DateTime.now().weekday; // 1=Mon ... 7=Sun
    final dayEnum = _weekdayToEnum(today);
    final todayExercises = workout.exercises?[dayEnum] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Workout name + badge
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  workout.name ?? 'My Workout',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${workout.trainingDays}D / WEEK',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
          child: Text(
            '${todayExercises.length} Exercises today',
            style: TextStyle(fontSize: 13, color: textSecondary),
          ),
        ),
        // Exercise list (max 3 previewed)
        if (todayExercises.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'Rest day — no exercises planned for today.',
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
          )
        else
          ...todayExercises.take(3).map((exercise) {
            final name = exercise.name ?? 'Exercise';
            final sets = exercise.sets ?? 3;
            final reps = exercise.reps ?? 10;
            return _buildExerciseItem(name, '$sets Sets × $reps Reps');
          }),
        if (todayExercises.length > 3)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(
              '+${todayExercises.length - 3} more exercises',
              style: TextStyle(
                  fontSize: 12, color: AppTheme.primary.withValues(alpha: 0.7)),
            ),
          ),
        const SizedBox(height: 12),
        // Start Workout Button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isStartingWorkout ? null : _startWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text(
                'Start Workout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseItem(String name, String detail) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceHighlight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              color: AppTheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.drag_indicator_rounded, color: textSecondary, size: 20),
        ],
      ),
    );
  }

  // ── Performance Overview ───────────────────────────────────────────────────
  Widget _buildPerformanceOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.fitness_center_rounded,
                iconColor: AppTheme.primary,
                label: 'TOTAL VOLUME',
                value: _isLoadingStats
                    ? '...'
                    : '${_formatVolume(_totalVolume)} kg',
                sub: '↑ This week',
                subColor: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.layers_rounded,
                iconColor: AppTheme.secondary,
                label: 'SETS FINISHED',
                value: _isLoadingStats ? '...' : '$_completedSets',
                sub: '/ ${_totalSets == 0 ? '—' : _totalSets}',
                subColor: textSecondary,
                showProgress: _totalSets > 0,
                progress: _totalSets > 0 ? _completedSets / _totalSets : 0.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String sub,
    required Color subColor,
    bool showProgress = false,
    double progress = 0.0,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: surfaceHighlight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          if (showProgress) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: surfaceHighlight,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            sub,
            style: TextStyle(
              fontSize: 12,
              color: subColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Days _weekdayToEnum(int weekday) {
    // weekday: 1=Mon, 2=Tue, ..., 7=Sun
    const dayMap = [
      Days.monday,
      Days.tuesday,
      Days.wednesday,
      Days.thursday,
      Days.friday,
      Days.saturday,
      Days.sunday,
    ];
    return dayMap[(weekday - 1) % 7];
  }

  String _formatVolume(int volume) {
    if (volume >= 1000) return '${(volume / 1000).toStringAsFixed(1)}k';
    return volume.toString();
  }

  String _monthName(int month) {
    const months = [
      '',
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
    return months[month];
  }

  String _formatShortDate(DateTime date) => '${date.day}';
}
