import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dml_hub/core/constants/app_spacing.dart';
import 'package:dml_hub/core/theme/app_colors.dart';
import 'package:dml_hub/features/hub/presentation/providers/biometric_providers.dart';

class BiometricLockPage extends ConsumerStatefulWidget {
  const BiometricLockPage({super.key});

  @override
  ConsumerState<BiometricLockPage> createState() => _BiometricLockPageState();
}

class _BiometricLockPageState extends ConsumerState<BiometricLockPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _authenticate();
    }
  }

  Future<void> _authenticate() {
    return ref.read(authenticateWithBiometricProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 64,
              color: AppColors.dmlBlue,
            ).animate().scale(duration: 400.ms).fadeIn(),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'DML Hub',
              style: Theme.of(context).textTheme.headlineMedium,
            ).animate(delay: 100.ms).fadeIn(),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: _authenticate,
              icon: const Icon(Icons.fingerprint_rounded),
              label: const Text('Unlock'),
            ).animate(delay: 200.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}
