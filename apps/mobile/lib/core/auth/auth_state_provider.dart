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
  });

  final String userId;
  final String name;
  final AppFlavor role;
  final String region;
  final String language;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'role': role == AppFlavor.patient ? 'patient' : 'asha',
        'region': region,
        'language': language,
      };

  factory MobileAuthUser.fromJson(Map<String, dynamic> json) => MobileAuthUser(
        userId: json['userId'] as String? ?? 'user-1',
        name: json['name'] as String? ?? 'User',
        role: (json['role'] as String?) == 'asha' ? AppFlavor.asha : AppFlavor.patient,
        region: json['region'] as String? ?? 'Default',
        language: json['language'] as String? ?? 'hi',
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

  Future<void> loginPatient({
    required String name,
    String village = 'Rampur Village',
    String language = 'hi',
  }) async {
    final user = MobileAuthUser(
      userId: 'p-${name.toLowerCase().replaceAll(' ', '')}',
      name: name,
      role: AppFlavor.patient,
      region: village,
      language: language,
    );
    _applyRoleConfig(AppFlavor.patient);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    state = state.copyWith(user: user);
  }

  Future<void> loginAsha({
    required String ashaId,
    required String name,
    String jurisdiction = 'Rampur Sub-Center',
  }) async {
    final user = MobileAuthUser(
      userId: ashaId,
      name: name,
      role: AppFlavor.asha,
      region: jurisdiction,
      language: 'hi',
    );
    _applyRoleConfig(AppFlavor.asha);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    state = state.copyWith(user: user);
  }

  Future<void> switchRole(AppFlavor newRole) async {
    if (state.user == null) return;
    final updated = MobileAuthUser(
      userId: state.user!.userId,
      name: state.user!.name,
      role: newRole,
      region: state.user!.region,
      language: state.user!.language,
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
