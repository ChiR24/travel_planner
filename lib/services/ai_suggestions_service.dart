import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/itinerary.dart';
import '../models/activity_category.dart';
import 'config_service.dart';
import '../config/api_config.dart';

class AISuggestionsService {
  final String _geminiApiKey;

  AISuggestionsService({required String geminiApiKey})
      : _geminiApiKey = geminiApiKey;

  Future<Map<String, dynamic>> getSuggestedActivities({
    required String location,
    required DateTime date,
    required List<ActivityCategory> preferredCategories,
    required Map<String, dynamic> preferences,
  }) async {
    final prompt = '''
You are an expert travel planner with deep knowledge of global destinations, local cultures, and travel logistics.
Generate personalized activity suggestions for a traveler visiting $location on ${date.toIso8601String()}.

Traveler Preferences:
- Preferred Categories: ${preferredCategories.map((c) => c.label).join(', ')}
${preferences.entries.map((e) => '- ${e.key}: ${e.value}').join('\n')}

Consider these factors:
1. Local Events: Special events, festivals, or seasonal activities on the specified date
2. Cultural Context: Local customs, etiquette, and cultural significance
3. Weather: Typical weather patterns and appropriate activities
4. Timing: Optimal visiting hours and duration for each activity
5. Local Specialties: Authentic experiences and hidden gems
6. Accessibility: Location and transportation considerations
7. Budget: Cost considerations and value for money
8. Crowd Levels: Peak times and quieter alternatives

Please provide suggestions in this exact JSON format:
{
  "activities": [
    {
      "name": "Activity Name",
      "description": "Detailed description including cultural context, practical tips, and why it's recommended",
      "category": "Category from the preferred list",
      "suggestedDuration": "Duration in minutes",
      "bestTimeToVisit": "Optimal time of day",
      "localTips": ["List of local insider tips"],
      "weatherConsiderations": "Weather-related advice",
      "culturalNotes": "Important cultural information",
      "tags": ["Relevant tags"]
    }
  ],
  "weatherAlert": "Weather-related warnings or recommendations",
  "culturalAlert": "Important cultural considerations for the day",
  "localEvents": ["Special events happening on this date"],
  "safetyTips": ["Safety recommendations"],
  "transportationTips": ["Transportation advice"]
}

Return ONLY valid JSON without any markdown formatting or additional text.''';

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.geminiApiBaseUrl}?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 8192,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get suggestions: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final suggestions = data['candidates'][0]['content']['parts'][0]['text'];
      return jsonDecode(suggestions);
    } catch (e) {
      return {
        'error': 'Failed to get suggestions: $e',
        'activities': [],
      };
    }
  }

  Future<Map<String, dynamic>> getLocalCustoms(String location) async {
    final prompt = '''
Provide detailed information about local customs and etiquette in $location.
Focus on practical information that travelers need to know.

Return the information in this JSON format:
{
  "greetings": {
    "formal": "How to greet formally",
    "casual": "How to greet casually",
    "gestures": ["Appropriate greeting gestures"],
    "avoidance": ["Gestures or actions to avoid"]
  },
  "dining": {
    "etiquette": ["Dining etiquette rules"],
    "customs": ["Local dining customs"],
    "tips": ["Practical dining tips"]
  },
  "dress": {
    "general": "General dress code",
    "religious": "Dress code for religious sites",
    "business": "Business dress code",
    "casual": "Casual dress expectations"
  },
  "communication": {
    "verbal": ["Verbal communication tips"],
    "nonverbal": ["Nonverbal communication notes"],
    "taboos": ["Topics or gestures to avoid"]
  },
  "religious": {
    "mainReligions": ["Main religions"],
    "customs": ["Religious customs to respect"],
    "sites": ["Etiquette for religious sites"]
  },
  "business": {
    "meetings": ["Business meeting etiquette"],
    "cards": "Business card customs",
    "timing": "Business timing expectations"
  },
  "general": {
    "respect": ["Ways to show respect"],
    "offense": ["Actions that may cause offense"],
    "tips": ["General cultural tips"]
  }
}''';

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.geminiApiBaseUrl}?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 8192,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get local customs: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final customs = data['candidates'][0]['content']['parts'][0]['text'];
      return jsonDecode(customs);
    } catch (e) {
      return {
        'error': 'Failed to get local customs: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getSafetyInfo(String location) async {
    final prompt = '''
Provide comprehensive safety information for travelers visiting $location.
Focus on current and practical safety advice.

Return the information in this JSON format:
{
  "overview": {
    "safetyLevel": "General safety level",
    "summary": "Brief safety summary",
    "emergencyNumbers": {
      "police": "Police number",
      "ambulance": "Ambulance number",
      "fire": "Fire department number"
    }
  },
  "areas": {
    "safe": ["Safe areas for tourists"],
    "caution": ["Areas to exercise caution"],
    "avoid": ["Areas to avoid"]
  },
  "transportation": {
    "public": ["Public transport safety tips"],
    "taxi": ["Taxi safety advice"],
    "walking": ["Walking safety tips"],
    "night": ["Night transportation advice"]
  },
  "scams": {
    "common": ["Common scams to watch for"],
    "prevention": ["Scam prevention tips"]
  },
  "health": {
    "water": "Water safety advice",
    "food": "Food safety tips",
    "medical": ["Medical facility information"],
    "insurance": "Insurance recommendations"
  },
  "general": {
    "daylight": ["Daytime safety tips"],
    "night": ["Nighttime safety tips"],
    "valuables": ["Valuable protection advice"]
  }
}''';

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.geminiApiBaseUrl}?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 8192,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get safety information: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final safety = data['candidates'][0]['content']['parts'][0]['text'];
      return jsonDecode(safety);
    } catch (e) {
      return {
        'error': 'Failed to get safety information: $e',
      };
    }
  }
}
