import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardStep1Screen extends StatefulWidget {
  const OnboardStep1Screen({super.key});

  @override
  State<OnboardStep1Screen> createState() => _OnboardStep1ScreenState();
}

class _OnboardStep1ScreenState extends State<OnboardStep1Screen> {
  final _nameController = TextEditingController(text: 'Ramesh Das');
  final _ageController = TextEditingController(text: '72');
  final _phoneController = TextEditingController(text: '9876543211');
  final _caregiverController = TextEditingController(text: 'Suresh Das (Son)');

  String _gender = 'Purush';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _caregiverController.dispose();
    super.dispose();
  }

  void _handleNext() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter patient name.')),
      );
      return;
    }

    context.push(
      '/asha/onboard/step2',
      extra: {
        'name': name,
        'age': _ageController.text.trim(),
        'gender': _gender,
        'phone': _phoneController.text.trim(),
        'caregiver': _caregiverController.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const emeraldBrand = Color(0xFF059669);
    const textDark = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: textDark, size: 28),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3-Step Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepCircle('1', isActive: true, isCompleted: false),
                  _buildStepLine(isActive: false),
                  _buildStepCircle('2', isActive: false, isCompleted: false),
                  _buildStepLine(isActive: false),
                  _buildStepCircle('3', isActive: false, isCompleted: false),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Buzurg ki Jankari',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 20),

              // Form fields
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Naam (मरीज़ का नाम)',
                  prefixIcon: const Icon(Icons.person_rounded, color: emeraldBrand),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Umar (saal mein) (उम्र)',
                  prefixIcon: const Icon(Icons.calendar_today_rounded, color: emeraldBrand),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),

              const SizedBox(height: 16),

              // Gender Choice Row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _gender = 'Purush'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _gender == 'Purush' ? const Color(0xFFECFDF5) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _gender == 'Purush' ? emeraldBrand : const Color(0xFFCBD5E1),
                            width: _gender == 'Purush' ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _gender == 'Purush'
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: _gender == 'Purush' ? emeraldBrand : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            const Text('Purush (पुरुष)',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _gender = 'Mahila'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _gender == 'Mahila' ? const Color(0xFFECFDF5) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _gender == 'Mahila' ? emeraldBrand : const Color(0xFFCBD5E1),
                            width: _gender == 'Mahila' ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _gender == 'Mahila'
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: _gender == 'Mahila' ? emeraldBrand : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            const Text('Mahila (महिला)',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number (optional)',
                  prefixIcon: const Icon(Icons.phone_rounded, color: emeraldBrand),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: _caregiverController,
                decoration: InputDecoration(
                  labelText: 'Caregiver ka Naam (optional)',
                  prefixIcon: const Icon(Icons.family_restroom_rounded, color: emeraldBrand),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),

              const SizedBox(height: 32),

              // Button: Aage Badhien ➔
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emeraldBrand,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Aage Badhien',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 22),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCircle(String label, {required bool isActive, required bool isCompleted}) {
    const emeraldBrand = Color(0xFF059669);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive || isCompleted ? emeraldBrand : const Color(0xFFE2E8F0),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, size: 18, color: Colors.white)
            : Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF64748B),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Widget _buildStepLine({required bool isActive}) {
    const emeraldBrand = Color(0xFF059669);
    return Container(
      width: 40,
      height: 3,
      color: isActive ? emeraldBrand : const Color(0xFFE2E8F0),
    );
  }
}
