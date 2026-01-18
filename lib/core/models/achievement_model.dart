import 'package:gym_track/core/base/base_model.dart';

/// Badge tier for achievements
enum BadgeTier {
  bronze,
  silver,
  gold,
}

/// Model for user achievements and badges
class AchievementModel extends BaseModel {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final BadgeTier tier;
  final bool unlocked;
  final DateTime? unlockedAt;
  final int? progressCurrent;
  final int? progressTarget;

  AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.tier,
    required this.unlocked,
    this.unlockedAt,
    this.progressCurrent,
    this.progressTarget,
  });

  /// Progress percentage (0-100)
  int? get progressPercent {
    if (progressCurrent == null ||
        progressTarget == null ||
        progressTarget == 0) {
      return null;
    }
    return ((progressCurrent! / progressTarget!) * 100).round().clamp(0, 100);
  }

  /// Whether the achievement is in progress but not unlocked
  bool get inProgress {
    return !unlocked && progressCurrent != null && progressCurrent! > 0;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'tier': tier.name,
      'unlocked': unlocked,
      if (unlockedAt != null) 'unlockedAt': unlockedAt!.toIso8601String(),
      if (progressCurrent != null) 'progressCurrent': progressCurrent,
      if (progressTarget != null) 'progressTarget': progressTarget,
    };
  }

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      iconName: json['iconName'] as String? ?? 'trophy',
      tier: BadgeTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => BadgeTier.bronze,
      ),
      unlocked: json['unlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      progressCurrent: json['progressCurrent'] as int?,
      progressTarget: json['progressTarget'] as int?,
    );
  }

  /// Create mock achievements for testing
  static List<AchievementModel> mockList() {
    return [
      AchievementModel(
        id: 'streak_7',
        name: '7-Day Streak',
        description: 'Complete workouts for 7 consecutive days',
        iconName: 'fire',
        tier: BadgeTier.bronze,
        unlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      AchievementModel(
        id: 'streak_30',
        name: '30-Day Streak',
        description: 'Complete workouts for 30 consecutive days',
        iconName: 'fire',
        tier: BadgeTier.silver,
        unlocked: false,
        progressCurrent: 14,
        progressTarget: 30,
      ),
      AchievementModel(
        id: 'streak_100',
        name: '100-Day Streak',
        description: 'Complete workouts for 100 consecutive days',
        iconName: 'fire',
        tier: BadgeTier.gold,
        unlocked: false,
        progressCurrent: 14,
        progressTarget: 100,
      ),
      AchievementModel(
        id: 'program_complete',
        name: 'Program Complete',
        description: 'Finish your first workout program',
        iconName: 'trophy',
        tier: BadgeTier.silver,
        unlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      AchievementModel(
        id: 'first_pr',
        name: 'First PR',
        description: 'Log your first personal record',
        iconName: 'lightning',
        tier: BadgeTier.bronze,
        unlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      AchievementModel(
        id: 'workout_50',
        name: '50 Workouts',
        description: 'Complete 50 total workouts',
        iconName: 'dumbbell',
        tier: BadgeTier.bronze,
        unlocked: false,
        progressCurrent: 87,
        progressTarget: 50,
      ),
    ];
  }
}
