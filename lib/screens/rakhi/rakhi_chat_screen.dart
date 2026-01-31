import 'package:flutter/material.dart';
import 'package:rakhi_app/core/constants/app_colors.dart';

class RakhiChatScreen extends StatelessWidget {
  const RakhiChatScreen({super.key});

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
              'Rakhi Chat Interface\n(Health Coach)',
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