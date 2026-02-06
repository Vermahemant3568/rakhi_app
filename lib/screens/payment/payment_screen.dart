import 'package:flutter/material.dart';
import 'package:rakhi_app/core/constants/app_colors.dart';
import 'package:rakhi_app/core/api/api_client.dart';
import 'package:rakhi_app/screens/rakhi/rakhi_chat_screen.dart';

class PaymentScreen extends StatefulWidget {
  final bool isTrial;
  
  const PaymentScreen({super.key, this.isTrial = false});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    try {
      if (widget.isTrial) {
        // Trial payment flow
        final orderResponse = await ApiClient.createTrialOrder({});
        if (orderResponse.statusCode == 200) {
          await _simulateRazorpayPayment(orderResponse.data);
        } else {
          _showError(orderResponse.data['error'] ?? 'Failed to create order');
        }
      } else {
        // Subscription payment flow
        final subscriptionResponse = await ApiClient.createSubscription({});
        if (subscriptionResponse.statusCode == 200) {
          await _simulateRazorpaySubscription(subscriptionResponse.data);
        } else {
          _showError(subscriptionResponse.data['error'] ?? 'Failed to create subscription');
        }
      }
    } catch (e) {
      _showError('Payment failed. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _simulateRazorpayPayment(Map<String, dynamic> orderData) async {
    final paymentData = {
      'razorpay_order_id': orderData['order_id'] ?? 'order_test_123',
      'razorpay_payment_id': 'pay_test_123',
      'razorpay_signature': 'signature_test_123',
    };

    final verifyResponse = await ApiClient.verifyTrialPayment(paymentData);
    if (verifyResponse.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RakhiChatScreen()),
      );
    } else {
      _showError(verifyResponse.data['error'] ?? 'Payment verification failed');
    }
  }

  Future<void> _simulateRazorpaySubscription(Map<String, dynamic> subscriptionData) async {
    final verificationData = {
      'razorpay_subscription_id': subscriptionData['subscription_id'] ?? 'sub_test_123',
      'razorpay_payment_id': 'pay_test_123',
      'razorpay_signature': 'signature_test_123',
    };

    final verifyResponse = await ApiClient.verifySubscription(verificationData);
    if (verifyResponse.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RakhiChatScreen()),
      );
    } else {
      _showError(verifyResponse.data['error'] ?? 'Subscription verification failed');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
              children: [
                const SizedBox(height: 40),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: AppColors.white),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    widget.isTrial ? Icons.timer : Icons.subscriptions,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  widget.isTrial ? 'Start 7-Day Trial' : 'Continue Rakhi Premium',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.isTrial ? '₹7 now, ₹299/month after trial' : '₹299/month, auto-pay',
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textWhite70,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: AppColors.primary)
                        : Text(
                            widget.isTrial ? 'Pay ₹7' : 'Subscribe',
                            style: const TextStyle(
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