import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dml_hub/core/di/injection_container.dart';
import 'package:dml_hub/features/hub/domain/services/biometric_service.dart';

final biometricAvailableProvider = FutureProvider<bool>((ref) {
  return getIt<BiometricService>().isAvailable();
});

final biometricLockEnabledProvider = FutureProvider<bool>((ref) {
  return getIt<BiometricService>().isLockEnabled();
});

class AppLockNotifier extends StateNotifier<bool> {
  AppLockNotifier() : super(false);

  void lock() => state = true;
  void unlock() => state = false;
}

final appLockStateProvider = StateNotifierProvider<AppLockNotifier, bool>((ref) {
  return AppLockNotifier();
});

final authenticateWithBiometricProvider = FutureProvider<void>((ref) async {
  final result = await getIt<BiometricService>().authenticate();
  result.fold(
    (_) => ref.read(appLockStateProvider.notifier).lock(),
    (_) => ref.read(appLockStateProvider.notifier).unlock(),
  );
});
