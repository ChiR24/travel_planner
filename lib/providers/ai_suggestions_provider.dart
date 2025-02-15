import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_suggestions_service.dart';
import '../models/activity_category.dart';
import 'config_provider.dart';

final aiSuggestionsServiceProvider = Provider<AISuggestionsService>((ref) {
  final geminiApiKey = ref.watch(geminiApiKeyProvider).when(
        data: (key) => key ?? '',
        loading: () => '',
        error: (_, __) => '',
      );
  return AISuggestionsService(geminiApiKey: geminiApiKey);
});

final activitySuggestionsProvider = FutureProvider.autoDispose.family<
    Map<String, dynamic>,
    ({
      String location,
      DateTime date,
      List<ActivityCategory> preferredCategories,
      Map<String, dynamic> preferences,
    })>((ref, params) async {
  final service = ref.watch(aiSuggestionsServiceProvider);
  return service.getSuggestedActivities(
    location: params.location,
    date: params.date,
    preferredCategories: params.preferredCategories,
    preferences: params.preferences,
  );
});

final localCustomsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, location) async {
  final service = ref.watch(aiSuggestionsServiceProvider);
  return service.getLocalCustoms(location);
});

final safetyInfoProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, location) async {
  final service = ref.watch(aiSuggestionsServiceProvider);
  return service.getSafetyInfo(location);
});

// Cache for suggestions to avoid unnecessary API calls
final _suggestionsCache = <String, Map<String, dynamic>>{};

// Helper function to generate cache key
String _generateCacheKey(String type, String location, [DateTime? date]) {
  if (date != null) {
    return '$type:$location:${date.toIso8601String()}';
  }
  return '$type:$location';
}

// Extension for caching suggestions
extension SuggestionsCaching on AISuggestionsService {
  Future<Map<String, dynamic>> getCachedSuggestions({
    required String type,
    required String location,
    required Future<Map<String, dynamic>> Function() fetcher,
    DateTime? date,
    Duration cacheDuration = const Duration(hours: 24),
  }) async {
    final cacheKey = _generateCacheKey(type, location, date);
    final cachedData = _suggestionsCache[cacheKey];

    if (cachedData != null) {
      final timestamp = cachedData['_timestamp'] as int?;
      if (timestamp != null &&
          DateTime.now().millisecondsSinceEpoch - timestamp <
              cacheDuration.inMilliseconds) {
        return cachedData;
      }
    }

    final freshData = await fetcher();
    _suggestionsCache[cacheKey] = {
      ...freshData,
      '_timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    return freshData;
  }
}

// Provider for suggestion history
final suggestionHistoryProvider = StateNotifierProvider<
    SuggestionHistoryNotifier,
    List<Map<String, dynamic>>>((ref) => SuggestionHistoryNotifier());

class SuggestionHistoryNotifier
    extends StateNotifier<List<Map<String, dynamic>>> {
  SuggestionHistoryNotifier() : super([]);

  void addSuggestion(Map<String, dynamic> suggestion) {
    state = [suggestion, ...state];
    if (state.length > 50) {
      // Keep only the last 50 suggestions
      state = state.take(50).toList();
    }
  }

  void clearHistory() {
    state = [];
  }

  List<Map<String, dynamic>> getForLocation(String location) {
    return state.where((s) => s['location'] == location).toList();
  }

  List<Map<String, dynamic>> getForCategory(ActivityCategory category) {
    return state.where((s) => s['category'] == category.toString()).toList();
  }
}
