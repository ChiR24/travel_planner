import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/itinerary.dart';
import '../services/itinerary_service.dart';
import '../services/storage_service.dart';
import 'storage_provider.dart';
import 'config_provider.dart';

final itineraryServiceProvider = Provider<ItineraryService>((ref) {
  final geminiApiKey = ref.watch(geminiApiKeyProvider).when(
        data: (key) => key ?? '',
        loading: () => '',
        error: (_, __) => '',
      );
  return ItineraryService(geminiApiKey: geminiApiKey);
});

// Provider to store all itineraries
final itinerariesProvider =
    StateNotifierProvider<ItinerariesNotifier, List<Itinerary>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ItinerariesNotifier(storageService);
});

// Provider to fetch a specific itinerary by ID
final itineraryByIdProvider = Provider.family<Itinerary?, String>((ref, id) {
  final itineraries = ref.watch(itinerariesProvider);
  try {
    return itineraries.firstWhere((itinerary) => itinerary.id == id);
  } catch (_) {
    return null;
  }
});

class GenerationState {
  final bool isLoading;
  final Itinerary? itinerary;
  final String? error;

  const GenerationState({
    this.isLoading = false,
    this.itinerary,
    this.error,
  });

  GenerationState copyWith({
    bool? isLoading,
    Itinerary? itinerary,
    String? error,
  }) {
    return GenerationState(
      isLoading: isLoading ?? this.isLoading,
      itinerary: itinerary ?? this.itinerary,
      error: error ?? this.error,
    );
  }
}

class GenerationNotifier extends StateNotifier<GenerationState> {
  final ItineraryService _itineraryService;
  final ItinerariesNotifier _itinerariesNotifier;

  GenerationNotifier(this._itineraryService, this._itinerariesNotifier)
      : super(const GenerationState());

  Future<void> generateItinerary(GenerateItineraryParams params) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final itinerary = await _itineraryService.generateItinerary(
        origin: params.origin,
        destinations: params.destinations,
        startDate: params.startDate,
        endDate: params.endDate,
        preferences: params.preferences,
      );

      await _itinerariesNotifier.addItinerary(itinerary);
      state = state.copyWith(isLoading: false, itinerary: itinerary);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final generationProvider =
    StateNotifierProvider<GenerationNotifier, GenerationState>((ref) {
  final itineraryService = ref.watch(itineraryServiceProvider);
  final itinerariesNotifier = ref.watch(itinerariesProvider.notifier);
  return GenerationNotifier(itineraryService, itinerariesNotifier);
});

class ItinerariesNotifier extends StateNotifier<List<Itinerary>> {
  final StorageService _storageService;

  ItinerariesNotifier(this._storageService) : super([]) {
    // Load saved itineraries when initialized
    _loadItineraries();
  }

  Future<void> _loadItineraries() async {
    final itineraries = await _storageService.loadItineraries();
    state = itineraries;
  }

  Future<void> addItinerary(Itinerary itinerary) async {
    state = [...state, itinerary];
    await _storageService.saveItineraries(state);
  }

  Future<void> removeItinerary(String id) async {
    state = state.where((itinerary) => itinerary.id != id).toList();
    await _storageService.saveItineraries(state);
  }

  Future<void> updateItinerary(Itinerary updatedItinerary) async {
    state = state.map((itinerary) {
      if (itinerary.id == updatedItinerary.id) {
        return updatedItinerary;
      }
      return itinerary;
    }).toList();
    await _storageService.saveItineraries(state);
  }

  Future<void> clearItineraries() async {
    state = [];
    await _storageService.clearItineraries();
  }
}

class GenerateItineraryParams {
  final String origin;
  final List<String> destinations;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> preferences;

  const GenerateItineraryParams({
    required this.origin,
    required this.destinations,
    required this.startDate,
    required this.endDate,
    required this.preferences,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GenerateItineraryParams &&
        other.origin == origin &&
        other.destinations.length == destinations.length &&
        other.destinations.every((d) => destinations.contains(d)) &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.preferences.length == preferences.length &&
        other.preferences.entries.every(
          (e) =>
              preferences.containsKey(e.key) && preferences[e.key] == e.value,
        );
  }

  @override
  int get hashCode {
    return Object.hash(
      origin,
      Object.hashAll(destinations),
      startDate,
      endDate,
      Object.hashAll(preferences.entries),
    );
  }
}
