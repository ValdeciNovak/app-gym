import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../models/workout.dart';
import '../controllers/training_controller.dart';
import '../screens/workout_session_screen.dart';
import '../adapters/title_to_group.dart';
import '../models/muscle_group.dart';
import '../data/exercises_catalog.dart';
import '../data/exercise_images.dart';

class WorkoutsTab extends StatefulWidget {
  const WorkoutsTab({super.key});

  @override
  State<WorkoutsTab> createState() => _WorkoutsTabState();
}

class _WorkoutsTabState extends State<WorkoutsTab> {
  final _prefsKey = 'workouts';
  final _weekNames = const {
    DateTime.monday: 'Seg',
    DateTime.tuesday: 'Ter',
    DateTime.wednesday: 'Qua',
    DateTime.thursday: 'Qui',
    DateTime.friday: 'Sex',
    DateTime.saturday: 'Sáb',
    DateTime.sunday: 'Dom',
  };

  List<Workout> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? [];
    setState(() {
      _items = list.map((e) => Workout.fromJson(e)).toList();
      _loading = false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _items.map((e) => e.toJson()).toList(),
    );
  }

  String _daysLabel(Set<int> days) {
    if (days.length == 7) return 'Todos os dias';
    if (days.isEmpty) return 'Sem dias definidos';
    final ordered = [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday,
    ].where(days.contains);
    return ordered.map((d) => _weekNames[d]!).join(' · ');
  }

  Future<void> _confirmDelete(int index) async {
    final item = _items[index];
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir treino'),
        content: Text('Tem certeza que deseja excluir "${item.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _items.removeAt(index));
      await _save();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Treino "${item.title}" removido')),
        );
      }
    }
  }

  void _showExerciseHelp(BuildContext ctx, String name) {
    final src = exerciseImages[name];

    showModalBottomSheet(
      context: ctx,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        Widget image;
        if (src == null) {
          image = const Icon(Icons.image_not_supported_outlined, size: 80);
        } else if (src.startsWith('http')) {
          image = Image.network(
            src,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          );
        } else {
          image = Image.asset(
            src,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          );
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
              AspectRatio(aspectRatio: 16 / 9, child: Center(child: image)),
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

  Future<void> _showAddOrEdit({Workout? initial, int? index}) async {
    // seleção de grupos (1..2)
    final selectedGroups = <MuscleGroup>{...(initial?.groups ?? [])};
    final selectedDays = <int>{...(initial?.days ?? <int>{})};
    final selectedExercises = <String>{...(initial?.exercises ?? [])};

    String _titleFromGroups(Iterable<MuscleGroup> gs) =>
        gs.map(muscleLabel).join(' + ');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // atualiza os exercícios visíveis conforme grupos selecionados
            final visibleCatalog = selectedGroups
                .expand((g) => exercisesCatalog[g] ?? const [])
                .toSet()
                .toList()
              ..sort();

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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          initial == null ? 'Novo treino' : 'Editar treino',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (initial != null)
                        IconButton(
                          tooltip: 'Excluir',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            Navigator.pop(context);
                            await _confirmDelete(index!);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Grupos musculares (máx. 2)',
                        style: Theme.of(context).textTheme.labelLarge),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final g in MuscleGroup.values)
                        FilterChip(
                          label: Text(muscleLabel(g)),
                          selected: selectedGroups.contains(g),
                          onSelected: (s) {
                            setModalState(() {
                              if (s) {
                                if (selectedGroups.length < 2) {
                                  selectedGroups.add(g);
                                }
                              } else {
                                selectedGroups.remove(g);
                                // desmarca exercícios que não pertencem mais
                                final keep = exercisesCatalog[g] ?? const [];
                                selectedExercises.removeWhere((e) => keep.contains(e));
                              }
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Dias da semana',
                        style: Theme.of(context).textTheme.labelLarge),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final day in [
                        DateTime.monday,
                        DateTime.tuesday,
                        DateTime.wednesday,
                        DateTime.thursday,
                        DateTime.friday,
                        DateTime.saturday,
                        DateTime.sunday,
                      ])
                        FilterChip(
                          label: Text(_weekNames[day]!),
                          selected: selectedDays.contains(day),
                          onSelected: (s) {
                            setModalState(() {
                              if (s) {
                                selectedDays.add(day);
                              } else {
                                selectedDays.remove(day);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Exercícios',
                        style: Theme.of(context).textTheme.labelLarge),
                  ),
                  const SizedBox(height: 8),
                  if (selectedGroups.isEmpty)
                    const Text('Selecione ao menos 1 grupo para ver exercícios.')
                  else
                    SizedBox(
                      height: 220,
                      child: Scrollbar(
                        child: ListView(
                          children: [
                            for (final ex in visibleCatalog)
                              CheckboxListTile(
                                value: selectedExercises.contains(ex),
                                title: Text(ex),
                                secondary: IconButton(
                                  tooltip: 'Como executar',
                                  icon: const Icon(Icons.help_outline),
                                  onPressed: () => _showExerciseHelp(context, ex),
                                ),
                                onChanged: (v) {
                                  setModalState(() {
                                    if (v == true) {
                                      selectedExercises.add(ex);
                                    } else {
                                      selectedExercises.remove(ex);
                                    }
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check),
                      label: Text(initial == null ? 'Adicionar' : 'Salvar'),
                      onPressed: selectedGroups.isEmpty
                          ? null
                          : () {
                        final title = _titleFromGroups(selectedGroups.toList());
                        final newItem = Workout(
                          title: title,
                          days: selectedDays.isEmpty ? {DateTime.monday} : selectedDays,
                          groups: selectedGroups.toList(),
                          exercises: selectedExercises.toList(),
                        );
                        setState(() {
                          if (index == null) {
                            _items.add(newItem);
                          } else {
                            _items[index] = newItem;
                          }
                        });
                        _save();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _startWorkout(BuildContext context, Workout item) {
    // se tiver 2 grupos, a sessão permite alternar entre eles
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutSessionScreen(workout: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TrainingController>();

    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: _items.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fitness_center, size: 64),
              const SizedBox(height: 12),
              const Text('Você ainda não montou seus treinos.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Toque no botão "+", escolha 1 ou 2 grupos e selecione exercícios.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final item = _items[i];
          return Dismissible(
            key: ValueKey('${item.title}-$i'),
            direction: DismissDirection.endToStart,
            onDismissed: (_) {
              setState(() => _items.removeAt(i));
              _save();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Treino "${item.title}" removido')),
              );
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.red.withOpacity(0.15),
              child: const Icon(Icons.delete_outline),
            ),
            child: Card(
              child: ListTile(
                title: Text(item.title),
                subtitle: Text(
                  '${_daysLabel(item.days)}'
                      '${item.exercises.isEmpty ? '' : '\nExercícios: ${item.exercises.join(', ')}'}',
                ),
                leading: const Icon(Icons.schedule_outlined),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'start') {
                      _startWorkout(context, item);
                    } else if (v == 'edit') {
                      _showAddOrEdit(initial: item, index: i);
                    } else if (v == 'delete') {
                      await _confirmDelete(i);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'start', child: Text('Iniciar agora')),
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Excluir')),
                  ],
                ),
                onTap: () => _startWorkout(context, item),
                onLongPress: () => _showAddOrEdit(initial: item, index: i),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEdit(),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
    );
  }
}
