import 'package:flutter/foundation.dart';
import '../models/performed_workout.dart';
import '../models/muscle_group.dart';

class TrainingController extends ChangeNotifier {
  final List<PerformedWorkout> _sessions = [];

  List<PerformedWorkout> get sessions => List.unmodifiable(_sessions);

  void addSession(PerformedWorkout s) {
    _sessions.add(s);
    notifyListeners();
  }

  void addSessions(List<PerformedWorkout> list) {
    _sessions.addAll(list);
    notifyListeners();
  }

  /// Tempo total (minutos) por grupo muscular nos últimos 7 dias
  Map<MuscleGroup, double> weeklyMinutesByGroup() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final map = {for (final g in MuscleGroup.values) g: 0.0};

    for (final s in _sessions) {
      final end = s.end.toLocal();
      final inRange = end.isAfter(weekAgo) && !end.isAfter(now);
      if (inRange && s.group != null) {
        map[s.group!] = (map[s.group!] ?? 0) + (s.duration.inSeconds / 60.0);
      }
    }

    return map;
  }

  /// Peso total (repetições × peso) por grupo muscular
  Map<MuscleGroup, double> totalWeightByGroup() {
    final map = {for (final g in MuscleGroup.values) g: 0.0};

    for (final s in _sessions) {
      if (s.group != null) {
        double total = 0;
        for (final ex in s.exercises) {
          for (final serie in ex.series) {
            final peso = double.tryParse(serie['peso'] ?? '');
            final reps = int.tryParse(serie['reps'] ?? '');
            if (peso != null && reps != null) total += peso * reps;
          }
        }
        map[s.group!] = (map[s.group!] ?? 0) + total;
      }
    }

    return map;
  }

}
