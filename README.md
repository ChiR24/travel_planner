# Travel Planner 2.0

A comprehensive travel planning application built with Flutter and Riverpod, designed to help users plan, organize, and manage their trips efficiently.

## Latest Release - v1.0.2

### Recent Fixes and Improvements

1. **Weather API Integration**
   - Fixed Weather API integration to use HTTPS for secure API calls
   - Updated weather icon URLs to use secure connections
   - Improved weather data parsing and display

2. **Google Maps Integration**
   - Added Google Maps JavaScript API integration for the web version
   - Fixed map rendering issues across platforms
   - Enhanced location services reliability

3. **URL Launcher Dependency**
   - Updated URL launcher package to the latest version
   - Fixed compatibility issues with newer Flutter versions
   - Resolved issues with opening external links

4. **Performance Optimizations**
   - Improved app startup time
   - Reduced memory usage during weather data processing
   - Enhanced overall UI responsiveness

## Recent Improvements

### Architecture Improvements

1. **Feature-First Architecture**
   - Reorganized the codebase into a feature-first structure
   - Created separate directories for each feature with data, domain, and presentation layers
   - Improved code organization and maintainability

2. **Core Components**
   - Added centralized error handling with `AppErrorHandler`
   - Implemented adaptive layouts for better responsiveness across different screen sizes
   - Created reusable skeleton loading screens for improved UX during data loading

### UI/UX Enhancements

1. **Skeleton Loading Screens**
   - Replaced traditional loading spinners with skeleton screens
   - Provides a smoother, more engaging loading experience
   - Reduces perceived loading time

2. **Haptic Feedback**
   - Added haptic feedback for key interactions
   - Enhances the tactile experience of the app
   - Provides subtle feedback for user actions

3. **Adaptive Layouts**
   - Implemented responsive design that adapts to different screen sizes
   - Optimized layouts for mobile, tablet, and desktop
   - Improved user experience across devices

### New Features

1. **Offline Maps with MapBox**
   - Added support for offline maps
   - Users can download maps for their destinations
   - Improved functionality for users in areas with poor connectivity

2. **AI-Powered Itinerary Generation**
   - Implemented an AI service for generating trip itineraries
   - Takes user preferences, destination, and dates as input
   - Creates personalized itineraries with activities and schedules

3. **Social Sharing and Collaboration**
   - Added ability to share itineraries with travel companions
   - Implemented collaborative editing features
   - Enhanced the social aspect of trip planning

## Getting Started

### Prerequisites

- Flutter 3.0.0 or higher
- Dart 2.17.0 or higher

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/travel_planner_2.git
   ```

2. Navigate to the project directory:
   ```
   cd travel_planner_2
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Project Structure

```
lib/
├── core/                  # Core utilities and widgets
│   ├── theme/             # App theming
│   ├── utils/             # Utility functions
│   └── widgets/           # Reusable widgets
├── features/              # Feature modules
│   ├── itinerary/         # Itinerary feature
│   │   ├── data/          # Data sources and repositories
│   │   ├── domain/        # Business logic and models
│   │   └── presentation/  # UI components
│   ├── trip_management/   # Trip management feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── preferences/       # User preferences feature
│       ├── data/
│       ├── domain/
│       └── presentation/
├── models/                # Data models
├── services/              # Services
├── providers/             # Riverpod providers
├── ui/                    # UI components
├── app.dart               # App configuration
└── main.dart              # Entry point
```

## Future Improvements

- Implement unit and widget tests for improved code quality
- Add support for more languages and localization
- Integrate with more travel APIs for real-time data
- Implement advanced trip analytics and insights

## License

This project is licensed under the MIT License - see the LICENSE file for details.

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

[Coming soon]

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

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Google for Gemini API
- All contributors and supporting 