import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _prefsKey = 'profile';

  final _formKey = GlobalKey<FormState>();
  DateTime? _birthDate;
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  ActivityLevel _activity = ActivityLevel.normal;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefsKey);
    if (json != null) {
      final p = Profile.fromJson(json);
      _birthDate = p.birthDate;
      if (p.weightKg != null) _weightCtrl.text = p.weightKg!.toStringAsFixed(1);
      if (p.heightCm != null) _heightCtrl.text = p.heightCm!.toStringAsFixed(1);
      _activity = p.activity;
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final profile = Profile(
      birthDate: _birthDate,
      weightKg: _weightCtrl.text.isEmpty
          ? null
          : double.tryParse(_weightCtrl.text.replaceAll(',', '.')),
      heightCm: _heightCtrl.text.isEmpty
          ? null
          : double.tryParse(_heightCtrl.text.replaceAll(',', '.')),
      activity: _activity,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, profile.toJson());
    if (!mounted) return;
    Navigator.pop(context, profile);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Informações salvas')));
  }

  Future<void> _pickBirthDate() async {
    final initial = _birthDate ?? DateTime(2000, 1, 1);
    final first = DateTime(1900);
    final last = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: 'Selecione a data de nascimento',
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    String birthLabel =
    _birthDate == null ? 'Selecionar' : '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Informações pessoais')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.cake_outlined),
                  title: const Text('Data de nascimento'),
                  subtitle: Text(birthLabel),
                  onTap: _pickBirthDate,
                  trailing: const Icon(Icons.edit_calendar_outlined),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _weightCtrl,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Peso (kg)',
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                    hintText: 'ex.: 72.5',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final d = double.tryParse(v.replaceAll(',', '.'));
                    if (d == null || d <= 0) return 'Peso inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _heightCtrl,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Altura (cm)',
                    prefixIcon: Icon(Icons.height),
                    hintText: 'ex.: 175',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final d = double.tryParse(v.replaceAll(',', '.'));
                    if (d == null || d <= 0) return 'Altura inválida';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Quão ativo você é?',
                      style: Theme.of(context).textTheme.labelLarge),
                ),
                const SizedBox(height: 8),
                SegmentedButton<ActivityLevel>(
                  segments: const [
                    ButtonSegment(
                        value: ActivityLevel.low, label: Text('Pouco ativo')),
                    ButtonSegment(
                        value: ActivityLevel.normal, label: Text('Normal')),
                    ButtonSegment(
                        value: ActivityLevel.high, label: Text('Muito ativo')),
                  ],
                  selected: {_activity},
                  onSelectionChanged: (set) =>
                      setState(() => _activity = set.first),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
