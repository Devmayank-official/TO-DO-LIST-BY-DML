import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dml_hub/features/hub/domain/entities/plugin_info.dart';
import 'package:dml_hub/features/todo/presentation/providers/task_providers.dart';

final installedPluginsProvider = FutureProvider<List<PluginInfo>>((ref) async {
  final todayTaskCount = await ref.watch(todayTasksProvider.future).then((tasks) => tasks.length);

  return <PluginInfo>[
    BuiltInPlugins.todo(quickStatLabel: '$todayTaskCount tasks due today'),
  ];
});
