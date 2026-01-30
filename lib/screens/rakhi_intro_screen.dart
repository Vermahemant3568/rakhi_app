import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class RakhiIntroScreen extends StatelessWidget {
  const RakhiIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.primaryGradient,
          ),
        ),
        child: const SafeArea(
          child: Center(
            child: Text(
              'Rakhi Intro Screen\n(Onboarding)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}