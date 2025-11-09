import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'providers/theme_provider.dart';
import 'providers/theme_settings_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    print("Environment variables loaded successfully");
  } catch (e) {
    print("Error loading environment variables: $e");
    // Continue with default values
  }

  runApp(const ProviderScope(child: MyApp()));
}



class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(effectiveThemeModeProvider);
    final theme = ref.watch(effectiveThemeProvider);

    return MaterialApp.router(
      routerConfig: _router,
      title: 'Travel Planner',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
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
