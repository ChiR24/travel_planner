import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/route_suggestions_service.dart';
import 'config_provider.dart';

// Global cache for suggestions
final _suggestionsCache = <String, Map<String, dynamic>>{};

final routeSuggestionsServiceProvider =
    Provider<RouteSuggestionsService>((ref) {
  final geminiApiKey = ref.watch(geminiApiKeyProvider).when(
        data: (key) => key ?? '',
        loading: () => '',
        error: (_, __) => '',
      );
  return RouteSuggestionsService(geminiApiKey);
});

// Main suggestions provider
final routeSuggestionsProvider = FutureProvider.autoDispose.family<
    Map<String, dynamic>,
    ({
      String startLocation,
      String destination,
      Map<String, dynamic> routeInfo,
    })>((ref, params) async {
  final service = ref.watch(routeSuggestionsServiceProvider);
  final cacheKey = '${params.startLocation}_${params.destination}';

  // Check memory cache first
  if (_suggestionsCache.containsKey(cacheKey)) {
    return _suggestionsCache[cacheKey]!;
  }

  try {
    final suggestions = await service.getSuggestions(
      startLocation: params.startLocation,
      destination: params.destination,
      routeInfo: params.routeInfo,
    );

    // Cache successful responses
    if (suggestions['error'] == null) {
      _suggestionsCache[cacheKey] = suggestions;

      // Set up cache invalidation after 30 minutes
      Future.delayed(const Duration(minutes: 30), () {
        _suggestionsCache.remove(cacheKey);
      });
    } else {
      // If there's an error in the response, don't cache it
      print('Error in suggestions response: ${suggestions['error']}');
      if (suggestions['raw'] != null) {
        print('Raw response: ${suggestions['raw']}');
      }
    }

    return suggestions;
  } on TimeoutException catch (e) {
    print('Timeout while getting suggestions: $e');
    return {
      'error': 'Request timed out. Please try again.',
    };
  } catch (e) {
    print('Error while getting suggestions: $e');
    // Add error to cache temporarily
    _suggestionsCache[cacheKey] = {
      'error': e.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Remove error from cache after 1 minute
    Future.delayed(const Duration(minutes: 1), () {
      if (_suggestionsCache[cacheKey]?['error'] != null) {
        _suggestionsCache.remove(cacheKey);
      }
    });

    rethrow;
  }
});

// Split providers for each section
final travelTipsProvider = FutureProvider.autoDispose.family<
    List<dynamic>,
    ({
      String startLocation,
      String destination,
      Map<String, dynamic> routeInfo,
    })>((ref, params) async {
  final suggestions = await _getSuggestions(ref, params);
  return suggestions['travelTips'] as List<dynamic>;
});

final weatherInfoProvider = FutureProvider.autoDispose.family<
    Map<String, dynamic>,
    ({
      String startLocation,
      String destination,
      Map<String, dynamic> routeInfo,
    })>((ref, params) async {
  final suggestions = await _getSuggestions(ref, params);
  return suggestions['weatherConsideration'] as Map<String, dynamic>;
});

final trafficInfoProvider = FutureProvider.autoDispose.family<
    Map<String, dynamic>,
    ({
      String startLocation,
      String destination,
      Map<String, dynamic> routeInfo,
    })>((ref, params) async {
  final suggestions = await _getSuggestions(ref, params);
  return suggestions['trafficTips'] as Map<String, dynamic>;
});

Future<Map<String, dynamic>> _getSuggestions(
  Ref ref,
  ({
    String startLocation,
    String destination,
    Map<String, dynamic> routeInfo,
  }) params,
) async {
  final service = ref.watch(routeSuggestionsServiceProvider);
  final cacheKey = '${params.startLocation}_${params.destination}';

  // Check memory cache first
  if (_suggestionsCache.containsKey(cacheKey)) {
    return _suggestionsCache[cacheKey]!;
  }

  try {
    final suggestions = await service.getSuggestions(
      startLocation: params.startLocation,
      destination: params.destination,
      routeInfo: params.routeInfo,
    );

    // Cache successful responses
    if (suggestions['error'] == null) {
      _suggestionsCache[cacheKey] = suggestions;

      // Set up cache invalidation after 30 minutes
      Future.delayed(const Duration(minutes: 30), () {
        _suggestionsCache.remove(cacheKey);
      });
    } else {
      // If there's an error in the response, don't cache it
      print('Error in suggestions response: ${suggestions['error']}');
      if (suggestions['raw'] != null) {
        print('Raw response: ${suggestions['raw']}');
      }
    }

    return suggestions;
  } on TimeoutException catch (e) {
    print('Timeout while getting suggestions: $e');
    return {
      'error': 'Request timed out. Please try again.',
    };
  } catch (e) {
    print('Error while getting suggestions: $e');
    // Add error to cache temporarily
    _suggestionsCache[cacheKey] = {
      'error': e.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Remove error from cache after 1 minute
    Future.delayed(const Duration(minutes: 1), () {
      if (_suggestionsCache[cacheKey]?['error'] != null) {
        _suggestionsCache.remove(cacheKey);
      }
    });

    rethrow;
  }
}
