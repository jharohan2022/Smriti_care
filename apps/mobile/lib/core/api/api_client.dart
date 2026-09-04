import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/flavor_config.dart';
import '../services/device_identity_service.dart';

/// Sealed failure type — the single error boundary the whole app maps network
/// problems into. Screens can `switch` over it exhaustively.
sealed class ApiFailure implements Exception {
  const ApiFailure(this.message);
  final String message;
  @override
  String toString() => 'ApiFailure($message)';
}

class NetworkFailure extends ApiFailure {
  const NetworkFailure() : super('No internet connection');
}

class TimeoutFailure extends ApiFailure {
  const TimeoutFailure() : super('The server took too long to respond');
}

class UnauthorizedFailure extends ApiFailure {
  const UnauthorizedFailure() : super('Device is not authorised');
}

class ServerFailure extends ApiFailure {
  const ServerFailure(this.statusCode, String message) : super(message);
  final int? statusCode;
}

/// Thin Dio wrapper. Every call funnels DioExceptions through [_map] so callers
/// only ever see an [ApiFailure], never a raw transport exception.
class ApiClient {
  ApiClient(this._dio);
  final Dio _dio;

  Future<Response<T>> post<T>(String path, {Object? data}) =>
      _guard(() => _dio.post<T>(path, data: data));

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) =>
      _guard(() => _dio.get<T>(path, queryParameters: query));

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() run) async {
    try {
      return await run();
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  ApiFailure _map(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
        return const NetworkFailure();
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 401 || code == 403) return const UnauthorizedFailure();
        return ServerFailure(code, 'Server error ($code)');
      default:
        return const NetworkFailure();
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final cfg = FlavorConfig.instance;
  final dio = Dio(BaseOptions(
    baseUrl: cfg.apiBaseUrl,
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
  ));

  // Sign patient requests with the device-bound secret (zero-auth model).
  dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
    final identity = await ref.read(deviceIdentityServiceProvider).current();
    if (identity != null) {
      options.headers['X-Patient-Id'] = identity.patientId;
      options.headers['X-Device-Secret'] = identity.deviceSecret;
    }
    handler.next(options);
  }));

  return ApiClient(dio);
});
