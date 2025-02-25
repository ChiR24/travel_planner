import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/weather_data.dart';
import '../providers/weather_provider.dart';

class WeatherCard extends ConsumerWidget {
  final String location;
  final bool showForecast;
  final bool compact;

  const WeatherCard({
    Key? key,
    required this.location,
    this.showForecast = false,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get current weather
    final weatherAsync = ref.watch(currentWeatherProvider(location));

    // Get forecast if needed
    final forecastAsync = showForecast
        ? ref.watch(
            forecastProvider(ForecastParams(location: location, days: 3)))
        : const AsyncValue<List<WeatherData>>.loading();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: weatherAsync.when(
          data: (weatherData) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context, weatherData),
                  const SizedBox(height: 16),
                  _buildCurrentWeather(context, weatherData),
                  if (showForecast) ...[
                    const Divider(height: 32),
                    _buildForecast(context, forecastAsync),
                  ],
                ],
              ),
            );
          },
          loading: () => _buildLoadingState(context),
          error: (error, stackTrace) => _buildErrorState(context, error),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WeatherData weatherData) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weatherData.location,
                style: TextStyle(
                  fontSize: compact ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                weatherData.country,
                style: TextStyle(
                  fontSize: compact ? 12 : 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Last updated',
              style: TextStyle(
                fontSize: compact ? 10 : 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              DateFormat('h:mm a').format(weatherData.lastUpdated),
              style: TextStyle(
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentWeather(BuildContext context, WeatherData weatherData) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weatherData.tempC.round()}',
                    style: TextStyle(
                      fontSize: compact ? 36 : 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '°C',
                    style: TextStyle(
                      fontSize: compact ? 18 : 24,
                      fontWeight: FontWeight.w300,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              Text(
                weatherData.condition,
                style: TextStyle(
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.thermostat_outlined,
                    size: compact ? 14 : 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Feels like ${weatherData.feelsLikeC.round()}°C',
                    style: TextStyle(
                      fontSize: compact ? 12 : 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              if (weatherData.conditionIcon.isNotEmpty)
                _buildWeatherIcon(weatherData.conditionIcon),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.water_drop_outlined,
                    size: compact ? 14 : 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${weatherData.humidity.round()}%',
                    style: TextStyle(
                      fontSize: compact ? 12 : 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.air,
                    size: compact ? 14 : 16,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${weatherData.windKph.round()} km/h',
                    style: TextStyle(
                      fontSize: compact ? 12 : 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherIcon(String iconUrl) {
    // Make sure the URL uses HTTPS
    final secureUrl = iconUrl.startsWith('http:')
        ? iconUrl.replaceFirst('http:', 'https:')
        : iconUrl;

    // For web platform, handle image loading differently
    if (kIsWeb) {
      return Image.network(
        secureUrl,
        width: 64,
        height: 64,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading weather icon: $error');
          return const Icon(
            Icons.cloud,
            size: 64,
            color: Colors.grey,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            width: 64,
            height: 64,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    }

    return Image.network(
      secureUrl,
      width: 64,
      height: 64,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.cloud,
          size: 64,
          color: Colors.grey,
        );
      },
    );
  }

  Widget _buildForecast(
      BuildContext context, AsyncValue<List<WeatherData>> forecastAsync) {
    return forecastAsync.when(
      data: (forecastList) {
        if (forecastList.isEmpty) {
          return const Center(
            child: Text('No forecast data available'),
          );
        }

        // Skip the first item if it's today and we have multiple days
        final displayList = forecastList.length > 1
            ? forecastList.skip(1).toList()
            : forecastList;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Forecast',
              style: TextStyle(
                fontSize: compact ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: compact ? 80 : 100,
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final forecast = displayList[index];
                  // Debug print to see what's being rendered
                  print(
                      'Rendering forecast for day: ${forecast.lastUpdated}, temp: ${forecast.tempC}°C');

                  return Container(
                    width: compact ? 70 : 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getDayName(forecast.lastUpdated),
                          style: TextStyle(
                            fontSize: compact ? 10 : 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        if (forecast.conditionIcon.isNotEmpty)
                          SizedBox(
                            height: compact ? 24 : 28,
                            width: compact ? 24 : 28,
                            child:
                                _buildSmallWeatherIcon(forecast.conditionIcon),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          '${forecast.tempC.round()}°C',
                          style: TextStyle(
                            fontSize: compact ? 10 : 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Text(
          'Error loading forecast: ${error.toString()}',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildSmallWeatherIcon(String iconUrl) {
    // Make sure the URL uses HTTPS
    final secureUrl = iconUrl.startsWith('http:')
        ? iconUrl.replaceFirst('http:', 'https:')
        : iconUrl;

    // For web platform, handle image loading differently
    if (kIsWeb) {
      return Image.network(
        secureUrl,
        width: 32,
        height: 32,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading forecast icon: $error');
          return const Icon(
            Icons.cloud,
            size: 32,
            color: Colors.grey,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            width: 32,
            height: 32,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 1,
              ),
            ),
          );
        },
      );
    }

    return Image.network(
      secureUrl,
      width: 32,
      height: 32,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.cloud,
          size: 32,
          color: Colors.grey,
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return SizedBox(
      height: compact ? 120 : 150,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return SizedBox(
      height: compact ? 120 : 150,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Error loading weather data',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            if (!compact) ...[
              const SizedBox(height: 4),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getDayName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    } else {
      return DateFormat('E').format(date); // Day name (e.g., Mon, Tue)
    }
  }
}
