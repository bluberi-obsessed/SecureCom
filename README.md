# SecureCom - AI-Powered Anti-Scam Protection

SecureCom is an AI-driven mobile application that identifies and blocks smishing (SMS phishing) and vishing (voice phishing) attacks in real-time on Android devices.

## Features

✨ **Real-time Protection**
- SMS message scanning and threat detection
- Call monitoring and vishing identification
- AI-powered semantic analysis

📊 **Comprehensive Dashboard**
- Threat level indicators
- Weekly activity charts
- Detailed detection history

⚙️ **Customizable Settings**
- Adjustable sensitivity levels
- Whitelist management
- Privacy controls

🔒 **Privacy-Focused**
- Local processing
- Anonymized cloud learning
- User data control

## Screenshots

*Coming soon*

## Prerequisites

- Windows 10/11 (with WSL2) or Linux
- Flutter SDK 3.16+
- Android Studio with Android SDK
- Android Emulator or Physical Device (API 26+)

## Installation

### 1. Clone/Download Project
```powershell
# Windows
cd C:\Projects
# Extract securecom.zip or clone repository
cd securecom
```

### 2. Install Dependencies
```powershell
flutter pub get
```

### 3. Generate Code
```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Run Application

**Option A: Using Android Studio**
1. Open project in Android Studio
2. Select emulator or connected device
3. Click Run button (or press Shift+F10)

**Option B: Command Line**
```powershell
# Start emulator (if not running)
emulator -avd Pixel_6_Pro_API_34

# In new terminal
flutter run
```

**Option C: VS Code**
1. Open project folder
2. Press F5 or click Run > Start Debugging

## Project Structure
```
securecom/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── core/                        # Core utilities
│   │   ├── constants/               # App-wide constants
│   │   ├── theme/                   # Theme configuration
│   │   ├── utils/                   # Helper functions
│   │   └── widgets/                 # Reusable widgets
│   ├── data/                        # Data layer
│   │   ├── models/                  # Freezed data models
│   │   ├── repositories/            # Repository interfaces
│   │   └── data_sources/            # Mock & API services
│   ├── domain/                      # Business logic
│   │   └── entities/                # Domain entities
│   ├── presentation/                # UI layer
│   │   ├── providers/               # Riverpod providers
│   │   ├── screens/                 # App screens
│   │   └── widgets/                 # Screen-specific widgets
│   └── services/                    # Platform services
├── android/                         # Android configuration
├── assets/                          # Images, animations
└── test/                            # Unit tests
```

## Architecture

SecureCom follows **Clean Architecture** principles:

- **Presentation Layer**: Flutter UI with Riverpod state management
- **Domain Layer**: Business logic and entities
- **Data Layer**: Repositories, data sources (Mock & API)

### Key Technologies

- **Flutter**: Cross-platform UI framework
- **Riverpod**: State management
- **Freezed**: Immutable data models
- **Dio**: HTTP client (ready for backend)
- **fl_chart**: Data visualization
- **Hive**: Local database

## Mock Data

The app currently uses **realistic mock data** with:
- 20+ SMS scam examples (Filipino context)
- 10+ call scam examples
- Confirmed scams, suspicious, and legitimate messages
- Real-world scam patterns (bank phishing, delivery scams, etc.)

## Backend Integration (Coming Soon)

To switch from mock data to real backend:

1. **Update Repository Provider** in `lib/presentation/providers/detection_provider.dart`:
```dart
final detectionRepositoryProvider = Provider<DetectionRepository>((ref) {
  // Change this line:
  // return MockDetectionRepository(); // Current
  return ApiDetectionRepository(ApiClient()); // Production
});
```

2. **Configure API Client** in `lib/data/data_sources/remote/api_client.dart`:
   - Update `baseUrl` to your backend URL
   - Add authentication tokens

## Troubleshooting

### Build Errors
```powershell
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Emulator Not Detected
```powershell
# Check devices
flutter devices
adb devices

# Restart ADB
adb kill-server
adb start-server
```

### WSL Issues
```bash
# In WSL terminal
export ADB_SERVER_SOCKET=tcp:127.0.0.1:5037
flutter devices
```

### Missing Generated Files
```powershell
# Ensure build_runner completes successfully
flutter pub run build_runner build --delete-conflicting-outputs --verbose
```

## Development

### Adding New Features

1. Create data models in `lib/data/models/`
2. Add mock data in `lib/data/data_sources/mock/`
3. Create providers in `lib/presentation/providers/`
4. Build UI in `lib/presentation/screens/`

### Running Tests
```powershell
flutter test
```

### Code Generation
```powershell
# Watch mode (auto-regenerate on save)
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Roadmap

- [x] Mock data implementation
- [x] SMS detection UI
- [x] Call detection UI
- [x] Settings management
- [ ] Backend API integration
- [ ] AI model training (Huawei ModelArts)
- [ ] Real-time SMS interception
- [ ] Call audio transcription (Huawei SIS)
- [ ] Cloud intelligence sync
- [ ] User authentication

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## License

This project is licensed under the MIT License - see LICENSE file for details.

## Support

For issues and questions:
- Email: support@securecom.app
- GitHub Issues: [Create Issue](https://github.com/yourrepo/securecom/issues)

## Acknowledgments

- Flutter Team for the amazing framework
- Riverpod for elegant state management
- All contributors and testers

---

**Made with ❤️ by the SecureCom Team**