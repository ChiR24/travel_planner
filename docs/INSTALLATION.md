# Travel Planner Installation Guide

This guide provides detailed instructions for installing and running the Travel Planner application on different platforms.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Android Installation](#android-installation)
- [iOS Installation](#ios-installation)
- [Web Installation](#web-installation)
- [Development Environment](#development-environment)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before installing Travel Planner, ensure you have the following:

- **For All Platforms**:
  - Internet connection for initial setup and app updates
  - Account credentials (if using cloud sync features)

- **For Mobile Devices**:
  - Sufficient storage space (at least 100MB)
  - Android 6.0+ or iOS 12.0+
  - Google Play Services (Android) or App Store (iOS)

- **For Development**:
  - Flutter SDK 3.19.0 or higher
  - Dart SDK 3.2.0 or higher
  - Android Studio / Xcode / VS Code
  - Git

## Android Installation

### From Google Play Store
1. Open the Google Play Store on your Android device
2. Search for "Travel Planner"
3. Tap on the Travel Planner app by ChiR24
4. Tap "Install"
5. Wait for the download and installation to complete
6. Open the app and sign in or create an account

### Direct APK Installation
1. Download the latest APK from [GitHub Releases](https://github.com/ChiR24/travel_planner/releases)
2. On your Android device, go to Settings > Security
3. Enable "Unknown Sources" to allow installation of apps from sources other than the Play Store
4. Open the downloaded APK file using your file manager
5. Follow the on-screen instructions to install
6. Open the app and sign in or create an account

### Build from Source (Advanced)
1. Clone the repository: `git clone https://github.com/ChiR24/travel_planner.git`
2. Navigate to the project directory: `cd travel_planner`
3. Install dependencies: `flutter pub get`
4. Connect your Android device or start an emulator
5. Build and install: `flutter run --release`

## iOS Installation

### From App Store
1. Open the App Store on your iOS device
2. Search for "Travel Planner"
3. Tap on the Travel Planner app by ChiR24
4. Tap "Get" or the download icon
5. Authenticate with Face ID, Touch ID, or Apple ID password
6. Wait for the download and installation to complete
7. Open the app and sign in or create an account

### TestFlight (Beta)
1. Install TestFlight from the App Store
2. Accept the invitation link sent to your email
3. Open TestFlight and download the Travel Planner beta
4. Follow the on-screen instructions to install
5. Open the app and sign in or create an account

### Build from Source (Advanced)
1. Clone the repository: `git clone https://github.com/ChiR24/travel_planner.git`
2. Navigate to the project directory: `cd travel_planner`
3. Install dependencies: `flutter pub get`
4. Connect your iOS device or start a simulator
5. Build and install: `flutter run --release`

## Web Installation

### Using Hosted Version
1. Visit [travel-planner.example.com](https://travel-planner.example.com) in your browser
2. Sign in or create an account
3. Optionally, add the site to your home screen for easier access:
   - **Chrome**: Click the menu (⋮) > "Install Travel Planner"
   - **Safari**: Share button > "Add to Home Screen"
   - **Firefox**: Menu > "Install app"

### Deploy Your Own Instance
1. Clone the repository: `git clone https://github.com/ChiR24/travel_planner.git`
2. Navigate to the project directory: `cd travel_planner`
3. Install dependencies: `flutter pub get`
4. Build for web: `flutter build web --release`
5. Deploy the contents of the `build/web` directory to your web server
6. Configure your web server to redirect all requests to `index.html`

## Development Environment

### Setting Up for Development
1. Install Flutter by following the [official guide](https://flutter.dev/docs/get-started/install)
2. Clone the repository: `git clone https://github.com/ChiR24/travel_planner.git`
3. Navigate to the project directory: `cd travel_planner`
4. Install dependencies: `flutter pub get`
5. Create a `.env` file with the required API keys (see `.env.example`)
6. Run the development version: `flutter run`

### API Keys Setup
The application requires several API keys to function properly:

1. **Weather API Key**:
   - Sign up at [WeatherAPI](https://www.weatherapi.com/)
   - Get your API key from the dashboard
   - Add to your `.env` file as `WEATHER_API_KEY=your_key_here`

2. **Google Maps API Key**:
   - Create a project in [Google Cloud Console](https://console.cloud.google.com/)
   - Enable the Maps JavaScript API, Maps SDK for Android, and Maps SDK for iOS
   - Create API keys for each platform with appropriate restrictions
   - Add to your `.env` file as `GOOGLE_MAPS_API_KEY=your_key_here`

3. **Mapbox API Key** (for offline maps):
   - Create an account at [Mapbox](https://www.mapbox.com/)
   - Get your access token from the dashboard
   - Add to your `.env` file as `MAPBOX_API_KEY=your_key_here`

## Troubleshooting

### Common Issues

#### App Crashes on Startup
- Ensure you have the latest version
- Check if your device meets the minimum requirements
- Try clearing the app cache and data
- Reinstall the application

#### Can't Connect to Weather Services
- Check your internet connection
- Verify that you've added valid API keys
- Look for any firewalls or network restrictions

#### Maps Not Loading
- Ensure Google Play Services is updated (Android)
- Check if location permissions are granted
- Verify that you've added valid API keys
- Try switching between online and offline maps

#### Installation Errors
- For "App not installed" errors, check device storage
- For developer builds, ensure Flutter and Dart are up to date
- For iOS builds, verify that your device is registered in the developer account

### Getting Help

If you encounter issues not covered in this guide:

1. Check the [GitHub Issues](https://github.com/ChiR24/travel_planner/issues) for similar problems
2. Search the [Wiki](https://github.com/ChiR24/travel_planner/wiki) for answers
3. Create a new issue with detailed information about your problem
4. Contact support at support@example.com 