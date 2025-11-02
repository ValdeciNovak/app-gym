import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/theme_controller.dart';
import 'controllers/training_controller.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ThemeController _theme = ThemeController()..load();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrainingController(),
      child: AnimatedBuilder(
        animation: _theme,
        builder: (_, __) {
          return MaterialApp(
            title: 'App Gym',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.teal,
              brightness: Brightness.dark,
            ),
            themeMode: _theme.mode,
            initialRoute: '/login',
            routes: {
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/home': (_) => HomeScreen(themeController: _theme),
            },
          );
        },
      ),
    );
  }
}
