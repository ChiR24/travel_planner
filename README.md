# Travel Planner Pro

A modern, feature-rich travel planning application built with Flutter that helps users create personalized travel itineraries with AI-powered suggestions and comprehensive trip management features.

![Flutter Version](https://img.shields.io/badge/flutter-3.19.0-blue.svg)
![Dart Version](https://img.shields.io/badge/dart-3.6.2-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## 🌟 Features

### 🎯 Core Features
- **AI-Powered Itinerary Generation**
  - Smart travel suggestions based on preferences
  - Dynamic route optimization
  - Personalized activity recommendations
  - Weather-aware planning

- **Custom Preferences System**
  - 12+ preference categories
  - Customizable values
  - Smart suggestions
  - Category-based filtering
  - Real-time search functionality

- **Interactive Trip Planning**
  - Multi-destination support
  - Drag-and-drop itinerary builder
  - Dynamic route visualization
  - Real-time travel time estimates

### 🛠 Technical Features
- **Modern UI/UX**
  - Material Design 3
  - Smooth animations
  - Responsive layout
  - Dark/Light theme support
  - Custom icons and colors

- **Performance**
  - Efficient state management with Riverpod
  - Optimized list rendering
  - Smart caching system
  - Background processing

- **Data Management**
  - Offline support
  - Secure data storage
  - Cloud synchronization
  - Automatic backups

### 🔒 Security & Privacy
- Secure API key management
- Data encryption
- Privacy-focused design
- GDPR compliance

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.19.0 or higher)
- Dart SDK (3.6.2 or higher)
- Android Studio / VS Code
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/travel_planner_2.git
cd travel_planner_2
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure environment variables:
```bash
cp .env.example .env
```
Edit `.env` with your API keys:
```
GEMINI_API_KEY=your_api_key_here
GOOGLE_MAPS_API_KEY=your_api_key_here
WEATHER_API_KEY=your_api_key_here
```

4. Run the app:
```bash
flutter run
```

## 🏗 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── providers/               # State management
├── services/               # Business logic
├── ui/                    # User interface
│   ├── screens/          # App screens
│   ├── widgets/          # Reusable widgets
│   └── theme/           # App theming
└── utils/              # Helper functions
```

## 🎨 Features in Detail

### Custom Preferences System
The app includes a sophisticated preferences system with categories like:
- Food Type (Vegetarian, Vegan, etc.)
- Activity Level (Low to Extreme)
- Transportation Options
- Accommodation Preferences
- Budget Ranges
- Language Requirements
- Travel Pace
- Special Requirements
- Time Preferences
- Weather Preferences
- Cultural Interests
- Social Style

Each category includes:
- Custom icons
- Color coding
- Smart suggestions
- Search functionality
- Category filtering
- Real-time updates

### AI Integration
- Uses Google's Gemini API for smart suggestions
- Context-aware recommendations
- Natural language processing
- Learning from user preferences

## 🔧 Configuration

### Environment Variables
```dart
const String GEMINI_API_KEY = 'your_api_key';
const String GOOGLE_MAPS_API_KEY = 'your_api_key';
const String WEATHER_API_KEY = 'your_api_key';
```

### Theme Customization
```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: _primaryColor,
    secondary: _secondaryColor,
    // ... other colors
  ),
)
```

## 📱 Screenshots

[Add screenshots here]

## 🛣 Roadmap

- [ ] Multi-language support
- [ ] Offline maps
- [ ] AR navigation
- [ ] Social sharing
- [ ] Trip cost estimation
- [ ] Weather forecasting
- [ ] Local events integration
- [ ] Travel documentation management

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Google for Gemini API
- All contributors and supporters

## 📞 Support

For support, email support@travelplanner.com or join our Slack channel.
