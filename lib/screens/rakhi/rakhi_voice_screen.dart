import 'package:flutter/material.dart';
import 'package:rakhi_app/core/constants/app_colors.dart';
import 'package:rakhi_app/core/api/api_client.dart';

class RakhiVoiceScreen extends StatefulWidget {
  const RakhiVoiceScreen({super.key});

  @override
  State<RakhiVoiceScreen> createState() => _RakhiVoiceScreenState();
}

class _RakhiVoiceScreenState extends State<RakhiVoiceScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isMuted = false;
  bool _isConnecting = true;
  bool _isEmergency = false;
  bool _isFallback = false;
  String _fallbackMessage = '';

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _startCall();
  }

  void _setupAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  Future<void> _startCall() async {
    try {
      final response = await ApiClient.startVoiceCall();
      if (response.statusCode == 200) {
        setState(() => _isConnecting = false);
      } else {
        _showError('Failed to start call');
      }
    } catch (e) {
      _showError('Connection failed');
    }
  }

  void _showFallback(String message) {
    setState(() {
      _isFallback = true;
      _fallbackMessage = message;
    });
  }

  void _retryConnection() {
    setState(() {
      _isFallback = false;
      _isConnecting = true;
    });
    _startCall();
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
  }

  void _endCall() {
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getStatusText() {
    if (_isEmergency) return 'Please seek immediate medical help';
    if (_isFallback) return _fallbackMessage;
    if (_isConnecting) return 'Calling Rakhi...';
    return 'Connected';
  }

  Widget _buildEmergencyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.emergency, color: AppColors.white, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'MEDICAL EMERGENCY DETECTED',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade600,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: AppColors.white, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Service Issue',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: _retryConnection,
            child: const Text(
              'Retry',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    if (_isEmergency) {
      return FloatingActionButton.extended(
        onPressed: _endCall,
        backgroundColor: Colors.red.shade700,
        icon: const Icon(Icons.call_end, color: AppColors.white),
        label: const Text(
          'END CALL',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton(
          onPressed: _toggleMute,
          backgroundColor: _isMuted ? Colors.red : AppColors.white,
          child: Icon(
            _isMuted ? Icons.mic_off : Icons.mic,
            color: _isMuted ? AppColors.white : AppColors.primary,
          ),
        ),
        FloatingActionButton(
          onPressed: _endCall,
          backgroundColor: Colors.red,
          child: const Icon(
            Icons.call_end,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isEmergency ? Colors.red : AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            if (_isEmergency) _buildEmergencyBanner(),
            if (_isFallback) _buildFallbackBanner(),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.white.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isEmergency ? Icons.warning : Icons.favorite,
                          size: 100,
                          color: _isEmergency ? Colors.red : AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Text(
              _getStatusText(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 60),
            _buildCallControls(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}