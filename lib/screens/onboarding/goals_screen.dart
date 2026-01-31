import 'package:flutter/material.dart';
import 'package:rakhi_app/core/constants/app_colors.dart';
import 'package:rakhi_app/core/api/api_client.dart';
import 'package:rakhi_app/screens/payment/payment_screen.dart';

class GoalsScreen extends StatefulWidget {
  final String language;
  final String firstName;
  final String lastName;
  final String gender;
  final DateTime dob;
  final int height;
  final int weight;
  
  const GoalsScreen({
    super.key,
    required this.language,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dob,
    required this.height,
    required this.weight,
  });

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<dynamic> _goals = [];
  List<String> _selectedGoals = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final response = await ApiClient.getGoals();
    if (response.statusCode == 200) {
      setState(() {
        _goals = response.data['data'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load goals: ${response.data['error'] ?? 'Unknown error'}')),
      );
    }
  }

  Future<void> _submitOnboarding() async {
    setState(() => _isSubmitting = true);

    final data = {
      'first_name': widget.firstName,
      'last_name': widget.lastName,
      'gender': widget.gender.toLowerCase(),
      'dob': '${widget.dob.year}-${widget.dob.month.toString().padLeft(2, '0')}-${widget.dob.day.toString().padLeft(2, '0')}',
      'height_cm': widget.height.toDouble(),
      'weight_kg': widget.weight.toDouble(),
      'language_id': int.parse(widget.language),
      'goal_ids': _selectedGoals.map((id) => int.parse(id)).toList(),
    };

    try {
      final response = await ApiClient.submitOnboarding(data);
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PaymentScreen(isTrial: true),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit onboarding: ${response.data['error'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: AppColors.white),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Health Goals',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select your health goals',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textWhite70,
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.white))
                      : ListView.builder(
                          itemCount: _goals.length,
                          itemBuilder: (context, index) {
                            final goal = _goals[index];
                            final goalId = goal['id']?.toString() ?? '';
                            final isSelected = _selectedGoals.contains(goalId);
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(
                                  goal['name'] ?? '',
                                  style: const TextStyle(color: AppColors.white),
                                ),
                                leading: Checkbox(
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedGoals.add(goalId);
                                      } else {
                                        _selectedGoals.remove(goalId);
                                      }
                                    });
                                  },
                                  activeColor: AppColors.white,
                                  checkColor: AppColors.primary,
                                ),
                                tileColor: isSelected 
                                    ? AppColors.white.withOpacity(0.2)
                                    : AppColors.white.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedGoals.remove(goalId);
                                    } else {
                                      _selectedGoals.add(goalId);
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedGoals.isNotEmpty && !_isSubmitting
                        ? _submitOnboarding
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: AppColors.primary)
                        : const Text(
                            'Complete Setup',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}