import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _canCancel = true;
  int _countdown = 10; // Changed to 10 seconds
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _emergencyController;
  late Animation<double> _emergencyAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000), // Slower animation
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate( // Smaller scale change
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _emergencyController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _emergencyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _emergencyController, curve: Curves.elasticOut),
    );
    
    // Remove the automatic pulse animation to make it less distracting
    // _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    if (_isCountingDown || _isSOSSent) return;

    setState(() {
      _isCountingDown = true;
      _canCancel = true;
      _countdown = 10; // 10-second window
    });

    _emergencyController.forward();
    HapticFeedback.mediumImpact();
    _countdownTimer();
  }

  void _countdownTimer() async {
    while (_countdown > 0 && _isCountingDown) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isCountingDown) {
        setState(() {
          _countdown--;
          // After 10 seconds, user can no longer cancel
          if (_countdown == 0) {
            _canCancel = false;
          }
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
    
    setState(() {
      _isSOSSent = true;
      _isCountingDown = false;
    });
  }

  void _cancelCountdown() {
    if (!_canCancel) return; // Cannot cancel after 10 seconds
    
    setState(() {
      _isCountingDown = false;
      _countdown = 10;
      _canCancel = true;
    });
    _emergencyController.reverse();
  }

  void _captureEvidence() {
    // Mock evidence capture
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📸 Photo evidence captured and attached'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _recordAudio() {
    // Mock audio recording
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎤 Audio recording started'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isSOSSent ? Colors.green.shade50 : Colors.red.shade50,
      appBar: _isSOSSent ? null : AppBar(
        title: const Text('Emergency SOS'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: _isCountingDown ? null : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<TouristBloc, TouristState>(
        listener: (context, state) {
          if (state is SOSSent) {
            setState(() {
              _isSOSSent = true;
              _isCountingDown = false;
            });
          }
        },
        child: _isSOSSent ? _buildEmergencyModeView() : _buildSOSInitialView(),
      ),
    );
  }

  Widget _buildSOSInitialView() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Main Content
            if (!_isCountingDown) _buildInitialView(),
            if (_isCountingDown) _buildCountdownView(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyModeView() {
    final currentTourist = DemoData.currentTourist;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade900, Colors.red.shade700],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
            // Alert Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade800,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emergency,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'SOS ACTIVATED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Emergency services have been notified',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            // Live Location Map
            Container(
              height: 300, // Fixed height instead of Expanded
              margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(currentTourist.lat, currentTourist.lng),
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.smart_tourist_safety',
                      ),
                      MarkerLayer(
                        markers: [
                          // Current tourist position
                          Marker(
                            width: 60.0,
                            height: 60.0,
                            point: LatLng(currentTourist.lat, currentTourist.lng),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_pin,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          // Mock nearby responders
                          Marker(
                            width: 40.0,
                            height: 40.0,
                            point: LatLng(currentTourist.lat + 0.001, currentTourist.lng + 0.001),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.local_police,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          Marker(
                            width: 40.0,
                            height: 40.0,
                            point: LatLng(currentTourist.lat - 0.002, currentTourist.lng + 0.002),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.local_hospital,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            
            // Emergency Options
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Evidence Capture
                  Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _captureEvidence,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Capture Photo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _recordAudio,
                            icon: const Icon(Icons.mic),
                            label: const Text('Record Audio'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Contact Options
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _makeCall('Police'),
                            icon: const Icon(Icons.local_police),
                            label: const Text('Call Police'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _makeCall('Family'),
                            icon: const Icon(Icons.family_restroom),
                            label: const Text('Call Family'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _makeCall('Ambulance'),
                        icon: const Icon(Icons.local_hospital),
                        label: const Text('Request Ambulance'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Incident Status
                    _buildIncidentStatusTracker(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentStatusTracker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Incident Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusItem('Alert Sent', true, Colors.green),
          _buildStatusItem('Police Notified', true, Colors.blue),
          _buildStatusItem('Unit Assigned', false, Colors.orange),
          _buildStatusItem('Response En Route', false, Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, bool isComplete, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.schedule,
            color: isComplete ? color : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isComplete ? color : Colors.grey,
              fontWeight: isComplete ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialView() {
    final currentTourist = DemoData.currentTourist;
    
    return Column(
      children: [
        // Tourist Info Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    currentTourist.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.badge, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'ID: ${currentTourist.digitalId}',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Emergency SOS Button
        GestureDetector(
          onTap: _startCountdown,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [Colors.red, Colors.redAccent],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emergency,
                  color: Colors.white,
                  size: 60,
                ),
                const SizedBox(height: 10),
                Text(
                  'SOS',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'EMERGENCY',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Instructions
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 24),
              const SizedBox(height: 8),
              Text(
                'Tap and hold the SOS button for emergency assistance',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.orange.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _makeCall(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📞 Calling $type...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildInfoCard() {
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
                    color: Colors.red.withValues(alpha: 0.4),
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
        
        ScaleTransition(
          scale: _emergencyAnimation,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.4),
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
        ),
        
        const SizedBox(height: 30),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _canCancel ? Colors.orange.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _canCancel ? Colors.orange : Colors.red,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                _canCancel ? Icons.warning_amber_rounded : Icons.block,
                color: _canCancel ? Colors.orange : Colors.red,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                _canCancel 
                    ? '⚠️ Emergency Alert Activating'
                    : '🚨 SOS Cannot Be Cancelled',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _canCancel ? Colors.orange : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _canCancel
                    ? 'You have ${_countdown} seconds to cancel this emergency alert'
                    : 'Emergency services are being notified. Help is on the way.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 30),
        
        if (_canCancel)
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: _cancelCountdown,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 50),
              ),
              child: const Text(
                'Cancel SOS',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.red),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text(
                  'Cancellation window expired',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
                color: Colors.green.withValues(alpha: 0.3),
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
