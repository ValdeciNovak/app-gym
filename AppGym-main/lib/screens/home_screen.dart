import 'package:flutter/material.dart';
import 'package:app_gym/controllers/theme_controller.dart';
import 'package:app_gym/tabs/workouts_tab.dart';
import 'package:app_gym/tabs/settings_tab.dart';
import 'package:app_gym/tabs/summary_tab.dart';

class HomeScreen extends StatefulWidget {
  final ThemeController themeController;
  const HomeScreen({super.key, required this.themeController});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _index == 0 ? 'Treinos'
              : _index == 1 ? 'Resumo de Treinos'
              : 'Configurações',
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: [
          const WorkoutsTab(),
          const WorkoutSummaryScreen(),
          SettingsTab(themeController: widget.themeController),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Treinos',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Resumo',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}
