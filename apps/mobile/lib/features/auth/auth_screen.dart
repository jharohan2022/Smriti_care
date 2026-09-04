import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_state_provider.dart';
import '../../core/config/flavor_config.dart';
import '../../core/services/tts_service.dart';
import '../../core/theme/app_theme.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  AppFlavor _selectedRole = AppFlavor.patient;
  bool _isPatientSignUp = false;
  bool _isAshaSignUp = false;

  // Patient Login & Registration Controllers
  final _patientNameController = TextEditingController(text: 'Ramesh Kumar');
  final _patientIdController = TextEditingController();
  final _patientAgeController = TextEditingController(text: '68');
  final _patientVillageController = TextEditingController(text: 'Rampur Village');
  final _caregiverNameController = TextEditingController(text: 'Suresh Kumar');
  final _caregiverPhoneController = TextEditingController(text: '9876543210');
  final _medicalNotesController = TextEditingController();

  String _patientGender = 'Male (पुरुष)';
  String _selectedLanguage = 'hi';
  String _cognitiveStage = 'Mild Memory Loss (प्रारंभिक स्मृति ह्रास)';

  // ASHA Controllers
  final _ashaIdController = TextEditingController(text: 'ASHA-8841');
  final _ashaNameController = TextEditingController(text: 'Sunita Devi');
  final _ashaPinController = TextEditingController(text: '1234');
  final _ashaCenterController = TextEditingController(text: 'Rampur Sub-Center');

  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(
            'Welcome to Smriti Care. Please select Patient or ASHA worker to begin.',
            langCode: 'en',
          );
    });
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientIdController.dispose();
    _patientAgeController.dispose();
    _patientVillageController.dispose();
    _caregiverNameController.dispose();
    _caregiverPhoneController.dispose();
    _medicalNotesController.dispose();
    _ashaIdController.dispose();
    _ashaNameController.dispose();
    _ashaPinController.dispose();
    _ashaCenterController.dispose();
    super.dispose();
  }

  Future<void> _handlePatientSubmit() async {
    final name = _patientNameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter patient name (कृपया मरीज का नाम दर्ज करें)');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      if (_isPatientSignUp) {
        final age = int.tryParse(_patientAgeController.text.trim()) ?? 65;
        final village = _patientVillageController.text.trim().isNotEmpty
            ? _patientVillageController.text.trim()
            : 'Rampur Village';
        final caregiverName = _caregiverNameController.text.trim().isNotEmpty
            ? _caregiverNameController.text.trim()
            : 'Family Member';
        final caregiverPhone = _caregiverPhoneController.text.trim().isNotEmpty
            ? _caregiverPhoneController.text.trim()
            : '9876543210';

        await ref.read(authStateProvider.notifier).registerPatient(
              name: name,
              age: age,
              gender: _patientGender,
              village: village,
              caregiverName: caregiverName,
              caregiverPhone: caregiverPhone,
              patientId: _patientIdController.text.trim().isNotEmpty ? _patientIdController.text.trim() : null,
              language: _selectedLanguage,
              medicalNotes: _cognitiveStage,
            );

        ref.read(ttsServiceProvider).speak(
              'Registration successful. Welcome $name ji to Smriti Care.',
              langCode: _selectedLanguage,
            );
      } else {
        await ref.read(authStateProvider.notifier).loginPatient(
              name: name,
              patientId: _patientIdController.text.trim().isNotEmpty ? _patientIdController.text.trim() : null,
              village: _patientVillageController.text.trim().isNotEmpty
                  ? _patientVillageController.text.trim()
                  : 'Rampur Village',
              language: _selectedLanguage,
            );

        ref.read(ttsServiceProvider).speak(
              'Welcome back $name ji.',
              langCode: _selectedLanguage,
            );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Could not start session: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleAshaSubmit() async {
    final id = _ashaIdController.text.trim();
    final name = _ashaNameController.text.trim();
    final pin = _ashaPinController.text.trim();

    if (id.isEmpty || pin.isEmpty) {
      setState(() => _errorMessage = 'Please enter ASHA ID and Security PIN');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authStateProvider.notifier).loginAsha(
            ashaId: id,
            name: name.isNotEmpty ? name : 'ASHA Worker ($id)',
            jurisdiction: _ashaCenterController.text.trim().isNotEmpty
                ? _ashaCenterController.text.trim()
                : 'Primary Health Center',
          );
    } catch (e) {
      setState(() => _errorMessage = 'Authentication failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPatient = _selectedRole == AppFlavor.patient;

    return Scaffold(
      backgroundColor: isPatient ? const Color(0xFFFFF9E6) : const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo & Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isPatient ? const Color(0xFF00695C) : const Color(0xFF1565C0),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isPatient ? const Color(0xFF00695C) : const Color(0xFF1565C0))
                                .withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        isPatient ? Icons.favorite_rounded : Icons.health_and_safety_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'स्मृति Care — SmritiCare',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isPatient ? 28 : 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dementia Care & Cognitive Assessment Portal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Role Selection Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRole = AppFlavor.patient;
                                _errorMessage = null;
                              });
                              ref.read(ttsServiceProvider).speak(
                                    'Patient Mode selected.',
                                    langCode: 'en',
                                  );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isPatient ? const Color(0xFF00695C) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_rounded,
                                    size: 22,
                                    color: isPatient ? Colors.white : Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '👤 Patient',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: isPatient ? Colors.white : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRole = AppFlavor.asha;
                                _errorMessage = null;
                              });
                              ref.read(ttsServiceProvider).speak(
                                    'ASHA Worker Portal selected.',
                                    langCode: 'en',
                                  );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: !isPatient ? const Color(0xFF1565C0) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.medical_services_rounded,
                                    size: 20,
                                    color: !isPatient ? Colors.white : Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '🩺 ASHA',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: !isPatient ? Colors.white : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade800, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Main Card Content
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isPatient ? const Color(0xFFFFD54F) : Colors.blue.shade200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: isPatient ? _buildPatientForm() : _buildAshaForm(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mode Header + Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _isPatientSignUp ? 'मरीज पंजीकरण (Registration)' : 'मरीज लॉगिन (Sign In)',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF00695C)),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isPatientSignUp = !_isPatientSignUp;
                  _errorMessage = null;
                });
                ref.read(ttsServiceProvider).speak(
                      _isPatientSignUp
                          ? 'Patient Registration Form. Please enter your details.'
                          : 'Patient Sign In.',
                      langCode: 'en',
                    );
              },
              icon: Icon(
                _isPatientSignUp ? Icons.login_rounded : Icons.app_registration_rounded,
                size: 18,
                color: const Color(0xFF00695C),
              ),
              label: Text(
                _isPatientSignUp ? 'Sign In' : 'Register New',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00695C)),
              ),
            ),
          ],
        ),
        const Divider(height: 20),

        // Full Name Field
        TextField(
          controller: _patientNameController,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: 'Patient Full Name (मरीज का पूरा नाम) *',
            labelStyle: const TextStyle(fontSize: 14),
            prefixIcon: const Icon(Icons.badge_rounded, color: Color(0xFF00695C)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: const Color(0xFFFFF9E6),
          ),
        ),
        const SizedBox(height: 12),

        if (_isPatientSignUp) ...[
          // Age and Gender Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _patientAgeController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: 'Age (उम्र) *',
                    prefixIcon: const Icon(Icons.cake_rounded, color: Color(0xFF00695C)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xFFFFF9E6),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  value: _patientGender,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Gender (लिंग)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xFFFFF9E6),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male (पुरुष)', child: Text('Male (पुरुष)')),
                    DropdownMenuItem(value: 'Female (महिला)', child: Text('Female (महिला)')),
                    DropdownMenuItem(value: 'Other (अन्य)', child: Text('Other (अन्य)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _patientGender = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Caregiver Contact Name
          TextField(
            controller: _caregiverNameController,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Caregiver / Family Contact (देखभालकर्ता का नाम)',
              prefixIcon: const Icon(Icons.family_restroom_rounded, color: Color(0xFF00695C)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: const Color(0xFFFFF9E6),
            ),
          ),
          const SizedBox(height: 12),

          // Caregiver Phone
          TextField(
            controller: _caregiverPhoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Emergency Phone Number (आपातकालीन फोन नंबर)',
              prefixIcon: const Icon(Icons.phone_rounded, color: Color(0xFF00695C)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: const Color(0xFFFFF9E6),
            ),
          ),
          const SizedBox(height: 12),

          // Cognitive Stage / Condition
          DropdownButtonFormField<String>(
            value: _cognitiveStage,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Cognitive Observation (स्मृति स्थिति)',
              prefixIcon: const Icon(Icons.psychology_rounded, color: Color(0xFF00695C)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: const Color(0xFFFFF9E6),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Mild Memory Loss (प्रारंभिक स्मृति ह्रास)',
                child: Text('Mild (प्रारंभिक)'),
              ),
              DropdownMenuItem(
                value: 'Moderate Dementia (मध्यम डिमेंशिया)',
                child: Text('Moderate (मध्यम)'),
              ),
              DropdownMenuItem(
                value: 'Healthy Elderly Screening (नियमित जांच)',
                child: Text('Routine (नियमित)'),
              ),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _cognitiveStage = val);
            },
          ),
          const SizedBox(height: 12),
        ] else ...[
          // Optional Patient ID on Login
          TextField(
            controller: _patientIdController,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Patient ID (मरीज पहचान पत्र - Optional)',
              hintText: 'e.g. PAT-8841',
              prefixIcon: const Icon(Icons.tag_rounded, color: Color(0xFF00695C)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: const Color(0xFFFFF9E6),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Village / Town
        TextField(
          controller: _patientVillageController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Village / Town (गाँव / कस्बा)',
            prefixIcon: const Icon(Icons.location_city_rounded, color: Color(0xFF00695C)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: const Color(0xFFFFF9E6),
          ),
        ),
        const SizedBox(height: 12),

        // Language Dropdown
        DropdownButtonFormField<String>(
          value: _selectedLanguage,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Voice Language (आवाज़ की भाषा)',
            prefixIcon: const Icon(Icons.language_rounded, color: Color(0xFF00695C)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: const Color(0xFFFFF9E6),
          ),
          items: const [
            DropdownMenuItem(value: 'hi', child: Text('हिन्दी (Hindi)')),
            DropdownMenuItem(value: 'bn', child: Text('বাংলা (Bengali)')),
            DropdownMenuItem(value: 'ta', child: Text('தமிழ் (Tamil)')),
            DropdownMenuItem(value: 'en', child: Text('English')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _selectedLanguage = val);
          },
        ),

        const SizedBox(height: 20),

        // Submit Button
        ElevatedButton(
          onPressed: _loading ? null : _handlePatientSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00695C),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
          ),
          child: _loading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isPatientSignUp ? Icons.how_to_reg_rounded : Icons.play_circle_fill_rounded, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      _isPatientSignUp ? 'REGISTER & START CARE' : 'START CARE SESSION',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                  ],
                ),
        ),

        if (!_isPatientSignUp) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              _patientNameController.text = 'Ramesh Kumar';
              _patientVillageController.text = 'Rampur Village';
              _handlePatientSubmit();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF00695C),
              side: const BorderSide(color: Color(0xFF00695C), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('⚡ Quick 1-Tap Demo Patient (Ramesh)'),
          ),
        ],
      ],
    );
  }

  Widget _buildAshaForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _isAshaSignUp ? 'ASHA Onboarding' : 'ASHA Worker Login',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _isAshaSignUp = !_isAshaSignUp),
              child: Text(
                _isAshaSignUp ? 'Sign In' : 'Register New',
                style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1565C0)),
              ),
            ),
          ],
        ),
        const Divider(height: 20),
        TextField(
          controller: _ashaIdController,
          decoration: InputDecoration(
            labelText: 'ASHA ID / Registered Phone',
            prefixIcon: const Icon(Icons.badge_rounded, color: Color(0xFF1565C0)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 14),
        if (_isAshaSignUp) ...[
          TextField(
            controller: _ashaNameController,
            decoration: InputDecoration(
              labelText: 'Worker Full Name',
              prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFF1565C0)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _ashaCenterController,
            decoration: InputDecoration(
              labelText: 'Assigned Sub-Center / PHC',
              prefixIcon: const Icon(Icons.location_city_rounded, color: Color(0xFF1565C0)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),
        ],
        TextField(
          controller: _ashaPinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Security PIN (4 digits)',
            prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFF1565C0)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loading ? null : _handleAshaSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  _isAshaSignUp ? 'REGISTER ASHA ACCOUNT' : 'SIGN IN TO ASHA PORTAL',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
