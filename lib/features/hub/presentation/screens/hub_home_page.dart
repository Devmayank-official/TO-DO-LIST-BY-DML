import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dml_hub/core/constants/app_routes.dart';
import 'package:dml_hub/core/constants/app_spacing.dart';
import 'package:dml_hub/core/widgets/app_error_widget.dart';
import 'package:dml_hub/core/widgets/app_loading_widget.dart';
import 'package:dml_hub/features/hub/presentation/providers/hub_providers.dart';
import 'package:dml_hub/features/hub/presentation/widgets/plugin_card.dart';

class HubHomePage extends ConsumerWidget {
  const HubHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plugins = ref.watch(installedPluginsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DML Hub'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.hubSettings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: AppSpacing.pagePadding,
        child: plugins.when(
          loading: AppLoadingWidget.new,
          error: (error, _) => AppErrorWidget(message: error.toString()),
          data: (items) => GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.1,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final plugin = items[index];
              return PluginCard(
                title: plugin.displayName,
                description: plugin.description,
                quickStat: plugin.quickStatLabel ?? '',
                onTap: () => context.push(plugin.route),
              ).animate(delay: Duration(milliseconds: index * 80)).fadeIn().slideY(begin: 0.1);
            },
          ),
        ),
      ),
    );
  }
}
