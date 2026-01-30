import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'core/constants/app_colors.dart';

void main() {
  runApp(const RakhiApp());
}

class RakhiApp extends StatelessWidget {
  const RakhiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rakhi AI Health Coach',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
