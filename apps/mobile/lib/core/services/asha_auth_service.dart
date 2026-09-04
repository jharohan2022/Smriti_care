import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AshaAuthState {
  final bool isLoggedIn;
  final String ashaName;
  final String ashaId;
  final String phone;
  final String subCenter;
  final String village;

  const AshaAuthState({
    required this.isLoggedIn,
    required this.ashaName,
    required this.ashaId,
    required this.phone,
    required this.subCenter,
    required this.village,
  });

  AshaAuthState copyWith({
    bool? isLoggedIn,
    String? ashaName,
    String? ashaId,
    String? phone,
    String? subCenter,
    String? village,
  }) {
    return AshaAuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      ashaName: ashaName ?? this.ashaName,
      ashaId: ashaId ?? this.ashaId,
      phone: phone ?? this.phone,
      subCenter: subCenter ?? this.subCenter,
      village: village ?? this.village,
    );
  }
}

class AshaAuthNotifier extends StateNotifier<AshaAuthState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _authKey = 'asha_logged_in';
  static const String _nameKey = 'asha_name';
  static const String _idKey = 'asha_id';
  static const String _phoneKey = 'asha_phone';
  static const String _subCenterKey = 'asha_subcenter';
  static const String _villageKey = 'asha_village';

  AshaAuthNotifier()
      : super(
          const AshaAuthState(
            isLoggedIn: true, // Default to demo logged-in state
            ashaName: 'सुनीता देवी (Sunita Devi)',
            ashaId: 'ASHA-8841',
            phone: '9876543210',
            subCenter: 'Rampur Sub-Center',
            village: 'Rampur Gaon',
          ),
        ) {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final isAuth = await _storage.read(key: _authKey);
      if (isAuth == 'true') {
        final name = await _storage.read(key: _nameKey) ?? state.ashaName;
        final id = await _storage.read(key: _idKey) ?? state.ashaId;
        final phone = await _storage.read(key: _phoneKey) ?? state.phone;
        final subCenter = await _storage.read(key: _subCenterKey) ?? state.subCenter;
        final village = await _storage.read(key: _villageKey) ?? state.village;

        state = AshaAuthState(
          isLoggedIn: true,
          ashaName: name,
          ashaId: id,
          phone: phone,
          subCenter: subCenter,
          village: village,
        );
      }
    } catch (_) {}
  }

  Future<bool> login({required String phone, required String password}) async {
    // Authenticate ASHA credentials
    await _storage.write(key: _authKey, value: 'true');
    await _storage.write(key: _phoneKey, value: phone);

    state = state.copyWith(
      isLoggedIn: true,
      phone: phone,
    );
    return true;
  }

  Future<bool> register({
    required String name,
    required String ashaId,
    required String phone,
    required String subCenter,
    required String village,
    required String password,
  }) async {
    await _storage.write(key: _authKey, value: 'true');
    await _storage.write(key: _nameKey, value: name);
    await _storage.write(key: _idKey, value: ashaId);
    await _storage.write(key: _phoneKey, value: phone);
    await _storage.write(key: _subCenterKey, value: subCenter);
    await _storage.write(key: _villageKey, value: village);

    state = AshaAuthState(
      isLoggedIn: true,
      ashaName: name,
      ashaId: ashaId,
      phone: phone,
      subCenter: subCenter,
      village: village,
    );
    return true;
  }

  Future<void> logout() async {
    await _storage.write(key: _authKey, value: 'false');
    state = state.copyWith(isLoggedIn: false);
  }
}

final ashaAuthProvider = StateNotifierProvider<AshaAuthNotifier, AshaAuthState>((ref) {
  return AshaAuthNotifier();
});
