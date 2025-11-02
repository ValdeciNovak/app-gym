import 'dart:convert';

enum ActivityLevel { low, normal, high }

extension ActivityLevelX on ActivityLevel {
  String get label {
    switch (this) {
      case ActivityLevel.low:
        return 'Pouco ativo';
      case ActivityLevel.normal:
        return 'Normal';
      case ActivityLevel.high:
        return 'Muito ativo';
    }
  }

  static ActivityLevel fromLabel(String label) {
    switch (label) {
      case 'Pouco ativo':
        return ActivityLevel.low;
      case 'Muito ativo':
        return ActivityLevel.high;
      default:
        return ActivityLevel.normal;
    }
  }
}

class Profile {
  final DateTime? birthDate;
  final double? weightKg;
  final double? heightCm;
  final ActivityLevel activity;

  Profile({
    this.birthDate,
    this.weightKg,
    this.heightCm,
    this.activity = ActivityLevel.normal,
  });

  Map<String, dynamic> toMap() => {
    'birthDate': birthDate?.toIso8601String(),
    'weightKg': weightKg,
    'heightCm': heightCm,
    'activity': activity.name,
  };

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
    birthDate: map['birthDate'] != null
        ? DateTime.tryParse(map['birthDate'] as String)
        : null,
    weightKg: (map['weightKg'] as num?)?.toDouble(),
    heightCm: (map['heightCm'] as num?)?.toDouble(),
    activity: ActivityLevel.values.firstWhere(
          (e) => e.name == (map['activity'] as String? ?? 'normal'),
      orElse: () => ActivityLevel.normal,
    ),
  );

  String toJson() => jsonEncode(toMap());
  factory Profile.fromJson(String src) =>
      Profile.fromMap(jsonDecode(src) as Map<String, dynamic>);

  double? get bmi {
    if (weightKg == null || heightCm == null || heightCm == 0) return null;
    final h = (heightCm! / 100.0);
    return weightKg! / (h * h);
  }
}
