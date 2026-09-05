import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardStep2Screen extends StatefulWidget {
  const OnboardStep2Screen({super.key, this.prevData});
  final Map<String, dynamic>? prevData;

  @override
  State<OnboardStep2Screen> createState() => _OnboardStep2ScreenState();
}

class _OnboardStep2ScreenState extends State<OnboardStep2Screen> {
  String _selectedState = 'Assam';
  String _selectedDistrict = 'Sonapur';
  String _selectedVillage = 'Rampur Gaon';
  String _suggestedLanguage = 'Hindi';

  final List<String> _states = ['Assam', 'Bihar', 'Uttar Pradesh', 'Madhya Pradesh'];
  final List<String> _districts = ['Sonapur', 'Guwahati', 'Kamrup', 'Dispur'];
  final List<String> _villages = ['Rampur Gaon', 'Dhor Kola', 'Sonapur Center', 'Kalyanpur'];

  void _handleNext() {
    final mergedData = {
      ...?widget.prevData,
      'state': _selectedState,
      'district': _selectedDistrict,
      'village': _selectedVillage,
      'language': _suggestedLanguage,
    };

    context.push('/asha/onboard/step3-family', extra: mergedData);
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3-Step Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepCircle('1', isActive: false, isCompleted: true),
                  _buildStepLine(isActive: true),
                  _buildStepCircle('2', isActive: true, isCompleted: false),
                  _buildStepLine(isActive: false),
                  _buildStepCircle('3', isActive: false, isCompleted: false),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Gaon ka Chayan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 20),

              // Rajya / State Picker
              _buildDropdownField(
                label: 'Rajya (राज्य)',
                icon: Icons.public_rounded,
                value: _selectedState,
                items: _states,
                onChanged: (val) => setState(() => _selectedState = val!),
              ),

              const SizedBox(height: 14),

              // Zila / District Picker
              _buildDropdownField(
                label: 'Zila (ज़िला)',
                icon: Icons.location_city_rounded,
                value: _selectedDistrict,
                items: _districts,
                onChanged: (val) => setState(() => _selectedDistrict = val!),
              ),

              const SizedBox(height: 14),

              // Gaon / Village Picker
              _buildDropdownField(
                label: 'Gaon (गाँव)',
                icon: Icons.place_rounded,
                value: _selectedVillage,
                items: _villages,
                onChanged: (val) => setState(() => _selectedVillage = val!),
              ),

              const SizedBox(height: 20),

              // Dialect Suggestion Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_rounded, color: emeraldBrand, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sujhav: $_suggestedLanguage',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF065F46),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '(Is gaon mein adhiktar log Hindi bolte hain)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

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

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    const emeraldBrand = Color(0xFF059669);
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: emeraldBrand),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
