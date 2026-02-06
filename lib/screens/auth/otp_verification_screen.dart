import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rakhi_app/core/constants/app_colors.dart';
import 'package:rakhi_app/core/api/api_client.dart';
import 'package:rakhi_app/screens/onboarding/intro_screen.dart';
import 'package:rakhi_app/screens/rakhi/rakhi_chat_screen.dart';
import 'package:rakhi_app/screens/payment/payment_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String mobileNumber;
  
  const OtpVerificationScreen({super.key, required this.mobileNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verify OTP',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the OTP sent to +91 ${widget.mobileNumber}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: AppColors.white)
                    : const Text(
                        'Verify OTP',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.verifyOtp(widget.mobileNumber, _otpController.text);
      
      if (response.statusCode == 200) {
        _handleOtpVerificationSuccess(response.data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.data['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify OTP: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleOtpVerificationSuccess(Map<String, dynamic> response) {
    final data = response['data'];
    final bool isOnboarded = data['is_onboarded'] ?? false;
    final String subscriptionStatus = data['subscription_status'] ?? 'none';
    
    // Route based on user status
    if (!isOnboarded) {
      // NEW USER - Start onboarding flow
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const IntroScreen()),
      );
    } else if (subscriptionStatus == 'active' || subscriptionStatus == 'trial') {
      // EXISTING USER WITH ACTIVE SUBSCRIPTION - Go to chat
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RakhiChatScreen()),
      );
    } else {
      // EXISTING USER WITH EXPIRED/NO SUBSCRIPTION - Go to payment
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PaymentScreen()),
      );
    }
  }
}