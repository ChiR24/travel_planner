import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_planner_2/ui/screens/home_screen.dart';
import 'package:travel_planner_2/ui/screens/plan_screen.dart';
import 'package:travel_planner_2/ui/screens/itinerary_details_screen.dart';
import 'package:travel_planner_2/ui/screens/my_itineraries_screen.dart';
import 'package:travel_planner_2/ui/screens/service_metrics_screen.dart';
import 'package:travel_planner_2/ui/screens/theme_settings_screen.dart';
import 'package:travel_planner_2/ui/screens/notification_settings_screen.dart';
import 'package:travel_planner_2/ui/screens/settings_screen.dart';
import 'package:travel_planner_2/ui/screens/trip_management_screen.dart';
import 'package:travel_planner_2/ui/screens/about_screen.dart';
import 'package:travel_planner_2/providers/storage_provider.dart';
import 'package:travel_planner_2/providers/config_provider.dart';
import 'package:travel_planner_2/providers/theme_provider.dart';
import 'package:travel_planner_2/providers/notification_provider.dart';
import 'package:travel_planner_2/services/config_service.dart';
import 'package:travel_planner_2/services/notification_service.dart';
import 'package:travel_planner_2/theme/app_theme.dart';
import 'package:travel_planner_2/services/offline_storage_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'providers/offline_storage_provider.dart';
import 'providers/trip_management_provider.dart';
import 'services/trip_management_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final prefs = await SharedPreferences.getInstance();
  final configService = ConfigService();
  await configService.initialize();

  // Initialize connectivity monitoring
  final connectivity = Connectivity();
  final isOffline =
      await connectivity.checkConnectivity() == ConnectivityResult.none;

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize trip management service
  final tripManagementService = TripManagementService();
  await tripManagementService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        configServiceProvider.overrideWithValue(configService),
        isOfflineProvider.overrideWith((ref) => isOffline),
        notificationServiceProvider.overrideWithValue(notificationService),
        tripManagementServiceProvider.overrideWithValue(tripManagementService),
      ],
      child: const TravelPlannerApp(),
    ),
  );
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/plan',
      builder: (context, state) => const PlanScreen(),
    ),
    GoRoute(
      path: '/itinerary/:id',
      builder: (context, state) => ItineraryDetailsScreen(
        itineraryId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/my-itineraries',
      builder: (context, state) => const MyItinerariesScreen(),
    ),
    GoRoute(
      path: '/metrics',
      builder: (context, state) => const ServiceMetricsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
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
    final storageState = ref.watch(storageStateProvider);
    final theme = ref.watch(effectiveThemeProvider);
    final themeMode = ref.watch(effectiveThemeModeProvider);

    if (storageState == StorageState.initializing) {
      return MaterialApp(
        title: 'Travel Planner',
        theme: theme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler:
                  TextScaler.linear(ref.watch(themeProvider).textScaleFactor),
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
            textScaler:
                TextScaler.linear(ref.watch(themeProvider).textScaleFactor),
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
    ref.listen<StorageState>(storageStateProvider, (previous, current) {
      if (current == StorageState.error) {
        final error = ref.read(storageErrorProvider);
        if (error != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Storage error: ${error.message}'),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () => ref.read(initializeStorageProvider.future),
              ),
            ),
          );
        }
      }
    });

    return ScaffoldMessenger(child: child ?? const SizedBox.shrink());
  }
}
