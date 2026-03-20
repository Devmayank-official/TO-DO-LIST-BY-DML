import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'package:dml_hub/core/error/failures.dart';
import 'package:dml_hub/core/utils/logger.dart';
import 'package:dml_hub/features/hub/domain/services/biometric_service.dart';

class BiometricServiceImpl implements BiometricService {
  BiometricServiceImpl({
    required LocalAuthentication localAuthentication,
    required FlutterSecureStorage secureStorage,
  })  : _localAuthentication = localAuthentication,
        _secureStorage = secureStorage;

  final LocalAuthentication _localAuthentication;
  final FlutterSecureStorage _secureStorage;

  static const String _lockEnabledKey = 'biometric_lock_enabled';

  @override
  Future<Either<Failure, Unit>> authenticate() async {
    try {
      final authenticated = await _localAuthentication.authenticate(
        localizedReason: 'Unlock DML Hub',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      if (!authenticated) {
        return const Left(AuthFailure('Authentication cancelled'));
      }
      return const Right(unit);
    } catch (error, stackTrace) {
      logger.error('Biometric authentication failed', error, stackTrace);
      return Left(AuthFailure('Authentication failed: $error'));
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      return await _localAuthentication.canCheckBiometrics ||
          await _localAuthentication.isDeviceSupported();
    } catch (error, stackTrace) {
      logger.error('Biometric availability check failed', error, stackTrace);
      return false;
    }
  }

  @override
  Future<bool> isLockEnabled() async {
    final stored = await _secureStorage.read(key: _lockEnabledKey);
    return stored == 'true';
  }

  @override
  Future<Either<Failure, Unit>> setLockEnabled(bool enabled) async {
    try {
      await _secureStorage.write(key: _lockEnabledKey, value: enabled.toString());
      return const Right(unit);
    } catch (error, stackTrace) {
      logger.error('Biometric lock persistence failed', error, stackTrace);
      return const Left(AuthFailure('Failed to update biometric lock setting'));
    }
  }
}
