import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits `true` when any network transport is available. Everything offline-aware
/// (the sync manager, the ASHA sync widget, the web-parity banners) watches this.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final conn = Connectivity();
  bool online(List<ConnectivityResult> r) =>
      r.any((e) => e != ConnectivityResult.none);

  yield online(await conn.checkConnectivity());
  yield* conn.onConnectivityChanged.map(online);
});

/// Synchronous "best known" online state (defaults to offline until the stream
/// resolves — we assume offline so we never optimistically block on the network).
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).maybeWhen(
        data: (v) => v,
        orElse: () => false,
      );
});
