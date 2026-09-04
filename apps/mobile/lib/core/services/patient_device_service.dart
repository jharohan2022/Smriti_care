import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PatientProfileData {
  final String id;
  final String name;
  final String age;
  final String condition;
  final String ashaName;
  final String ashaPhone;
  final String emergencyContact;
  final String primaryLanguage;
  final String careLevel;
  final bool isDeviceBound;

  const PatientProfileData({
    required this.id,
    required this.name,
    required this.age,
    required this.condition,
    required this.ashaName,
    required this.ashaPhone,
    required this.emergencyContact,
    this.primaryLanguage = 'hi',
    this.careLevel = 'Stage 2 (Moderate)',
    this.isDeviceBound = true,
  });

  PatientProfileData copyWith({
    String? id,
    String? name,
    String? age,
    String? condition,
    String? ashaName,
    String? ashaPhone,
    String? emergencyContact,
    String? primaryLanguage,
    String? careLevel,
    bool? isDeviceBound,
  }) {
    return PatientProfileData(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      condition: condition ?? this.condition,
      ashaName: ashaName ?? this.ashaName,
      ashaPhone: ashaPhone ?? this.ashaPhone,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      primaryLanguage: primaryLanguage ?? this.primaryLanguage,
      careLevel: careLevel ?? this.careLevel,
      isDeviceBound: isDeviceBound ?? this.isDeviceBound,
    );
  }
}

class PatientDeviceNotifier extends StateNotifier<PatientProfileData> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _ashaPinKey = 'asha_security_pin';
  static const String _defaultPin = '1234';

  PatientDeviceNotifier()
      : super(
          const PatientProfileData(
            id: 'PAT-9842',
            name: 'रामनाथ शर्मा (Ramnath Sharma)',
            age: '72',
            condition: 'Mild Cognitive Impairment / Early Dementia',
            ashaName: 'सुनीता दीदी (Sunita Didi)',
            ashaPhone: '+91 98765 43210',
            emergencyContact: '+91 98111 22334 (Rohan - Son)',
            primaryLanguage: 'hi',
            careLevel: 'Moderate Support',
            isDeviceBound: true,
          ),
        );

  /// Verifies ASHA 4-digit PIN before allowing any management actions
  Future<bool> verifyAshaPin(String pin) async {
    final storedPin = await _storage.read(key: _ashaPinKey);
    final validPin = storedPin ?? _defaultPin;
    return pin == validPin;
  }

  /// Sets custom ASHA PIN
  Future<void> setAshaPin(String newPin) async {
    await _storage.write(key: _ashaPinKey, value: newPin);
  }

  /// Update patient information (Only permitted by ASHA)
  Future<void> updatePatientDetails({
    String? name,
    String? age,
    String? condition,
    String? ashaName,
    String? ashaPhone,
    String? emergencyContact,
    String? careLevel,
  }) async {
    state = state.copyWith(
      name: name,
      age: age,
      condition: condition,
      ashaName: ashaName,
      ashaPhone: ashaPhone,
      emergencyContact: emergencyContact,
      careLevel: careLevel,
    );
  }

  /// Reset / Unbind Device — ONLY executable by ASHA worker with verified PIN
  Future<bool> resetDeviceWithAshaPin(String pin) async {
    final valid = await verifyAshaPin(pin);
    if (!valid) return false;

    // Reset to default fresh bound state or clean initial state
    state = const PatientProfileData(
      id: 'PAT-NEW',
      name: 'नया मरीज़ (New Patient)',
      age: '70',
      condition: 'Cognitive Support Required',
      ashaName: 'आशा कार्यकर्ता (ASHA Worker)',
      ashaPhone: '+91 98765 00000',
      emergencyContact: '+91 98000 00000',
      primaryLanguage: 'hi',
      careLevel: 'Standard Support',
      isDeviceBound: true,
    );
    return true;
  }
}

final patientDeviceProvider =
    StateNotifierProvider<PatientDeviceNotifier, PatientProfileData>((ref) {
  return PatientDeviceNotifier();
});
