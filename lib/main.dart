import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/plan_screen.dart';
import 'ui/screens/itinerary_details_screen.dart';
import 'ui/screens/my_itineraries_screen.dart';
import 'ui/screens/service_metrics_screen.dart';
import 'ui/screens/theme_settings_screen.dart';
import 'ui/screens/notification_settings_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/trip_management_screen.dart';
import 'ui/screens/about_screen.dart';
import 'ui/screens/splash_screen.dart';
import 'providers/storage_provider.dart';
import 'providers/config_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';
import 'services/config_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'services/offline_storage_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'providers/offline_storage_provider.dart';
import 'providers/trip_management_provider.dart';
import 'services/trip_management_service.dart';
import 'providers/theme_settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  runApp(const ProviderScope(child: MyApp()));
}

final initializationProvider = FutureProvider<void>((ref) async {
  try {
    // Initialize SharedPreferences first
    final prefs = await SharedPreferences.getInstance();
    ref.read(storageProvider.notifier).initialize(prefs);

    // Initialize other services
    final configService = ConfigService();
    await configService.initialize();

    // Initialize connectivity monitoring
    final connectivity = Connectivity();
    final isOffline =
        await connectivity.checkConnectivity() == ConnectivityResult.none;
    ref.read(isOfflineProvider.notifier).state = isOffline;

    // Initialize notification service
    final notificationService = NotificationService();
    await notificationService.initialize();

    // Initialize trip management service
    final tripManagementService = TripManagementService();
    await tripManagementService.initialize().catchError((error) {
      print('Error initializing TripManagementService: $error');
      // Re-throw to ensure the error is properly handled
      throw error;
    });

    // Simulate additional loading time for splash screen
    await Future.delayed(const Duration(seconds: 2));
  } catch (e) {
    print('Error during app initialization: $e');
    rethrow;
  }
});

// Service providers
final configServiceProvider = Provider<ConfigService>((ref) => ConfigService());
final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());
final tripManagementServiceProvider =
    Provider<TripManagementService>((ref) => TripManagementService());

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialization = ref.watch(initializationProvider);
    final themeMode = ref.watch(effectiveThemeModeProvider);
    final theme = ref.watch(effectiveThemeProvider);

    return MaterialApp.router(
      routerConfig: _router,
      title: 'Travel Planner',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        return initialization.when(
          data: (_) => child ?? const SizedBox.shrink(),
          loading: () => const SplashScreen(),
          error: (error, stack) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/plan',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const PlanScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/itinerary/:id',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: ItineraryDetailsScreen(
          itineraryId: state.pathParameters['id']!,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            ),
          );
        },
      ),
    ),
    GoRoute(
      path: '/my-itineraries',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyItinerariesScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
    ),
    GoRoute(
      path: '/metrics',
      builder: (context, state) => const ServiceMetricsScreen(),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/settings/theme',
      builder: (context, state) => const ThemeSettingsScreen(),
    ),
    GoRoute(
      path: '/settings/notifications',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: '/settings/about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/trips',
      builder: (context, state) => const TripManagementScreen(),
    ),
  ],
  errorPageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  ),
);

class TravelPlannerApp extends ConsumerStatefulWidget {
  const TravelPlannerApp({super.key});

  @override
  ConsumerState<TravelPlannerApp> createState() => _TravelPlannerAppState();
}

class _TravelPlannerAppState extends ConsumerState<TravelPlannerApp> {
  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    await ref.read(initializeStorageProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final storageState = ref.watch(storageProvider);
    final theme = ref.watch(effectiveThemeProvider);
    final themeMode = ref.watch(effectiveThemeModeProvider);
    final settings = ref.watch(themeSettingsProvider);

    if (!storageState.isInitialized) {
      return MaterialApp(
        title: 'Travel Planner',
        theme: theme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(settings.textScaleFactor),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (storageState.error != null) {
      return MaterialApp(
        title: 'Travel Planner',
        theme: theme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(settings.textScaleFactor),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: Scaffold(
          body: Center(
            child: Text('Error initializing storage: ${storageState.error}'),
          ),
        ),
      );
    }

    // Monitor storage state
    ref.listen<StorageState>(storageProvider, (previous, current) {
      if (current.error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Storage error: ${current.error}'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                // Add retry logic here if needed
              },
            ),
          ),
        );
      }
    });

    return MaterialApp.router(
      routerConfig: _router,
      title: 'Travel Planner',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.textScaleFactor),
          ),
          child: _AppBuilder(child: child),
        );
      },
    );
  }
}

class _AppBuilder extends ConsumerWidget {
  final Widget? child;

  const _AppBuilder({this.child});

  void showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Monitor connectivity changes
    ref.listen<bool>(isOfflineProvider, (previous, current) {
      if (current) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('You are offline. Changes will be synced when online.'),
            duration: Duration(seconds: 3),
          ),
        );
      } else if (previous == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Back online. Syncing changes...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });

    // Monitor storage state
    ref.listen<StorageState>(storageProvider, (previous, current) {
      if (current.error != null) {
        showErrorDialog(
          context: context,
          title: 'Storage Error',
          message: current.error!,
        );
      }
    });

    return ScaffoldMessenger(child: child ?? const SizedBox.shrink());
  }
}
