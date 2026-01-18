import 'package:gym_track/core/base/base_model.dart';

/// User fitness goal type
enum GoalType {
  fatLoss,
  muscleGain,
  strength,
  endurance,
  general,
}

extension GoalTypeExtension on GoalType {
  String get displayName {
    switch (this) {
      case GoalType.fatLoss:
        return 'Fat Loss';
      case GoalType.muscleGain:
        return 'Muscle Gain';
      case GoalType.strength:
        return 'Strength';
      case GoalType.endurance:
        return 'Endurance';
      case GoalType.general:
        return 'General Fitness';
    }
  }

  String get iconName {
    switch (this) {
      case GoalType.fatLoss:
        return 'trending_down';
      case GoalType.muscleGain:
        return 'fitness_center';
      case GoalType.strength:
        return 'bolt';
      case GoalType.endurance:
        return 'directions_run';
      case GoalType.general:
        return 'favorite';
    }
  }
}

/// Model for user goals and program progress
class UserGoalModel extends BaseModel {
  final GoalType goalType;
  final int weeklyTarget;
  final int weeklyCompleted;
  final String? programName;
  final int? programWeekCurrent;
  final int? programWeekTotal;
  final DateTime? startDate;
  final DateTime? targetDate;

  UserGoalModel({
    required this.goalType,
    required this.weeklyTarget,
    required this.weeklyCompleted,
    this.programName,
    this.programWeekCurrent,
    this.programWeekTotal,
    this.startDate,
    this.targetDate,
  });

  /// Weekly progress percentage (0-100)
  int get weeklyProgressPercent {
    if (weeklyTarget == 0) return 0;
    return ((weeklyCompleted / weeklyTarget) * 100).round().clamp(0, 100);
  }

  /// Program progress percentage (0-100)
  int? get programProgressPercent {
    if (programWeekCurrent == null ||
        programWeekTotal == null ||
        programWeekTotal == 0) {
      return null;
    }
    return ((programWeekCurrent! / programWeekTotal!) * 100)
        .round()
        .clamp(0, 100);
  }

  /// Formatted program progress (e.g., "Week 3 of 8")
  String? get formattedProgramProgress {
    if (programWeekCurrent == null || programWeekTotal == null) return null;
    return 'Week $programWeekCurrent of $programWeekTotal';
  }

  /// Formatted weekly progress (e.g., "3 of 4 workouts")
  String get formattedWeeklyProgress {
    return '$weeklyCompleted of $weeklyTarget workouts';
  }

  /// Whether user is on track for weekly goal
  bool get onTrackWeekly {
    return weeklyCompleted >= weeklyTarget;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'goalType': goalType.name,
      'weeklyTarget': weeklyTarget,
      'weeklyCompleted': weeklyCompleted,
      if (programName != null) 'programName': programName,
      if (programWeekCurrent != null) 'programWeekCurrent': programWeekCurrent,
      if (programWeekTotal != null) 'programWeekTotal': programWeekTotal,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (targetDate != null) 'targetDate': targetDate!.toIso8601String(),
    };
  }

  factory UserGoalModel.fromJson(Map<String, dynamic> json) {
    return UserGoalModel(
      goalType: GoalType.values.firstWhere(
        (e) => e.name == json['goalType'],
        orElse: () => GoalType.general,
      ),
      weeklyTarget: json['weeklyTarget'] as int? ?? 4,
      weeklyCompleted: json['weeklyCompleted'] as int? ?? 0,
      programName: json['programName'] as String?,
      programWeekCurrent: json['programWeekCurrent'] as int?,
      programWeekTotal: json['programWeekTotal'] as int?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
    );
  }

  /// Create mock goal for testing
  factory UserGoalModel.mock() {
    return UserGoalModel(
      goalType: GoalType.muscleGain,
      weeklyTarget: 4,
      weeklyCompleted: 3,
      programName: '4-Week Strength Builder',
      programWeekCurrent: 3,
      programWeekTotal: 8,
      startDate: DateTime.now().subtract(const Duration(days: 14)),
      targetDate: DateTime.now().add(const Duration(days: 42)),
    );
  }

  /// Create empty goal for new users
  factory UserGoalModel.empty() {
    return UserGoalModel(
      goalType: GoalType.general,
      weeklyTarget: 3,
      weeklyCompleted: 0,
    );
  }
}
