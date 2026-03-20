import 'package:flutter_riverpod/flutter_riverpod.dart';

class HubSettingsState {
  const HubSettingsState({
    this.useDarkMode = true,
    this.biometricLockEnabled = false,
  });

  final bool useDarkMode;
  final bool biometricLockEnabled;

  HubSettingsState copyWith({
    bool? useDarkMode,
    bool? biometricLockEnabled,
  }) {
    return HubSettingsState(
      useDarkMode: useDarkMode ?? this.useDarkMode,
      biometricLockEnabled: biometricLockEnabled ?? this.biometricLockEnabled,
    );
  }
}

class HubSettingsNotifier extends StateNotifier<HubSettingsState> {
  HubSettingsNotifier() : super(const HubSettingsState());

  void toggleTheme(bool enabled) {
    state = state.copyWith(useDarkMode: enabled);
  }

  void toggleBiometricLock(bool enabled) {
    state = state.copyWith(biometricLockEnabled: enabled);
  }
}

final hubSettingsProvider = StateNotifierProvider<HubSettingsNotifier, HubSettingsState>((ref) {
  return HubSettingsNotifier();
});
