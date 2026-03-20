import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dml_hub/features/hub/presentation/providers/hub_settings_providers.dart';

class HubSettingsPage extends ConsumerWidget {
  const HubSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(hubSettingsProvider);
    final notifier = ref.read(hubSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Hub Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Appearance'),
          ),
          SwitchListTile(
            value: settings.useDarkMode,
            onChanged: notifier.toggleTheme,
            title: const Text('Dark mode'),
            subtitle: const Text('DML Hub is dark-first for MVP.'),
          ),
          const Divider(),
          const ListTile(
            title: Text('Security'),
          ),
          SwitchListTile(
            value: settings.biometricLockEnabled,
            onChanged: notifier.toggleBiometricLock,
            title: const Text('Biometric lock'),
            subtitle: const Text('Require authentication when app lock is enabled.'),
          ),
          const Divider(),
          const AboutListTile(
            applicationName: 'DML Hub',
            applicationVersion: '0.1.0',
            aboutBoxChildren: [
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Android-first productivity platform with a built-in To-Do plugin.'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
