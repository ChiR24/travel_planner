import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';

class StorageState {
  final SharedPreferences? prefs;
  final StorageService? service;
  final bool isInitialized;
  final String? error;

  const StorageState({
    this.prefs,
    this.service,
    this.isInitialized = false,
    this.error,
  });

  StorageState copyWith({
    SharedPreferences? prefs,
    StorageService? service,
    bool? isInitialized,
    String? error,
  }) {
    return StorageState(
      prefs: prefs ?? this.prefs,
      service: service ?? this.service,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error ?? this.error,
    );
  }
}

class StorageNotifier extends StateNotifier<StorageState> {
  StorageNotifier() : super(const StorageState());

  void initialize(SharedPreferences prefs) {
    final service = StorageService(prefs);
    state = StorageState(
      prefs: prefs,
      service: service,
      isInitialized: true,
    );
  }

  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final service = StorageService(prefs);
      state = StorageState(
        prefs: prefs,
        service: service,
        isInitialized: true,
      );
    } catch (e) {
      state = StorageState(error: e.toString());
    }
  }

  SharedPreferences? get prefs => state.prefs;
  StorageService? get service => state.service;
  bool get isInitialized => state.isInitialized;
  String? get error => state.error;
}

final storageProvider =
    StateNotifierProvider<StorageNotifier, StorageState>((ref) {
  return StorageNotifier();
});
