import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ));

/// The device-bound patient identity. There is NO login: the patient is
/// identified by credentials the ASHA worker provisioned into the OS keystore.
class DeviceIdentity {
  const DeviceIdentity({required this.patientId, required this.deviceSecret});
  final String patientId;
  final String deviceSecret;
}

class DeviceIdentityService {
  DeviceIdentityService(this._storage);
  final FlutterSecureStorage _storage;

  static const _kId = 'smriti.patientId';
  static const _kSecret = 'smriti.deviceSecret';

  Future<DeviceIdentity?> current() async {
    final id = await _storage.read(key: _kId);
    final secret = await _storage.read(key: _kSecret);
    if (id == null || secret == null) return null;
    return DeviceIdentity(patientId: id, deviceSecret: secret);
  }

  /// Called once, during ASHA-driven provisioning (see ARCHITECTURE §4).
  Future<void> store(DeviceIdentity identity) async {
    await _storage.write(key: _kId, value: identity.patientId);
    await _storage.write(key: _kSecret, value: identity.deviceSecret);
  }

  Future<bool> get isProvisioned async => (await current()) != null;
}

final deviceIdentityServiceProvider =
    Provider((ref) => DeviceIdentityService(ref.watch(secureStorageProvider)));

/// Resolves the current identity once; screens gate on this instead of a login.
final deviceIdentityProvider = FutureProvider<DeviceIdentity?>(
  (ref) => ref.watch(deviceIdentityServiceProvider).current(),
);
