import 'dart:convert';
import 'muscle_group.dart';
import '../adapters/title_to_group.dart';

class Workout {
  final String title;         // texto exibido (ex.: "Peito + Tríceps")
  final Set<int> days;        // 1=Seg ... 7=Dom
  final List<MuscleGroup> groups;   // NOVO: 1..n grupos
  final List<String> exercises;     // NOVO: nomes dos exercícios

  Workout({
    required this.title,
    required this.days,
    required this.groups,
    required this.exercises,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'days': days.toList(),
    'groups': groups.map((g) => g.name).toList(),
    'exercises': exercises,
  };

  factory Workout.fromMap(Map<String, dynamic> map) {
    // retrocompatibilidade: se não houver 'groups', inferimos pelo título
    final inferredGroups = map['groups'] != null
        ? (map['groups'] as List)
        .map((e) => MuscleGroup.values.firstWhere(
          (g) => g.name == e,
      orElse: () => mapTitleToGroup(map['title'] as String),
    ))
        .toList()
        : _inferGroupsFromTitle(map['title'] as String);

    return Workout(
      title: map['title'] as String,
      days: Set<int>.from((map['days'] as List).map((e) => e as int)),
      groups: inferredGroups,
      exercises:
      (map['exercises'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }

  String toJson() => jsonEncode(toMap());
  factory Workout.fromJson(String src) =>
      Workout.fromMap(jsonDecode(src) as Map<String, dynamic>);

  static List<MuscleGroup> _inferGroupsFromTitle(String title) {
    // aceita 1..n grupos com base no texto
    final t = title.toLowerCase();
    final map = {
      'peito': MuscleGroup.peito,
      'chest': MuscleGroup.peito,
      'costas': MuscleGroup.costas,
      'back': MuscleGroup.costas,
      'ombro': MuscleGroup.ombros,
      'should': MuscleGroup.ombros,
      'bíceps': MuscleGroup.biceps,
      'biceps': MuscleGroup.biceps,
      'tríceps': MuscleGroup.triceps,
      'triceps': MuscleGroup.triceps,
      'perna': MuscleGroup.pernas,
      'legs': MuscleGroup.pernas,
      'glúte': MuscleGroup.gluteos,
      'glute': MuscleGroup.gluteos,
      'abdô': MuscleGroup.abdomen,
      'abdom': MuscleGroup.abdomen,
      'core': MuscleGroup.abdomen,
      'abs': MuscleGroup.abdomen,
    };
    final result = <MuscleGroup>{};
    map.forEach((k, v) {
      if (t.contains(k)) result.add(v);
    });
    return result.isEmpty ? [mapTitleToGroup(title)] : result.toList();
  }
}
