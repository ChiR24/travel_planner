import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/offline_storage_service.dart';

final offlineStorageProvider = Provider<OfflineStorageService>((ref) {
  final service = OfflineStorageService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Provider for offline status
final isOfflineProvider = StateProvider<bool>((ref) => false);

// Provider for sync status
final lastSyncTimeProvider = FutureProvider<DateTime?>((ref) async {
  try {
    final storage = ref.watch(offlineStorageProvider);
    return storage.getLastSyncTime();
  } on OfflineStorageException catch (e) {
    // Log the error but don't rethrow - return null instead
    print('Error getting last sync time: $e');
    return null;
  }
});

// Provider for pending sync operations
final pendingSyncCountProvider = StateProvider<int>((ref) => 0);

// Provider for storage errors
final storageErrorProvider =
    StateProvider<OfflineStorageException?>((ref) => null);

// Storage state provider
enum OfflineStorageState { initializing, ready, error }

final storageStateProvider = StateProvider<OfflineStorageState>((ref) {
  return OfflineStorageState.initializing;
});

// Initialize storage
final initializeStorageProvider = FutureProvider<void>((ref) async {
  final storage = ref.watch(offlineStorageProvider);
  final storageState = ref.watch(storageStateProvider.notifier);
  final storageError = ref.watch(storageErrorProvider.notifier);

  try {
    storageState.state = OfflineStorageState.initializing;
    await storage.initialize();
    storageState.state = OfflineStorageState.ready;
    storageError.state = null;
  } on OfflineStorageException catch (e) {
    storageState.state = OfflineStorageState.error;
    storageError.state = e;
    rethrow;
  }
});
