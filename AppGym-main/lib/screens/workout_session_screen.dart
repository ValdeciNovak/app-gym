/*
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/training_controller.dart';
import '../models/workout.dart';
import '../models/muscle_group.dart';
import '../models/muscle_group.dart' show muscleLabel;
import '../models/performed_workout.dart';
import '../data/exercise_images.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final Workout workout;
  final MuscleGroup initialGroup;

  const WorkoutSessionScreen({
    super.key,
    required this.workout,
    required this.initialGroup,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late final List<MuscleGroup> _allowedGroups;
  late MuscleGroup _activeGroup;

  DateTime? _sessionStart;
  DateTime? _segmentStart;
  Timer? _ticker;

  final Map<MuscleGroup, Duration> _accum = {
    for (final g in MuscleGroup.values) g: Duration.zero
  };

  final List<PerformedWorkout> _segments = [];

  @override
  void initState() {
    super.initState();
    _allowedGroups = widget.workout.groups.isNotEmpty
        ? widget.workout.groups
        : [widget.initialGroup];
    _activeGroup = _allowedGroups.first;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    if (_sessionStart != null) return;
    final now = DateTime.now();
    _sessionStart = now;
    _segmentStart = now;

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _switchGroup(MuscleGroup newGroup) {
    if (_segmentStart == null) return;
    final now = DateTime.now();

    final elapsed = now.difference(_segmentStart!);
    _accum[_activeGroup] = (_accum[_activeGroup] ?? Duration.zero) + elapsed;

    _segments.add(PerformedWorkout(
      start: _segmentStart!,
      end: now,
      group: _activeGroup,
    ));

    _activeGroup = newGroup;
    _segmentStart = now;
    setState(() {});
  }

  void _stopAndSave(TrainingController c) {
    _ticker?.cancel();

    if (_segmentStart != null) {
      final now = DateTime.now();
      final elapsed = now.difference(_segmentStart!);

      _accum[_activeGroup] = (_accum[_activeGroup] ?? Duration.zero) + elapsed;

      _segments.add(PerformedWorkout(
        start: _segmentStart!,
        end: now,
        group: _activeGroup,
      ));

      _segmentStart = null;
    }

    if (_segments.isNotEmpty) {
      c.addSessions(_segments);
      final total = _totalElapsed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sessão salva • ${total.inMinutes} min')),
      );
    }

    Navigator.pop(context);
  }

  Duration get _totalElapsed {
    if (_sessionStart == null) return Duration.zero;
    final running = _segmentStart != null;
    final fixed = _accum.values.fold<Duration>(Duration.zero, (a, b) => a + b);
    if (!running) return fixed;
    return fixed + DateTime.now().difference(_segmentStart!);
  }

  Duration groupElapsed(MuscleGroup g) {
    final base = _accum[g] ?? Duration.zero;
    if (_segmentStart != null && g == _activeGroup) {
      return base + DateTime.now().difference(_segmentStart!);
    }
    return base;
  }

  // --- POPUP DE EXERCÍCIO ---
  void _showExerciseHelp(String name) {
    final src = exerciseImages[name];

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        Widget image;
        if (src == null) {
          image = const Icon(Icons.image_not_supported_outlined, size: 80);
        } else if (src.startsWith('http')) {
          image = Image.network(src, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
        } else {
          image = Image.asset(src, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16, right: 16, top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Center(child: image),
              ),
              const SizedBox(height: 12),
              Text(
                'Dica: mantenha a técnica correta e ajuste a carga conforme seu nível.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TrainingController>();
    final running = _sessionStart != null;

    return Scaffold(
      appBar: AppBar(title: Text(widget.workout.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.workout.exercises.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Exercícios', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: -8,
                        children: [
                          for (final ex in widget.workout.exercises)
                            InkWell(
                              onTap: () => _showExerciseHelp(ex),
                              borderRadius: BorderRadius.circular(20),
                              child: Chip(
                                label: Text(ex),
                                avatar: const Icon(Icons.help_outline, size: 18),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Grupo ativo', style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _allowedGroups.map((g) {
                final selected = g == _activeGroup;
                return ChoiceChip(
                  label: Text(muscleLabel(g)),
                  selected: selected,
                  onSelected: (s) {
                    if (!s) return;
                    if (!running) {
                      setState(() => _activeGroup = g);
                    } else if (g != _activeGroup) {
                      _switchGroup(g);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('Tempo por grupo', style: Theme.of(context).textTheme.titleSmall),
                        const Spacer(),
                        Text(_fmt(_totalElapsed), style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._allowedGroups.map((g) => _GroupTimeRow(
                      label: muscleLabel(g),
                      d: groupElapsed(g),
                      highlight: g == _activeGroup,
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!running)
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar sessão'),
                onPressed: _start,
              )
            else
              FilledButton.icon(
                icon: const Icon(Icons.stop),
                label: const Text('Encerrar e salvar'),
                onPressed: () => _stopAndSave(controller),
              ),
            const Spacer(),
            Text('Dica: toque no nome do exercício para ver a execução.'),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _GroupTimeRow extends StatelessWidget {
  final String label;
  final Duration d;
  final bool highlight;

  const _GroupTimeRow({
    required this.label,
    required this.d,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.fiber_manual_record, size: 10,
              color: highlight ? Theme.of(context).colorScheme.primary : null),
          const SizedBox(width: 6),
          Expanded(child: Text(label, style: style)),
          Text(_fmt(d), style: style),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
*/
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/training_controller.dart';
import '../models/workout.dart';
import '../models/performed_workout.dart';
import '../data/exercise_images.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutSessionScreen({super.key, required this.workout});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  DateTime? _sessionStart;
  Timer? _ticker;
  bool _isPaused = false;

  final List<Map<String, dynamic>> _exerciseData = [];

  @override
  void initState() {
    super.initState();
    _exerciseData.addAll(widget.workout.exercises.map((e) => {
      'name': e,
      'series': [
        {'peso': '', 'reps': ''},
      ],
    }));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    if (_sessionStart != null && !_isPaused) return;
    if (_sessionStart == null) _sessionStart = DateTime.now();

    _isPaused = false;
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!_isPaused) setState(() {});
    });
    setState(() {});
  }

  void _pause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _stopAndSave(TrainingController c) {
    _ticker?.cancel();

    final now = DateTime.now();
    final total = now.difference(_sessionStart ?? now);

    // Monta os exercícios realizados
    final performedExercises = _exerciseData.map((ex) {
      return PerformedExercise(
        name: ex['name'],
        series: List<Map<String, String>>.from(ex['series']),
      );
    }).toList();

    // Salva o treino com grupo e exercícios
    c.addSessions([
      PerformedWorkout(
        start: _sessionStart ?? now,
        end: now,
        group: widget.workout.groups.first, // ✅ grupo definido no Workout
        exercises: performedExercises, // ✅ adiciona dados reais
      ),
    ]);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sessão salva • ${total.inMinutes} min')),
    );

    Navigator.pop(context);
  }


  Duration get _totalElapsed {
    if (_sessionStart == null) return Duration.zero;
    return DateTime.now().difference(_sessionStart!);
  }

  void _addSerie(int index) {
    setState(() {
      _exerciseData[index]['series'].add({'peso': '', 'reps': ''});
    });
  }

  void _showExerciseHelp(String name) {
    final src = exerciseImages[name];

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        Widget image;
        if (src == null) {
          image = const Icon(Icons.image_not_supported_outlined, size: 80);
        } else if (src.startsWith('http')) {
          image = Image.network(src, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
        } else {
          image = Image.asset(src, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Center(child: image),
              ),
              const SizedBox(height: 12),
              Text(
                'Dica: mantenha a técnica correta e ajuste a carga conforme seu nível.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TrainingController>();
    final running = _sessionStart != null;
    final isActive = running && !_isPaused;

    return Scaffold(
      appBar: AppBar(title: Text(widget.workout.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _exerciseData.length,
                itemBuilder: (context, index) {
                  final ex = _exerciseData[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(ex['name'],
                                    style:
                                    Theme.of(context).textTheme.titleMedium),
                              ),
                              IconButton(
                                icon: const Icon(Icons.help_outline),
                                onPressed: () =>
                                    _showExerciseHelp(ex['name']),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(ex['series'].length, (sIndex) {
                            final serie = ex['series'][sIndex];
                            return Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      enabled: isActive,
                                      decoration: const InputDecoration(
                                        labelText: 'Peso (kg)',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (v) =>
                                      serie['peso'] = v.trim(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      enabled: isActive,
                                      decoration: const InputDecoration(
                                        labelText: 'Repetições',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (v) =>
                                      serie['reps'] = v.trim(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _addSerie(index),
                              icon: const Icon(Icons.add),
                              label: const Text('Adicionar série'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text('Tempo de treino:',
                        style: Theme.of(context).textTheme.titleSmall),
                    const Spacer(),
                    Text(_fmt(_totalElapsed),
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (!running)
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar sessão'),
                onPressed: _start,
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                    label: Text(_isPaused ? 'Retomar' : 'Pausar'),
                    onPressed: _pause,
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    icon: const Icon(Icons.stop),
                    label: const Text('Encerrar e salvar'),
                    onPressed: () => _stopAndSave(controller),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
