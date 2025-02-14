import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'selected_language';
  final SharedPreferences _prefs;

  LocalizationService(this._prefs);

  static final Map<String, String> supportedLanguages = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'it': 'Italiano',
    'ja': '日本語',
    'zh': '中文',
  };

  static final Map<String, Map<String, String>> translations = {
    'en': {
      'app_name': 'Travel Planner',
      'plan_trip': 'Plan Trip',
      'my_trips': 'My Trips',
      'settings': 'Settings',
      'start_planning': 'Start Planning',
      'where_to_go': 'Where would you like to go?',
      'starting_point': 'Starting Point',
      'destination': 'Destination',
      'add_destination': 'Add Destination',
      'travel_dates': 'Travel Dates',
      'start_date': 'Start Date',
      'end_date': 'End Date',
      'preferences': 'Preferences',
      'generate_itinerary': 'Generate Itinerary',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'go_back': 'Go Back',
      'offline_mode': 'Offline Mode',
      'sync_required': 'Sync Required',
    },
    'es': {
      'app_name': 'Planificador de Viajes',
      'plan_trip': 'Planificar Viaje',
      'my_trips': 'Mis Viajes',
      'settings': 'Configuración',
      'start_planning': 'Empezar a Planificar',
      'where_to_go': '¿A dónde te gustaría ir?',
      'starting_point': 'Punto de Partida',
      'destination': 'Destino',
      'add_destination': 'Añadir Destino',
      'travel_dates': 'Fechas de Viaje',
      'start_date': 'Fecha de Inicio',
      'end_date': 'Fecha de Fin',
      'preferences': 'Preferencias',
      'generate_itinerary': 'Generar Itinerario',
      'loading': 'Cargando...',
      'error': 'Error',
      'retry': 'Reintentar',
      'go_back': 'Volver',
      'offline_mode': 'Modo Sin Conexión',
      'sync_required': 'Sincronización Necesaria',
    },
    // Add more languages as needed
  };

  String get currentLanguage => _prefs.getString(_languageKey) ?? 'en';

  Future<void> setLanguage(String languageCode) async {
    if (!supportedLanguages.containsKey(languageCode)) {
      throw Exception('Language not supported: $languageCode');
    }
    await _prefs.setString(_languageKey, languageCode);
  }

  String translate(String key) {
    final lang = currentLanguage;
    final langMap = translations[lang];
    if (langMap == null) return translations['en']?[key] ?? key;
    return langMap[key] ?? translations['en']?[key] ?? key;
  }

  Locale get locale => Locale(currentLanguage);

  static List<Locale> get supportedLocales =>
      supportedLanguages.keys.map((code) => Locale(code)).toList();
}

// Provider
final localizationServiceProvider = Provider<LocalizationService>((ref) {
  throw UnimplementedError('Initialize with SharedPreferences instance');
});

// Extension for easy access in widgets
extension LocalizationExtension on BuildContext {
  String tr(String key) {
    final service =
        ProviderScope.containerOf(this).read(localizationServiceProvider);
    return service.translate(key);
  }
}

// Mixin for StatefulWidget to handle language changes
mixin LocalizationStateMixin<T extends StatefulWidget> on State<T> {
  late String _currentLanguage;
  late VoidCallback _languageChangeCallback;

  @override
  void initState() {
    super.initState();
    final service = context.read(localizationServiceProvider);
    _currentLanguage = service.currentLanguage;
    _languageChangeCallback = () {
      if (_currentLanguage != service.currentLanguage) {
        setState(() {
          _currentLanguage = service.currentLanguage;
        });
      }
    };
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Widget to display language selector
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(localizationServiceProvider);
    final currentLanguage = service.currentLanguage;

    return PopupMenuButton<String>(
      onSelected: (String languageCode) async {
        await service.setLanguage(languageCode);
        if (context.mounted) {
          // Trigger app rebuild
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed('/');
        }
      },
      itemBuilder: (BuildContext context) {
        return LocalizationService.supportedLanguages.entries.map((entry) {
          return PopupMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                if (entry.key == currentLanguage)
                  const Icon(Icons.check, size: 18)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 8),
                Text(entry.value),
              ],
            ),
          );
        }).toList();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language),
            const SizedBox(width: 4),
            Text(LocalizationService.supportedLanguages[currentLanguage]!),
          ],
        ),
      ),
    );
  }
}
