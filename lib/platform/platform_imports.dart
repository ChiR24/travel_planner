import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/offline_storage_provider.dart';
import '../services/notification_service.dart';
import '../services/trip_management_service.dart';

/// Initialize platform-specific services for non-web platforms
Future<void> initializePlatformServices() async {
  // Initialize Hive for native platforms
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  print(
      'Initialized Hive for native platform with path: ${appDocumentDir.path}');
}

/// Initialize provider-specific services for non-web platforms
Future<void> initializeProviderServices<T>(Ref ref) async {
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
}
