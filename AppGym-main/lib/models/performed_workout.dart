import 'muscle_group.dart';

class PerformedWorkout {
  final DateTime start;
  final DateTime end;
  final MuscleGroup? group;
  final List<PerformedExercise> exercises; // 👈 novo

  PerformedWorkout({
    required this.start,
    required this.end,
    required this.group,
    this.exercises = const [],
  });

  Duration get duration => end.difference(start);
}

class PerformedExercise {
  final String name;
  final List<Map<String, String>> series; // [{peso: '50', reps: '10'}, ...]

  PerformedExercise({
    required this.name,
    required this.series,
  });
}
