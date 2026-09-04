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
    this.careLevel = 'Moderate Support',
    this.isDeviceBound = false,
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
  static const String _deviceBoundKey = 'is_device_bound_patient';
  static const String _patientNameKey = 'bound_patient_name';
  static const String _patientAgeKey = 'bound_patient_age';
  static const String _patientAshaNameKey = 'bound_patient_asha_name';
  static const String _patientAshaPhoneKey = 'bound_patient_asha_phone';
  static const String _patientEmergencyKey = 'bound_patient_emergency';
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
            isDeviceBound: false, // Defaults to false on clean install until activated once
          ),
        ) {
    _loadDeviceBinding();
  }

  Future<void> _loadDeviceBinding() async {
    try {
      final boundVal = await _storage.read(key: _deviceBoundKey);
      final isBound = boundVal == 'true';
      if (isBound) {
        final name = await _storage.read(key: _patientNameKey) ?? state.name;
        final age = await _storage.read(key: _patientAgeKey) ?? state.age;
        final ashaName = await _storage.read(key: _patientAshaNameKey) ?? state.ashaName;
        final ashaPhone = await _storage.read(key: _patientAshaPhoneKey) ?? state.ashaPhone;
        final emergency = await _storage.read(key: _patientEmergencyKey) ?? state.emergencyContact;

        state = state.copyWith(
          name: name,
          age: age,
          ashaName: ashaName,
          ashaPhone: ashaPhone,
          emergencyContact: emergency,
          isDeviceBound: true,
        );
      }
    } catch (_) {}
  }

  /// Activate & bind device for a patient (Executed ONLY once after download)
  Future<void> activateDeviceForPatient({
    required String name,
    required String age,
    required String ashaName,
    required String ashaPhone,
    required String emergencyContact,
    String condition = 'Mild Cognitive Impairment / Early Dementia',
  }) async {
    await _storage.write(key: _deviceBoundKey, value: 'true');
    await _storage.write(key: _patientNameKey, value: name);
    await _storage.write(key: _patientAgeKey, value: age);
    await _storage.write(key: _patientAshaNameKey, value: ashaName);
    await _storage.write(key: _patientAshaPhoneKey, value: ashaPhone);
    await _storage.write(key: _patientEmergencyKey, value: emergencyContact);

    state = state.copyWith(
      name: name,
      age: age,
      ashaName: ashaName,
      ashaPhone: ashaPhone,
      emergencyContact: emergencyContact,
      condition: condition,
      isDeviceBound: true,
    );
  }

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

  /// Reset / Unbind Device — ONLY executable by ASHA worker with verified PIN
  Future<bool> resetDeviceWithAshaPin(String pin) async {
    final valid = await verifyAshaPin(pin);
    if (!valid) return false;

    await _storage.delete(key: _deviceBoundKey);
    await _storage.delete(key: _patientNameKey);
    await _storage.delete(key: _patientAgeKey);
    await _storage.delete(key: _patientAshaNameKey);
    await _storage.delete(key: _patientAshaPhoneKey);
    await _storage.delete(key: _patientEmergencyKey);

    state = state.copyWith(
      isDeviceBound: false,
    );
    return true;
  }
}

final patientDeviceProvider =
    StateNotifierProvider<PatientDeviceNotifier, PatientProfileData>((ref) {
  return PatientDeviceNotifier();
});
