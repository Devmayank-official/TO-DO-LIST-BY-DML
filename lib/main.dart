import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dml_hub/features/hub/presentation/providers/biometric_providers.dart';
import 'package:dml_hub/features/hub/presentation/providers/hub_settings_providers.dart';
import 'package:dml_hub/features/hub/presentation/screens/biometric_lock_page.dart';
import 'package:dml_hub/core/di/injection_container.dart';
import 'package:dml_hub/core/router/app_router.dart';
import 'package:dml_hub/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  runApp(const ProviderScope(child: DmlHubApp()));
}

class DmlHubApp extends ConsumerWidget {
  const DmlHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    final settings = ref.watch(hubSettingsProvider);
    final appLocked = ref.watch(appLockStateProvider);

    if (appLocked) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const BiometricLockPage(),
      );
    }

    return MaterialApp.router(
      title: 'DML Hub',
      theme: AppTheme.darkTheme,
      themeMode: settings.useDarkMode ? ThemeMode.dark : ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
