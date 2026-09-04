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
  bool _isSignUp = false;

  // Patient Controllers
  final _patientNameController = TextEditingController(text: 'Ramesh Kumar');
  final _patientVillageController = TextEditingController(text: 'Rampur Village');
  String _selectedLanguage = 'hi';

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
    _patientVillageController.dispose();
    _ashaIdController.dispose();
    _ashaNameController.dispose();
    _ashaPinController.dispose();
    _ashaCenterController.dispose();
    super.dispose();
  }

  Future<void> _handlePatientSubmit() async {
    final name = _patientNameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter patient name');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authStateProvider.notifier).loginPatient(
            name: name,
            village: _patientVillageController.text.trim().isNotEmpty
                ? _patientVillageController.text.trim()
                : 'Local Village',
            language: _selectedLanguage,
          );
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
              constraints: const BoxConstraints(maxWidth: 480),
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
                  const SizedBox(height: 16),
                  Text(
                    'स्मृति Care — SmritiCare',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isPatient ? 28 : 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Dementia Care & ASHA Cognitive Monitoring',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),

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
                                    'Patient Mode selected. Tap Start Care to begin.',
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

                  const SizedBox(height: 20),

                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                      ),
                    ),

                  // Card Content
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPatient ? Colors.amber.shade200 : Colors.blue.shade200,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Patient Care Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00695C)),
            ),
            IconButton(
              tooltip: 'Voice Help',
              icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF00695C), size: 28),
              onPressed: () {
                ref.read(ttsServiceProvider).speak(
                      'Welcome. Enter your name or tap Start Care to begin your memory exercises.',
                      langCode: _selectedLanguage,
                    );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _patientNameController,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: 'Patient Name (मरीज का नाम)',
            labelStyle: const TextStyle(fontSize: 15),
            prefixIcon: const Icon(Icons.badge_rounded, color: Color(0xFF00695C)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: const Color(0xFFFFF8E1).withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _patientVillageController,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Village / Town (गाँव / शहर)',
            prefixIcon: const Icon(Icons.location_city_rounded, color: Color(0xFF00695C)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: const Color(0xFFFFF8E1).withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _selectedLanguage,
          decoration: InputDecoration(
            labelText: 'Voice Language (भाषा)',
            prefixIcon: const Icon(Icons.language_rounded, color: Color(0xFF00695C)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_fill_rounded, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'START CARE SESSION',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 14),
        OutlinedButton(
          onPressed: () {
            _patientNameController.text = 'Ramesh Kumar';
            _patientVillageController.text = 'Rampur Village';
            _handlePatientSubmit();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF00695C),
            side: const BorderSide(color: Color(0xFF00695C)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('⚡ Quick 1-Tap Demo Patient (Ramesh)'),
        ),
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
            Text(
              _isSignUp ? 'ASHA Onboarding' : 'ASHA Worker Login',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
            ),
            TextButton(
              onPressed: () => setState(() => _isSignUp = !_isSignUp),
              child: Text(
                _isSignUp ? 'Sign In' : 'Register New',
                style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1565C0)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _ashaIdController,
          decoration: InputDecoration(
            labelText: 'ASHA ID / Registered Phone',
            prefixIcon: const Icon(Icons.badge_rounded, color: Color(0xFF1565C0)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (_isSignUp) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _ashaNameController,
            decoration: InputDecoration(
              labelText: 'Worker Full Name',
              prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF1565C0)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: _ashaCenterController,
          decoration: InputDecoration(
            labelText: 'Sub-Center / Jurisdiction',
            prefixIcon: const Icon(Icons.local_hospital_rounded, color: Color(0xFF1565C0)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _ashaPinController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Security PIN / Password',
            prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFF1565C0)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 18),
        ElevatedButton(
          onPressed: _loading ? null : _handleAshaSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 3,
          ),
          child: _loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  _isSignUp ? 'REGISTER ASHA ACCOUNT' : 'SIGN IN TO ASHA PORTAL',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            _ashaIdController.text = 'ASHA-8841';
            _ashaNameController.text = 'Sunita Devi';
            _ashaPinController.text = '1234';
            _handleAshaSubmit();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1565C0),
            side: const BorderSide(color: Color(0xFF1565C0)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('⚡ Quick 1-Tap Demo ASHA (Sunita Devi)'),
        ),
      ],
    );
  }
}
