import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../blocs/tourist_bloc.dart';
import '../models/demo_data.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  
  int _currentStep = 0;
  String _selectedLanguage = 'English';
  String _selectedDocumentType = 'aadhaar'; // 'aadhaar' or 'passport'
  bool _hasConsentAgreed = false;
  bool _termsAccepted = false;
  bool _privacyPolicyAccepted = false;
  String _digitalId = '';
  
  // DigiLocker and KYC related
  bool _isDigiLockerConnected = false;
  bool _isKYCVerified = false;
  Map<String, dynamic>? _documentData;
  
  // OTP related
  bool _isOTPSent = false;
  bool _isOTPVerified = false;
  int _otpTimer = 60;
  Timer? _timer;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'hi', 'name': 'हिंदी', 'flag': '🇮🇳'},
    {'code': 'ur', 'name': 'اردو', 'flag': '📝'},
    {'code': 'ka', 'name': 'कश्मीरी', 'flag': '🏔️'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _idController.dispose();
    _emergencyContactController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 6) { // Updated to 6 steps
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // DigiLocker Integration Methods
  Future<void> _connectDigiLocker() async {
    // Mock DigiLocker authentication
    setState(() {
      _isDigiLockerConnected = true;
    });
    
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock document retrieval
    setState(() {
      _documentData = {
        'name': 'John Doe',
        'aadhaar': '1234-5678-9012',
        'dob': '01/01/1990',
        'address': '123 Main St, City, State',
        'verified': true,
      };
      _isKYCVerified = true;
      _nameController.text = _documentData!['name'];
      _idController.text = _documentData!['aadhaar'];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ DigiLocker connected successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // OTP Methods
  Future<void> _sendOTP() async {
    if (_phoneController.text.trim().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit phone number')),
      );
      return;
    }

    setState(() {
      _isOTPSent = true;
      _otpTimer = 60;
    });

    _startOTPTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP sent to +91-${_phoneController.text}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _startOTPTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpTimer > 0) {
        setState(() {
          _otpTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    // Mock OTP verification (in real app, verify with backend)
    if (_otpController.text == '123456') {
      setState(() {
        _isOTPVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Phone number verified successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _nextStep();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Invalid OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _generateDigitalId() {
    if (_nameController.text.trim().isEmpty || 
        _idController.text.trim().isEmpty || 
        _emergencyContactController.text.trim().isEmpty ||
        !_hasConsentAgreed ||
        !_isKYCVerified ||
        !_isOTPVerified ||
        !_termsAccepted ||
        !_privacyPolicyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all verification steps')),
      );
      return;
    }

    setState(() {
      _digitalId = 'KYC-${_selectedDocumentType.toUpperCase()}-${_idController.text}-${DateTime.now().millisecondsSinceEpoch}';
    });

    // Add tourist to demo data with verified status
    DemoData.currentTourist = DemoData.currentTourist.copyWith(
      name: _nameController.text.trim(),
      digitalId: _digitalId,
    );

    _nextStep();
  }

  void _proceedToDashboard() {
    context.read<TouristBloc>().add(LoadTourists());
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Smart Tourist Safety'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Step Indicator
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                for (int i = 0; i < 7; i++) // Updated to 7 steps
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: i <= _currentStep ? Colors.blue : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        if (i < 6) const SizedBox(width: 4), // Updated to 6
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Step Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStepLabel('Language', 0),
                _buildStepLabel('Document', 1),
                _buildStepLabel('DigiLocker', 2),
                _buildStepLabel('OTP', 3),
                _buildStepLabel('Terms', 4),
                _buildStepLabel('Info', 5),
                _buildStepLabel('ID', 6),
              ],
            ),
          ),
          
          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildLanguageSelectionPage(),
                _buildDocumentTypePage(),
                _buildDigiLockerPage(),
                _buildOTPVerificationPage(),
                _buildTermsConditionsPage(),
                _buildBasicInfoPage(),
                _buildDigitalIdPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLabel(String text, int step) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: _currentStep >= step ? FontWeight.bold : FontWeight.normal,
        color: _currentStep >= step ? Colors.blue : Colors.grey,
      ),
    );
  }

  Widget _buildLanguageSelectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          // Welcome Icon
          const Icon(
            Icons.language,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          
          const Text(
            'Select Your Language',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          
          Text(
            'Choose your preferred language for the app',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Language Selection Cards
          for (final language in _languages)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () {
                  setState(() {
                    _selectedLanguage = language['name']!;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _selectedLanguage == language['name'] 
                        ? Colors.blue 
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                tileColor: _selectedLanguage == language['name'] 
                    ? Colors.blue.shade50 
                    : Colors.white,
                leading: Text(
                  language['flag']!,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  language['name']!,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _selectedLanguage == language['name'] 
                        ? Colors.blue 
                        : Colors.black,
                  ),
                ),
                trailing: _selectedLanguage == language['name'] 
                    ? const Icon(Icons.check_circle, color: Colors.blue)
                    : null,
              ),
            ),
          
          const SizedBox(height: 40),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTypePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          const Icon(
            Icons.assignment_ind,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          
          const Text(
            'Choose Document Type',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          
          Text(
            'Select your preferred identity document for verification',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Aadhaar Card Option
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              onTap: () {
                setState(() {
                  _selectedDocumentType = 'aadhaar';
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _selectedDocumentType == 'aadhaar' 
                      ? Colors.blue 
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              tileColor: _selectedDocumentType == 'aadhaar' 
                  ? Colors.blue.shade50 
                  : Colors.white,
              leading: const Icon(
                Icons.credit_card,
                size: 32,
                color: Colors.orange,
              ),
              title: const Text(
                'Aadhaar Card',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              subtitle: const Text('Government issued unique ID'),
              trailing: _selectedDocumentType == 'aadhaar' 
                  ? const Icon(Icons.check_circle, color: Colors.blue)
                  : null,
            ),
          ),
          
          // Passport Option
          Container(
            margin: const EdgeInsets.only(bottom: 32),
            child: ListTile(
              onTap: () {
                setState(() {
                  _selectedDocumentType = 'passport';
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _selectedDocumentType == 'passport' 
                      ? Colors.blue 
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              tileColor: _selectedDocumentType == 'passport' 
                  ? Colors.blue.shade50 
                  : Colors.white,
              leading: const Icon(
                Icons.menu_book,
                size: 32,
                color: Colors.green,
              ),
              title: const Text(
                'Passport',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              subtitle: const Text('International travel document'),
              trailing: _selectedDocumentType == 'passport' 
                  ? const Icon(Icons.check_circle, color: Colors.blue)
                  : null,
            ),
          ),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigiLockerPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          const Icon(
            Icons.cloud_sync,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          
          const Text(
            'DigiLocker Verification',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          
          Text(
            'Connect with DigiLocker to fetch your ${_selectedDocumentType == 'aadhaar' ? 'Aadhaar' : 'Passport'} details securely',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          if (!_isDigiLockerConnected) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.security,
                    size: 48,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Secure Document Verification',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your documents are verified directly from government database through DigiLocker',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _connectDigiLocker,
                icon: const Icon(Icons.link),
                label: const Text('Connect with DigiLocker'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.verified,
                    size: 48,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Document Verified Successfully!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_documentData != null) ...[
                    _buildDocumentInfo('Name', _documentData!['name']),
                    _buildDocumentInfo(
                      _selectedDocumentType == 'aadhaar' ? 'Aadhaar' : 'Passport', 
                      _documentData![_selectedDocumentType]
                    ),
                    _buildDocumentInfo('Status', '✅ Verified'),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isKYCVerified ? _nextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Continue to Phone Verification',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPVerificationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          const Icon(
            Icons.sms,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          
          const Text(
            'Phone Verification',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          
          Text(
            'Enter your phone number to receive OTP for verification',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Phone Number Input
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number *',
              prefixIcon: Icon(Icons.phone),
              prefixText: '+91 ',
              border: OutlineInputBorder(),
              hintText: 'Enter 10-digit phone number',
            ),
            keyboardType: TextInputType.phone,
            maxLength: 10,
          ),
          
          const SizedBox(height: 20),
          
          // Send OTP Button
          if (!_isOTPSent) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendOTP,
                icon: const Icon(Icons.send),
                label: const Text('Send OTP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ] else ...[
            // OTP Input Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'OTP sent to +91-${_phoneController.text}',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: _otpController,
                    decoration: const InputDecoration(
                      labelText: 'Enter 6-digit OTP',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                      hintText: '123456',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 4),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_otpTimer > 0) ...[
                        Text(
                          'Resend OTP in $_otpTimer s',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ] else ...[
                        TextButton(
                          onPressed: _sendOTP,
                          child: const Text('Resend OTP'),
                        ),
                      ],
                      ElevatedButton(
                        onPressed: _verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Verify'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTermsConditionsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          const Center(
            child: Icon(
              Icons.gavel,
              size: 80,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),
          
          const Center(
            child: Text(
              'Terms & Conditions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 30),
          
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const SingleChildScrollView(
              child: Text(
                '''SMART TOURIST SAFETY - TERMS AND CONDITIONS

1. ACCEPTANCE OF TERMS
By using Smart Tourist Safety app, you agree to these Terms and Conditions.

2. USER OBLIGATIONS
• Provide accurate personal information
• Maintain confidentiality of your account
• Use the service responsibly and lawfully
• Report emergencies truthfully

3. PRIVACY AND DATA PROTECTION
• Your personal data is protected under applicable privacy laws
• Location data is used only for safety and emergency purposes
• We do not share personal information with unauthorized third parties
• DigiLocker integration follows government security protocols

4. EMERGENCY SERVICES
• SOS feature connects you with local emergency services
• False emergency reports may result in account suspension
• Emergency response depends on local authority availability

5. LIABILITY DISCLAIMER
• App provides assistance but doesn't guarantee immediate response
• Users are responsible for their own safety decisions
• We are not liable for service interruptions or technical issues

6. DIGITAL ID AND VERIFICATION
• Digital ID is for identification purposes within the app
• KYC verification ensures user authenticity
• Misuse of digital identity is strictly prohibited

7. LOCATION SERVICES
• GPS tracking is used for safety monitoring
• Location sharing can be controlled by user preferences
• Data is encrypted and securely stored

8. UPDATES AND MODIFICATIONS
• Terms may be updated periodically
• Continued use implies acceptance of updated terms

By proceeding, you acknowledge that you have read, understood, and agree to these terms and conditions.''',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Terms Acceptance
          CheckboxListTile(
            value: _termsAccepted,
            onChanged: (value) {
              setState(() {
                _termsAccepted = value ?? false;
              });
            },
            title: const Text(
              'I accept the Terms and Conditions',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          
          // Privacy Policy Acceptance
          CheckboxListTile(
            value: _privacyPolicyAccepted,
            onChanged: (value) {
              setState(() {
                _privacyPolicyAccepted = value ?? false;
              });
            },
            title: const Text(
              'I accept the Privacy Policy',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          
          const SizedBox(height: 30),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_termsAccepted && _privacyPolicyAccepted) ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Accept and Continue',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          
          const Icon(
            Icons.person_add,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          
          const Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          
          Text(
            'Complete your profile for better safety assistance',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          // Pre-filled from DigiLocker
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name (from DigiLocker)',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            enabled: false, // Pre-filled from KYC
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _idController,
            decoration: InputDecoration(
              labelText: '${_selectedDocumentType == 'aadhaar' ? 'Aadhaar' : 'Passport'} Number (from DigiLocker)',
              prefixIcon: const Icon(Icons.badge),
              border: const OutlineInputBorder(),
            ),
            enabled: false, // Pre-filled from KYC
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number (verified)',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
            enabled: false, // Pre-filled from OTP verification
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _emergencyContactController,
            decoration: const InputDecoration(
              labelText: 'Emergency Contact Number *',
              prefixIcon: Icon(Icons.emergency),
              border: OutlineInputBorder(),
              hintText: 'Enter emergency contact number',
            ),
            keyboardType: TextInputType.phone,
          ),
          
          const SizedBox(height: 30),
          
          // Consent for location tracking
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: [
                CheckboxListTile(
                  value: _hasConsentAgreed,
                  onChanged: (value) {
                    setState(() {
                      _hasConsentAgreed = value ?? false;
                    });
                  },
                  title: const Text(
                    'I consent to location tracking for safety purposes',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'This helps emergency services locate you quickly',
                    style: TextStyle(fontSize: 12),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_emergencyContactController.text.trim().isNotEmpty && 
                         _hasConsentAgreed) ? _generateDigitalId : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Generate Digital ID',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalIdPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          // Success Animation
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
            child: const Icon(
              Icons.verified,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 30),
          
          const Text(
            'Digital Tourist ID Created!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 10),
          
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                '✅ Blockchain Verified & Secured',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Digital ID Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'DIGITAL TOURIST ID',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                
                // QR Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data: _digitalId,
                    version: QrVersions.auto,
                    size: 150.0,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  _nameController.text.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                Text(
                  'ID: $_digitalId',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Features List
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                _FeatureRow(
                  icon: Icons.location_on,
                  text: 'Real-time location tracking',
                ),
                _FeatureRow(
                  icon: Icons.shield,
                  text: 'Emergency SOS activation',
                ),
                _FeatureRow(
                  icon: Icons.warning,
                  text: 'Safety zone alerts',
                ),
                _FeatureRow(
                  icon: Icons.people,
                  text: 'Family sharing',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _proceedToDashboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Enter Safety Dashboard',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
