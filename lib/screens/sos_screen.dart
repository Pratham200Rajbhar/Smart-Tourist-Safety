import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../blocs/tourist_bloc.dart';
import '../models/demo_data.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> with TickerProviderStateMixin {
  bool _isCountingDown = false;
  bool _isSOSSent = false;
  int _countdown = 3;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    if (_isCountingDown || _isSOSSent) return;

    setState(() {
      _isCountingDown = true;
      _countdown = 3;
    });

    HapticFeedback.mediumImpact();
    _countdownTimer();
  }

  void _countdownTimer() async {
    while (_countdown > 0 && _isCountingDown) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isCountingDown) {
        setState(() {
          _countdown--;
        });
        HapticFeedback.lightImpact();
      }
    }

    if (_countdown == 0 && _isCountingDown && mounted) {
      _sendSOS();
    }
  }

  void _sendSOS() {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    final currentTourist = DemoData.currentTourist;
    context.read<TouristBloc>().add(SendSOS(currentTourist.lat, currentTourist.lng));
  }

  void _cancelCountdown() {
    setState(() {
      _isCountingDown = false;
      _countdown = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<TouristBloc, TouristState>(
        listener: (context, state) {
          if (state is SOSSent) {
            setState(() {
              _isSOSSent = true;
            });
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Main Content
                if (!_isSOSSent && !_isCountingDown) _buildInitialView(),
                if (_isCountingDown) _buildCountdownView(),
                if (_isSOSSent) _buildConfirmationView(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialView() {
    return Column(
      children: [
        // Info Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade300),
          ),
          child: const Column(
            children: [
              Icon(Icons.emergency, size: 60, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Emergency SOS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Press and hold the button below to send an emergency alert',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Info List
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: const Column(
            children: [
              Text(
                'What happens when you send SOS:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text('📍', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  Expanded(child: Text('Your location will be shared')),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text('🚨', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  Expanded(child: Text('Local authorities will be alerted')),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text('🆔', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  Expanded(child: Text('Your digital ID will be included')),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        
        // SOS Button
        ScaleTransition(
          scale: _pulseAnimation,
          child: GestureDetector(
            onLongPress: _startCountdown,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emergency, size: 50, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'HOLD TO\nSEND SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCountdownView() {
    return Column(
      children: [
        const SizedBox(height: 40),
        
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 15,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _countdown.toString(),
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'SENDING SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Column(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 40),
              SizedBox(height: 12),
              Text(
                'Emergency Alert Active',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your location and details are being sent to emergency services',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 30),
        
        ElevatedButton(
          onPressed: _cancelCountdown,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            minimumSize: const Size(200, 50),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildConfirmationView() {
    final currentTourist = DemoData.currentTourist;
    final timestamp = DateTime.now();
    
    return Column(
      children: [
        const SizedBox(height: 20),
        
        // Success Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(Icons.check, size: 60, color: Colors.white),
        ),
        
        const SizedBox(height: 20),
        
        const Text(
          'SOS Sent Successfully! ✅',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        const Text(
          'Emergency alert has been sent to local authorities',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 30),
        
        // Alert Details
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alert Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('👤', 'Tourist Name', currentTourist.name),
              _buildDetailRow('🆔', 'Digital ID', currentTourist.digitalId),
              _buildDetailRow('📍', 'Location', '${currentTourist.lat.toStringAsFixed(4)}, ${currentTourist.lng.toStringAsFixed(4)}'),
              _buildDetailRow('⏰', 'Timestamp', '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')} - ${timestamp.day}/${timestamp.month}/${timestamp.year}'),
              _buildDetailRow('🚨', 'Severity', 'HIGH PRIORITY'),
            ],
          ),
        ),
        
        const SizedBox(height: 30),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 50),
            ),
            child: const Text(
              'Back to Dashboard',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildDetailRow(String icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}