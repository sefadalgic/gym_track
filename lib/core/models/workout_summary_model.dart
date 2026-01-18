import 'package:gym_track/core/base/base_model.dart';

/// Workout completion status
enum WorkoutStatus {
  completed,
  skipped,
  inProgress,
}

extension WorkoutStatusExtension on WorkoutStatus {
  String get displayName {
    switch (this) {
      case WorkoutStatus.completed:
        return 'Completed';
      case WorkoutStatus.skipped:
        return 'Skipped';
      case WorkoutStatus.inProgress:
        return 'In Progress';
    }
  }
}

/// Lightweight model for recent workout history
class WorkoutSummaryModel extends BaseModel {
  final String id;
  final String name;
  final DateTime date;
  final int? durationMinutes;
  final int? exerciseCount;
  final WorkoutStatus status;
  final String? notes;

  WorkoutSummaryModel({
    required this.id,
    required this.name,
    required this.date,
    this.durationMinutes,
    this.exerciseCount,
    required this.status,
    this.notes,
  });

  /// Formatted date (e.g., "Jan 17")
  String get formattedDate {
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
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Formatted duration (e.g., "52 min")
  String? get formattedDuration {
    if (durationMinutes == null) return null;
    return '$durationMinutes min';
  }

  /// Formatted exercise count (e.g., "8 exercises")
  String? get formattedExerciseCount {
    if (exerciseCount == null) return null;
    return '$exerciseCount exercise${exerciseCount! == 1 ? '' : 's'}';
  }

  /// Subtitle for workout item (e.g., "Jan 17 • 52 min • 8 exercises")
  String get subtitle {
    final parts = <String>[formattedDate];
    if (status == WorkoutStatus.completed) {
      if (formattedDuration != null) parts.add(formattedDuration!);
      if (formattedExerciseCount != null) parts.add(formattedExerciseCount!);
    } else if (status == WorkoutStatus.skipped) {
      parts.add('Skipped');
    } else {
      parts.add('In Progress');
    }
    return parts.join(' • ');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      if (exerciseCount != null) 'exerciseCount': exerciseCount,
      'status': status.name,
      if (notes != null) 'notes': notes,
    };
  }

  factory WorkoutSummaryModel.fromJson(Map<String, dynamic> json) {
    return WorkoutSummaryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      durationMinutes: json['durationMinutes'] as int?,
      exerciseCount: json['exerciseCount'] as int?,
      status: WorkoutStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WorkoutStatus.completed,
      ),
      notes: json['notes'] as String?,
    );
  }

  /// Create mock workout history for testing
  static List<WorkoutSummaryModel> mockList() {
    final now = DateTime.now();
    return [
      WorkoutSummaryModel(
        id: '1',
        name: 'Upper Body Strength',
        date: now.subtract(const Duration(days: 1)),
        durationMinutes: 52,
        exerciseCount: 8,
        status: WorkoutStatus.completed,
      ),
      WorkoutSummaryModel(
        id: '2',
        name: 'Cardio & Core',
        date: now.subtract(const Duration(days: 2)),
        durationMinutes: 35,
        exerciseCount: 6,
        status: WorkoutStatus.completed,
      ),
      WorkoutSummaryModel(
        id: '3',
        name: 'Lower Body Power',
        date: now.subtract(const Duration(days: 3)),
        status: WorkoutStatus.skipped,
      ),
      WorkoutSummaryModel(
        id: '4',
        name: 'Full Body Circuit',
        date: now.subtract(const Duration(days: 4)),
        durationMinutes: 45,
        exerciseCount: 10,
        status: WorkoutStatus.completed,
      ),
      WorkoutSummaryModel(
        id: '5',
        name: 'Upper Body Hypertrophy',
        date: now.subtract(const Duration(days: 5)),
        durationMinutes: 58,
        exerciseCount: 9,
        status: WorkoutStatus.completed,
      ),
    ];
  }
}
