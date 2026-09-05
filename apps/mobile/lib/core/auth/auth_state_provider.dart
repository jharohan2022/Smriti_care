import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/flavor_config.dart';

class MobileAuthUser {
  const MobileAuthUser({
    required this.userId,
    required this.name,
    required this.role,
    this.region = 'Default',
    this.language = 'hi',
    this.age,
    this.gender,
    this.caregiverName,
    this.caregiverPhone,
    this.medicalNotes,
    this.profilePhotoPath,
  });

  final String userId;
  final String name;
  final AppFlavor role;
  final String region;
  final String language;
  final int? age;
  final String? gender;
  final String? caregiverName;
  final String? caregiverPhone;
  final String? medicalNotes;
  final String? profilePhotoPath;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'role': role == AppFlavor.patient ? 'patient' : 'asha',
        'region': region,
        'language': language,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
        if (caregiverName != null) 'caregiverName': caregiverName,
        if (caregiverPhone != null) 'caregiverPhone': caregiverPhone,
        if (medicalNotes != null) 'medicalNotes': medicalNotes,
        if (profilePhotoPath != null) 'profilePhotoPath': profilePhotoPath,
      };

  factory MobileAuthUser.fromJson(Map<String, dynamic> json) => MobileAuthUser(
        userId: json['userId'] as String? ?? 'user-1',
        name: json['name'] as String? ?? 'User',
        role: (json['role'] as String?) == 'asha' ? AppFlavor.asha : AppFlavor.patient,
        region: json['region'] as String? ?? 'Default',
        language: json['language'] as String? ?? 'hi',
        age: json['age'] as int?,
        gender: json['gender'] as String?,
        caregiverName: json['caregiverName'] as String?,
        caregiverPhone: json['caregiverPhone'] as String?,
        medicalNotes: json['medicalNotes'] as String?,
        profilePhotoPath: json['profilePhotoPath'] as String?,
      );
}

class MobileAuthState {
  const MobileAuthState({
    this.user,
    this.isLoading = false,
  });

  final MobileAuthUser? user;
  final bool isLoading;

  bool get isAuthenticated => user != null;
  AppFlavor get activeRole => user?.role ?? AppFlavor.patient;

  MobileAuthState copyWith({
    MobileAuthUser? user,
    bool? isLoading,
    bool clearUser = false,
  }) =>
      MobileAuthState(
        user: clearUser ? null : (user ?? this.user),
        isLoading: isLoading ?? this.isLoading,
      );
}

class AuthNotifier extends StateNotifier<MobileAuthState> {
  AuthNotifier(this._storage) : super(const MobileAuthState()) {
    _loadStoredSession();
  }

  final FlutterSecureStorage _storage;
  static const _userKey = 'smriticare_mobile_auth_user';
  static const _kPatientId = 'smriti.patientId';
  static const _kDeviceSecret = 'smriti.deviceSecret';

  Future<void> _loadStoredSession() async {
    try {
      final raw = await _storage.read(key: _userKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final user = MobileAuthUser.fromJson(decoded);
        _applyRoleConfig(user.role);
        state = state.copyWith(user: user);
      }
    } catch (_) {
      // In case of error, stay unauthenticated
    }
  }

  void _applyRoleConfig(AppFlavor role) {
    FlavorConfig.set(FlavorConfig(
      flavor: role,
      apiBaseUrl: FlavorConfig.instance.apiBaseUrl,
      appTitle: role == AppFlavor.patient ? 'SmritiCare — Patient' : 'SmritiCare — ASHA',
    ));
  }

  Future<void> registerPatient({
    required String name,
    required int age,
    required String gender,
    required String village,
    required String caregiverName,
    required String caregiverPhone,
    String? patientId,
    String language = 'hi',
    String? medicalNotes,
    String? profilePhotoPath,
  }) async {
    final generatedId = patientId != null && patientId.trim().isNotEmpty
        ? patientId.trim()
        : 'PAT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final user = MobileAuthUser(
      userId: generatedId,
      name: name,
      role: AppFlavor.patient,
      region: village,
      language: language,
      age: age,
      gender: gender,
      caregiverName: caregiverName,
      caregiverPhone: caregiverPhone,
      medicalNotes: medicalNotes,
      profilePhotoPath: profilePhotoPath,
    );

    _applyRoleConfig(AppFlavor.patient);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    await _storage.write(key: _kPatientId, value: generatedId);
    await _storage.write(key: _kDeviceSecret, value: 'device-sec-${DateTime.now().millisecondsSinceEpoch}');

    state = state.copyWith(user: user);
  }

  Future<void> loginPatient({
    required String name,
    String? patientId,
    String village = 'Rampur Village',
    String language = 'hi',
    String? profilePhotoPath,
  }) async {
    final id = patientId != null && patientId.trim().isNotEmpty
        ? patientId.trim()
        : 'p-${name.toLowerCase().replaceAll(' ', '')}';

    final user = MobileAuthUser(
      userId: id,
      name: name,
      role: AppFlavor.patient,
      region: village,
      language: language,
      profilePhotoPath: profilePhotoPath,
    );

    _applyRoleConfig(AppFlavor.patient);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    await _storage.write(key: _kPatientId, value: id);
    await _storage.write(key: _kDeviceSecret, value: 'device-sec-local');

    state = state.copyWith(user: user);
  }

  Future<void> loginAsha({
    required String ashaId,
    required String name,
    String jurisdiction = 'Rampur Sub-Center',
    String? profilePhotoPath,
  }) async {
    final user = MobileAuthUser(
      userId: ashaId,
      name: name,
      role: AppFlavor.asha,
      region: jurisdiction,
      language: 'hi',
      profilePhotoPath: profilePhotoPath,
    );
    _applyRoleConfig(AppFlavor.asha);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    state = state.copyWith(user: user);
  }

  Future<void> updateProfilePhoto(String photoPath) async {
    if (state.user == null) return;
    final updated = MobileAuthUser(
      userId: state.user!.userId,
      name: state.user!.name,
      role: state.user!.role,
      region: state.user!.region,
      language: state.user!.language,
      age: state.user!.age,
      gender: state.user!.gender,
      caregiverName: state.user!.caregiverName,
      caregiverPhone: state.user!.caregiverPhone,
      medicalNotes: state.user!.medicalNotes,
      profilePhotoPath: photoPath,
    );
    await _storage.write(key: _userKey, value: jsonEncode(updated.toJson()));
    state = state.copyWith(user: updated);
  }

  Future<void> switchRole(AppFlavor newRole) async {
    if (state.user == null) return;
    final updated = MobileAuthUser(
      userId: state.user!.userId,
      name: state.user!.name,
      role: newRole,
      region: state.user!.region,
      language: state.user!.language,
      age: state.user!.age,
      gender: state.user!.gender,
      caregiverName: state.user!.caregiverName,
      caregiverPhone: state.user!.caregiverPhone,
      medicalNotes: state.user!.medicalNotes,
      profilePhotoPath: state.user!.profilePhotoPath,
    );
    _applyRoleConfig(newRole);
    await _storage.write(key: _userKey, value: jsonEncode(updated.toJson()));
    state = state.copyWith(user: updated);
  }

  Future<void> logout() async {
    await _storage.delete(key: _userKey);
    state = state.copyWith(clearUser: true);
  }
}

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authStateProvider = StateNotifierProvider<AuthNotifier, MobileAuthState>((ref) {
  return AuthNotifier(ref.watch(secureStorageProvider));
});
