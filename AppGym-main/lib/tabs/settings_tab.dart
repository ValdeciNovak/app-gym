import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_gym/models/profile.dart';
import 'package:app_gym/screens/edit_profile_screen.dart';
import 'package:app_gym/controllers/theme_controller.dart';

class SettingsTab extends StatefulWidget {
  final ThemeController themeController;
  const SettingsTab({super.key, required this.themeController});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  static const _prefsKey = 'profile';
  Profile _profile = Profile();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefsKey);
    setState(() {
      _profile = json == null ? Profile() : Profile.fromJson(json);
      _loaded = true;
    });
  }

  String get _summary {
    final parts = <String>[];
    if (_profile.birthDate != null) {
      final d = _profile.birthDate!;
      parts.add(
          'Nasc.: ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}');
    }
    if (_profile.heightCm != null) {
      parts.add('Altura: ${_profile.heightCm!.toStringAsFixed(1)} cm');
    }
    if (_profile.weightKg != null) {
      parts.add('Peso: ${_profile.weightKg!.toStringAsFixed(1)} kg');
    }
    parts.add('Atividade: ${_profile.activity.label}');
    final bmi = _profile.bmi;
    if (bmi != null) parts.add('IMC: ${bmi.toStringAsFixed(1)}');
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Center(child: CircularProgressIndicator());

    final currentMode = widget.themeController.mode;

    // NÃO tem Scaffold aqui! Apenas o conteúdo da aba.
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Informações pessoais'),
            subtitle: Text(_summary),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final updated = await Navigator.push<Profile>(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
              if (updated != null) setState(() => _profile = updated);
            },
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          value: true,
          onChanged: (_) {},
          title: const Text('Notificações de treino'),
          subtitle: const Text('Lembretes e avisos'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.color_lens_outlined),
          title: const Text('Tema'),
          subtitle: Text(
            currentMode == ThemeMode.dark
                ? 'Escuro'
                : currentMode == ThemeMode.light
                ? 'Claro'
                : 'Sistema',
          ),
          trailing: DropdownButton<ThemeMode>(
            value: currentMode,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: ThemeMode.system, child: Text('Sistema')),
              DropdownMenuItem(value: ThemeMode.light, child: Text('Claro')),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('Escuro')),
            ],
            onChanged: (value) {
              if (value != null) {
                widget.themeController.update(value);
                setState(() {});
              }
            },
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Sair'),
          onTap: () => Navigator.pushNamedAndRemoveUntil(
              context, '/login', (r) => false),
        ),
      ],
    );
  }
}
