# hub-SKILLS.md
# DML Hub — Hub Shell Skills & Patterns
# Company: DML Labs | Package: com.dmllabs.hub
# Attach: When working on Hub Home, plugin registry, global settings, biometric lock, plugin card UI
# Always attach ALONGSIDE: SYSTEM_PROMPT.md + core-SKILLS.md

---

## 📁 HUB FEATURE FOLDER STRUCTURE

```
lib/features/hub/
├── data/
│   ├── datasources/
│   │   └── hub_local_datasource.dart    # Reads plugin registry from secure storage
│   └── repositories/
│       └── hub_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   └── plugin_info.dart             # Plugin metadata entity
│   ├── repositories/
│   │   └── hub_repository.dart          # Abstract interface
│   └── usecases/
│       ├── get_installed_plugins_usecase.dart
│       └── get_plugin_quick_stats_usecase.dart
│
└── presentation/
    ├── providers/
    │   ├── hub_providers.dart            # Plugin list, settings state
    │   ├── hub_providers.g.dart          # Generated
    │   ├── biometric_providers.dart      # Biometric lock state
    │   └── biometric_providers.g.dart
    ├── screens/
    │   ├── hub_home_page.dart            # Main launcher screen
    │   ├── hub_settings_page.dart        # Global settings
    │   └── biometric_lock_page.dart      # App lock screen
    └── widgets/
        ├── plugin_card.dart              # Individual plugin launcher card
        ├── plugin_card_header.dart       # Icon + name + quick stat
        ├── plugin_quick_stat.dart        # Live data preview on card
        └── hub_app_bar.dart              # Hub top app bar
```

---

## 🧩 SKILL 1 — PLUGIN REGISTRY ARCHITECTURE

### Rule
The Hub MUST NOT know about plugin implementation details.
Plugins register themselves via a `PluginInfo` entity — nothing more.
Hub renders plugin cards using ONLY `PluginInfo` data.
Adding a new plugin = add a new `PluginInfo` to the registry. Zero Hub changes.
Plugin routes are pre-defined in AppRoutes — Hub uses route strings to launch.

### Pattern: plugin_info.dart (domain entity)
```dart
/// Metadata for a DML Hub plugin.
/// Hub ONLY knows this — never imports from plugin features directly.
@freezed
class PluginInfo with _$PluginInfo {
  const factory PluginInfo({
    /// Unique identifier — matches route segment (e.g., 'todo', 'habits')
    required String id,

    /// Display name shown on plugin card
    required String displayName,

    /// Material icon for plugin card
    required IconData icon,

    /// One-line plugin description
    required String description,

    /// Route to push when card is tapped (from AppRoutes)
    required String route,

    /// Whether this plugin is currently enabled
    required bool isEnabled,

    /// Plugin version string
    required String version,

    /// Quick stat shown on card (e.g., "3 tasks due today")
    /// Null = no quick stat shown
    String? quickStatLabel,
  }) = _PluginInfo;
}
```

### Pattern: Plugin Registry (hardcoded for MVP built-in plugins)
```dart
/// Built-in plugin registry for DML Hub MVP.
/// For MVP: plugins are hardcoded here.
/// For Phase 10+: this will be replaced with a dynamic plugin loader.
abstract final class BuiltInPlugins {
  static const List<String> registeredIds = ['todo'];

  static PluginInfo todo({String? quickStatLabel}) => PluginInfo(
    id: 'todo',
    displayName: 'To-Do',
    icon: Icons.checklist_rounded,
    description: 'Tasks, projects & priorities',
    route: AppRoutes.todoToday,
    isEnabled: true,
    version: '1.0.0',
    quickStatLabel: quickStatLabel,
  );

  // ─── FUTURE PLUGIN STUBS (disabled until implemented) ─────
  // static PluginInfo habits() => PluginInfo(id: 'habits', ...)
  // static PluginInfo journal() => PluginInfo(id: 'journal', ...)
  // static PluginInfo notes()   => PluginInfo(id: 'notes', ...)
  // static PluginInfo goals()   => PluginInfo(id: 'goals', ...)
  // static PluginInfo focus()   => PluginInfo(id: 'focus', ...)
}
```

---

## 🏠 SKILL 2 — HUB HOME SCREEN

### Rule
Hub Home is MINIMAL: plugin cards grid + settings icon ONLY.
No bottom navigation bar on Hub Home — settings via top-right icon.
Plugin card tap → `context.push(plugin.route)` — ALWAYS push, never go().
Quick stat on each card reads from Riverpod providers (reactive, live data).
Use flutter_animate for card entrance animations (staggered list).

### Pattern: hub_home_page.dart
```dart
/// DML Hub home screen — plugin launcher.
/// Minimal: plugin cards + settings icon. Nothing else.
class HubHomePage extends ConsumerWidget {
  const HubHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plugins = ref.watch(installedPluginsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: HubAppBar(
        onSettingsTap: () => context.push(AppRoutes.hubSettings),
      ),
      body: SafeArea(
        child: plugins.when(
          loading: () => const AppLoadingWidget(),
          error: (e, _) => AppErrorWidget(message: e.toString()),
          data: (pluginList) => _PluginGrid(plugins: pluginList),
        ),
      ),
    );
  }
}

/// Plugin grid — staggered entrance animation via flutter_animate
class _PluginGrid extends StatelessWidget {
  const _PluginGrid({required this.plugins});
  final List<PluginInfo> plugins;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.1,
        ),
        itemCount: plugins.length,
        itemBuilder: (context, index) {
          return PluginCard(plugin: plugins[index])
            .animate(delay: Duration(milliseconds: index * 80))
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms);
        },
      ),
    );
  }
}
```

### Pattern: hub_app_bar.dart
```dart
/// DML Hub top app bar — minimal, brand-forward.
class HubAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HubAppBar({super.key, required this.onSettingsTap});
  final VoidCallback onSettingsTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'DML ',
              style: GoogleFonts.nunitoSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.dmlBlue,
              ),
            ),
            TextSpan(
              text: 'Hub',
              style: GoogleFonts.nunitoSans(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: onSettingsTap,
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
        ),
      ],
    );
  }
}
```

---

## 🃏 SKILL 3 — PLUGIN CARD WIDGET

### Rule
PluginCard is a pure display widget — it receives PluginInfo only.
Hero tag = plugin.id — enables shared element transition (Phase 2+).
Tap handler is ALWAYS context.push() — never passed as callback.
Quick stat text is pre-resolved by provider before passing to card.

### Pattern: plugin_card.dart
```dart
/// Individual plugin launcher card on Hub Home.
/// Hero-tagged for future shared element transition (Phase 2+).
class PluginCard extends StatelessWidget {
  const PluginCard({super.key, required this.plugin});
  final PluginInfo plugin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Hero(
      tag: 'plugin_card_${plugin.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(plugin.route),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: AppColors.dmlBlueDeep.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Icon ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.dmlBlueDeep,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    plugin.icon,
                    color: AppColors.dmlBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ─── Plugin Name ───────────────────────────
                Text(
                  plugin.displayName,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),

                // ─── Quick Stat ────────────────────────────
                if (plugin.quickStatLabel != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    plugin.quickStatLabel!,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.contentSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 🔒 SKILL 4 — BIOMETRIC LOCK

### Rule
Biometric lock is Hub-level — it protects ALL plugins, not individual plugins.
On app resume (lifecycle: resumed), check lock state before showing Hub Home.
Use local_auth package — NEVER implement custom auth.
Biometric settings stored in flutter_secure_storage (not SharedPreferences).
Fallback: device PIN/pattern if biometric fails.

### Pattern: BiometricService (domain interface)
```dart
/// Abstract biometric authentication service.
abstract class BiometricService {
  /// Returns true if device supports biometric auth
  Future<bool> isAvailable();

  /// Returns true if biometric lock is enabled by user
  Future<bool> isLockEnabled();

  /// Enable/disable biometric lock
  Future<Either<Failure, Unit>> setLockEnabled(bool enabled);

  /// Authenticate — returns Right(unit) on success
  Future<Either<Failure, Unit>> authenticate();
}
```

### Pattern: BiometricServiceImpl (data layer)
```dart
class BiometricServiceImpl implements BiometricService {
  BiometricServiceImpl({
    required LocalAuthentication localAuth,
    required FlutterSecureStorage secureStorage,
  })  : _localAuth = localAuth,
        _secureStorage = secureStorage;

  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  static const _lockEnabledKey = 'biometric_lock_enabled';

  @override
  Future<bool> isAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics ||
             await _localAuth.isDeviceSupported();
    } catch (e, st) {
      logger.error('BiometricService: isAvailable failed', error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<bool> isLockEnabled() async {
    final value = await _secureStorage.read(key: _lockEnabledKey);
    return value == 'true';
  }

  @override
  Future<Either<Failure, Unit>> setLockEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: _lockEnabledKey,
        value: enabled.toString(),
      );
      return const Right(unit);
    } catch (e, st) {
      logger.error('BiometricService: setLockEnabled failed', error: e, stackTrace: st);
      return const Left(AuthFailure('Failed to update lock setting'));
    }
  }

  @override
  Future<Either<Failure, Unit>> authenticate() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Unlock DML Hub',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // allow device PIN as fallback
        ),
      );
      if (authenticated) return const Right(unit);
      return const Left(AuthFailure('Authentication cancelled'));
    } catch (e, st) {
      logger.error('BiometricService: authenticate failed', error: e, stackTrace: st);
      return Left(AuthFailure('Authentication failed: ${e.toString()}'));
    }
  }
}
```

### Pattern: biometric_providers.dart
```dart
/// Tracks whether app is currently locked
@riverpod
class AppLockState extends _$AppLockState {
  @override
  bool build() => false; // false = locked initially, resolved in app lifecycle

  void lock() => state = true;
  void unlock() => state = false;
}

/// Triggers biometric authentication
@riverpod
Future<void> authenticateWithBiometric(AuthenticateWithBiometricRef ref) async {
  final service = getIt<BiometricService>();
  final result = await service.authenticate();
  result.fold(
    (failure) => logger.warning('Biometric auth failed: ${failure.message}'),
    (_) => ref.read(appLockStateProvider.notifier).unlock(),
  );
}
```

### Pattern: biometric_lock_page.dart
```dart
/// Shown when app is locked — full screen biometric prompt.
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
    // Auto-trigger on page open
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _authenticate();
  }

  Future<void> _authenticate() async {
    await ref.read(authenticateWithBiometricProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDeepNavy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 64, color: AppColors.dmlBlue)
              .animate().scale(duration: 400.ms).fadeIn(),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'DML Hub',
              style: GoogleFonts.nunitoSans(
                fontSize: 28, fontWeight: FontWeight.w800,
                color: AppColors.contentPrimary,
              ),
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
```

---

## ⚙️ SKILL 5 — HUB SETTINGS SCREEN

### Rule
Hub Settings = GLOBAL settings only (theme mode, biometric lock, about).
Plugin-level settings live inside the plugin itself at /hub/{plugin}/settings.
Settings state uses Riverpod + flutter_secure_storage for persistence.
NEVER use SharedPreferences — ALWAYS flutter_secure_storage for settings.

### Pattern: Hub Settings Sections (MVP)
```dart
/// Hub Settings sections for MVP.
/// Plugin settings are NOT here — they're inside each plugin.
enum HubSettingSection {
  appearance,    // Dark/Light/System theme toggle
  security,      // Biometric lock enable/disable
  about,         // App version, DML Labs credits
}
```

### Pattern: hub_settings_page.dart (structure only)
```dart
class HubSettingsPage extends ConsumerWidget {
  const HubSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ─── Appearance ──────────────────────────────────
          _SettingsSection(
            title: 'Appearance',
            children: [_ThemeModeSelector()],
          ),

          // ─── Security ────────────────────────────────────
          _SettingsSection(
            title: 'Security',
            children: [_BiometricLockToggle()],
          ),

          // ─── About ───────────────────────────────────────
          _SettingsSection(
            title: 'About',
            children: [
              _AboutTile(label: 'Version', value: '1.0.0'),
              _AboutTile(label: 'Company', value: 'DML Labs'),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## 🔄 SKILL 6 — HUB PROVIDERS

### Pattern: hub_providers.dart
```dart
/// Provides list of installed + enabled plugins with live quick stats.
@riverpod
Future<List<PluginInfo>> installedPlugins(InstalledPluginsRef ref) async {
  // Watch todo quick stat reactively
  final todayTaskCount = await ref.watch(todayTaskCountProvider.future);

  return [
    BuiltInPlugins.todo(
      quickStatLabel: todayTaskCount > 0
          ? '$todayTaskCount task${todayTaskCount == 1 ? '' : 's'} today'
          : 'All clear today ✓',
    ),
    // Future plugins added here — zero Hub screen changes needed
  ];
}

/// Current theme mode — persisted in secure storage
@riverpod
class ThemeModeState extends _$ThemeModeState {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    _loadPersistedMode(); // async load, starts with system default
    return ThemeMode.system;
  }

  Future<void> _loadPersistedMode() async {
    final storage = getIt<FlutterSecureStorage>();
    final value = await storage.read(key: _key);
    if (value != null) {
      state = ThemeMode.values.byName(value);
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final storage = getIt<FlutterSecureStorage>();
    await storage.write(key: _key, value: mode.name);
    logger.info('ThemeMode changed to: ${mode.name}');
  }
}
```

---

## 📋 SKILL 7 — HOW TO ADD A NEW PLUGIN (Future Reference)

> When implementing Phase 2+ plugins, follow this exact checklist:

```
STEP 1: Create lib/features/{plugin-name}/ with data/domain/presentation/
STEP 2: Add route constants to AppRoutes:
         static const String {name}Root = '/hub/{name}';
STEP 3: Add ShellRoute to app_router.dart under /hub routes
STEP 4: Add PluginInfo factory to BuiltInPlugins registry
STEP 5: Add plugin to installedPlugins provider list
STEP 6: Add any cross-plugin quick-stat provider if needed
STEP 7: Register plugin dependencies in injection_container.dart
DONE — Hub Home automatically shows the new plugin card.
       Zero changes to HubHomePage, PluginCard, or HubAppBar.
```

---

# END OF hub-SKILLS.md
# Attach with: SYSTEM_PROMPT.md + core-SKILLS.md
# When to attach: Hub Home, plugin registry, biometric lock, global settings, adding new plugins
