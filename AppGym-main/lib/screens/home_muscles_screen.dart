import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/muscle_group.dart';
import '../models/performed_workout.dart';

class HomeMusclesScreen extends StatelessWidget {
  final List<PerformedWorkout> performed;

  const HomeMusclesScreen({super.key, required this.performed});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    final counts = <MuscleGroup, int>{};

    for (final s in performed) {
      final end = s.end;
      if (end.isBefore(start) || end.isAfter(now)) continue;
      if (s.group != null) {
        counts[s.group!] = (counts[s.group!] ?? 0) + 1;
      }
    }

    final labels = MuscleGroup.values.map(muscleLabel).toList();
    final values = MuscleGroup.values
        .map((g) => (counts[g] ?? 0).toDouble())
        .toList();

    final total = values.fold<double>(0, (a, b) => a + b);
    final hasData = total > 0;

    if (!hasData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pie_chart, size: 48),
              const SizedBox(height: 12),
              Text(
                'Sem treinos nos últimos 7 dias',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Grupos mais treinados (últimos 7 dias)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 32,
                sections: List.generate(values.length, (i) {
                  final v = values[i];
                  if (v <= 0) return null; // fl_chart não curte seções 0
                  return PieChartSectionData(
                    value: v,
                    title: '${v.toInt()}',
                    radius: 56,
                    titleStyle: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                     color: Theme.of(context).colorScheme.primary,
                  );
                }).whereType<PieChartSectionData>().toList(),
                pieTouchData: PieTouchData(
                  enabled: true,
                  touchCallback: (event, resp) {},
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 24,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: List.generate(values.length, (i) {
              if (values[i] == 0) return const SizedBox.shrink();
              final pct = (values[i] / total) * 100;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fiber_manual_record, size: 10),
                  const SizedBox(width: 6),
                  Text('${labels[i]}: ${values[i].toInt()}× (${pct.toStringAsFixed(0)}%)'),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
