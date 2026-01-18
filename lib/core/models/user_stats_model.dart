import 'package:gym_track/core/base/base_model.dart';

/// Model for user workout statistics and progress metrics
class UserStatsModel extends BaseModel {
  final int streakDays;
  final int totalWorkouts;
  final int totalTimeMinutes;
  final int monthlyProgress;
  final String? mostPerformedExercise;
  final int? mostPerformedCount;
  final int? averageDurationMinutes;
  final double? activityTrendPercent;

  UserStatsModel({
    required this.streakDays,
    required this.totalWorkouts,
    required this.totalTimeMinutes,
    required this.monthlyProgress,
    this.mostPerformedExercise,
    this.mostPerformedCount,
    this.averageDurationMinutes,
    this.activityTrendPercent,
  });

  /// Formatted total time as hours (e.g., "42.5h")
  String get formattedTotalTime {
    final hours = totalTimeMinutes / 60;
    return '${hours.toStringAsFixed(1)}h';
  }

  /// Formatted monthly progress with sign (e.g., "+12")
  String get formattedMonthlyProgress {
    return monthlyProgress >= 0 ? '+$monthlyProgress' : '$monthlyProgress';
  }

  /// Formatted activity trend with sign (e.g., "+15%")
  String? get formattedActivityTrend {
    if (activityTrendPercent == null) return null;
    final trend = activityTrendPercent!;
    final sign = trend >= 0 ? '+' : '';
    return '$sign${trend.toStringAsFixed(0)}%';
  }

  /// Trend direction: 1 for up, -1 for down, 0 for neutral
  int get trendDirection {
    if (activityTrendPercent == null) return 0;
    if (activityTrendPercent! > 0) return 1;
    if (activityTrendPercent! < 0) return -1;
    return 0;
  }

  @override
  UserStatsModel fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      streakDays: json['streakDays'] as int? ?? 0,
      totalWorkouts: json['totalWorkouts'] as int? ?? 0,
      totalTimeMinutes: json['totalTimeMinutes'] as int? ?? 0,
      monthlyProgress: json['monthlyProgress'] as int? ?? 0,
      mostPerformedExercise: json['mostPerformedExercise']?['name'] as String?,
      mostPerformedCount: json['mostPerformedExercise']?['count'] as int?,
      averageDurationMinutes: json['averageDurationMinutes'] as int?,
      activityTrendPercent: (json['activityTrendPercent'] as num?)?.toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'streakDays': streakDays,
      'totalWorkouts': totalWorkouts,
      'totalTimeMinutes': totalTimeMinutes,
      'monthlyProgress': monthlyProgress,
      if (mostPerformedExercise != null)
        'mostPerformedExercise': {
          'name': mostPerformedExercise,
          'count': mostPerformedCount,
        },
      if (averageDurationMinutes != null)
        'averageDurationMinutes': averageDurationMinutes,
      if (activityTrendPercent != null)
        'activityTrendPercent': activityTrendPercent,
    };
  }

  /// Create empty stats for new users
  factory UserStatsModel.empty() {
    return UserStatsModel(
      streakDays: 0,
      totalWorkouts: 0,
      totalTimeMinutes: 0,
      monthlyProgress: 0,
    );
  }

  /// Create mock data for testing
  factory UserStatsModel.mock() {
    return UserStatsModel(
      streakDays: 14,
      totalWorkouts: 87,
      totalTimeMinutes: 2550, // 42.5 hours
      monthlyProgress: 12,
      mostPerformedExercise: 'Bench Press',
      mostPerformedCount: 24,
      averageDurationMinutes: 48,
      activityTrendPercent: 15.0,
    );
  }
}
