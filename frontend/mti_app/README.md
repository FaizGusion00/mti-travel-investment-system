# MTI Travel Investment App

Meta Travel International (MTI) - A modern mobile application for managing travel investments, referrals, and earnings.

![MTI Logo](assets/images/mti_logo.png)

## Overview

The MTI Travel Investment app is a Flutter-based mobile application designed to provide users with a modern, responsive, and visually appealing interface for managing their travel investments, tracking referrals, and monitoring earnings. The app features a dark theme with cosmic design elements and smooth animations throughout the user experience.

## Features

- **User Authentication**
  - Login with email and password
  - Registration with profile picture and age verification (18+)
  - Email verification with OTP
  - Forgot password functionality

- **Dashboard**
  - Portfolio performance visualization
  - Quick actions for common tasks
  - Latest transactions overview

- **Profile Management**
  - Editable user information
  - Profile picture upload
  - USDT wallet address management
  - Reference code sharing

- **Network Marketing**
  - Team overview with visualization
  - Earnings from referrals
  - Performance metrics

## Tech Stack

- **Framework**: Flutter
- **State Management**: Provider and GetX
- **Navigation**: GetX
- **Animations**: flutter_animate
- **Charts**: fl_chart
- **Network**: dio
- **Storage**: shared_preferences
- **Image Handling**: image_picker, cached_network_image

## Project Structure

The project follows a clean architecture with feature-based organization:

```
lib/
├── config/            # App configuration (routes, theme)
├── core/              # Core functionality (constants, utils)
├── features/          # Feature modules
│   ├── auth/          # Authentication features
│   ├── home/          # Home screen features
│   ├── network/       # Network marketing features
│   ├── profile/       # User profile features
│   └── splash/        # Splash screen
├── screens/           # Screen implementations
├── shared/            # Shared components
├── widgets/           # Reusable widgets
└── main.dart          # Entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (version 3.7.0 or higher)
- Dart SDK (version 3.0.0 or higher)
- Android Studio / VS Code
- Android SDK / Xcode (for iOS development)

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/your-organization/mti-travel-investment.git
   ```

2. Navigate to the project directory:
   ```
   cd mti-travel-investment/frontend/mti_app
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Build and Deployment

### Android

```
flutter build apk --release
```

The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```
flutter build ios --release
```

## License

This project is proprietary and confidential. Unauthorized copying, distribution, or use is strictly prohibited.

## Contact

Meta Travel International - [https://mti.travel](https://mti.travel)
