import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_planner_2/ui/screens/home_screen.dart';
import 'package:travel_planner_2/ui/screens/plan_screen.dart';
import 'package:travel_planner_2/ui/screens/itinerary_details_screen.dart';
import 'package:travel_planner_2/ui/screens/my_itineraries_screen.dart';
import 'package:travel_planner_2/ui/screens/service_metrics_screen.dart';
import 'package:travel_planner_2/providers/storage_provider.dart';
import 'package:travel_planner_2/providers/config_provider.dart';
import 'package:travel_planner_2/services/config_service.dart';
import 'package:travel_planner_2/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Initialize config service
  final configService = ConfigService();
  await configService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        configServiceProvider.overrideWithValue(configService),
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
  ],
);

class TravelPlannerApp extends StatelessWidget {
  const TravelPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Travel Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
