# Travel Planner

A comprehensive travel planning application built with Flutter and Riverpod, designed to help users plan, organize, and manage their trips efficiently.

## ✨ Features

### 🎯 Core Features
- **AI-Powered Itinerary Generation**
  - Smart travel suggestions using Google Gemini API
  - Personalized activity recommendations
  - Weather-aware planning

- **Weather Integration**
  - Real-time weather data and forecasts
  - Multi-location weather tracking
  - Weather-aware planning suggestions

- **Maps & Location**
  - Google Maps integration
  - Interactive map views
  - Location picker

- **Trip Management**
  - Create, edit, and manage multiple trips
  - Multi-destination support
  - Budget tracking

### 🛠 Technical Features
- **Modern Architecture**
  - Flutter Riverpod for state management
  - Feature-first directory structure
  - Clean separation of concerns

- **UI/UX**
  - Material Design 3
  - Dark/Light theme support
  - Responsive design
  - Smooth animations

- **Data Management**
  - Offline support with Hive
  - Secure data storage
  - Automatic synchronization

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.19.0 or higher
- Dart SDK 3.6.2 or higher
- Git

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/yourusername/travel_planner.git
cd travel_planner
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Create environment file:**
```bash
# Create .env file with your API keys
GEMINI_API_KEY=your_gemini_api_key
GOOGLE_MAPS_API_KEY=your_google_maps_key
WEATHER_API_KEY=your_weather_api_key
USE_MOCK_DATA=true  # Set to false for real API calls
```

4. **Run the app:**
```bash
# Web browser
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

## 📁 Project Structure

```
lib/
├── config/                 # Configuration files
│   └── api_config.dart     # API configuration
├── models/                 # Data models
├── services/               # Business logic
│   ├── ai_suggestions_service.dart
│   ├── weather_service.dart
│   ├── maps_service.dart
│   └── [other services]
├── providers/              # State management (Riverpod)
├── ui/                     # User interface
│   ├── screens/           # App screens
│   └── widgets/           # Reusable components
├── theme/                  # App theming
└── main.dart              # Entry point
```

## 🔑 API Configuration

### Required API Keys

Create a `.env` file in the project root:

```env
# Google Gemini API for AI suggestions
GEMINI_API_KEY=your_gemini_api_key

# Google Maps API for location services
GOOGLE_MAPS_API_KEY=your_google_maps_api_key

# Weather API for weather data
WEATHER_API_KEY=your_weather_api_key

# Use mock data for development
USE_MOCK_DATA=true
```

**Get API Keys:**
- [Gemini API](https://makersuite.google.com/app/apikey)
- [Google Maps API](https://console.cloud.google.com/apis/credentials)
- [Weather API](https://www.weatherapi.com/)

## 🏗 Architecture

### State Management
- **Flutter Riverpod** - Modern, type-safe state management
- **Provider pattern** - Dependency injection
- **StateNotifier** - Complex state management

### Services
- **AISuggestionsService** - AI-powered trip suggestions
- **WeatherService** - Weather data and forecasts
- **MapsService** - Google Maps integration
- **TripManagementService** - Trip CRUD operations

### Data Storage
- **Hive** - Local NoSQL database for offline storage
- **SharedPreferences** - Simple key-value storage
- **SecureStorage** - Encrypted API key storage

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/services/weather_service_test.dart
```

## 📦 Build

### Web
```bash
flutter build web --release
```

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🛣 Roadmap

- [ ] Unit and widget tests
- [ ] Multi-language support (i18n)
- [ ] Offline maps
- [ ] Social sharing
- [ ] AR navigation
- [ ] Travel cost estimation
- [ ] Local events integration

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - UI framework
- [Riverpod](https://riverpod.dev/) - State management
- [Google Gemini API](https://ai.google.dev/) - AI capabilities
- [Google Maps](https://developers.google.com/maps) - Mapping services

---

![Flutter](https://img.shields.io/badge/Flutter-3.19.0-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.6.2-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
