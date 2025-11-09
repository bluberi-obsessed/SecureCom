# SecureCom - AI-Powered Protection System for Smishing and Vishing

SecureCom is an AI-driven mobile application that identifies and blocks smishing (SMS phishing) and vishing (voice phishing) attacks in real-time on Android devices.

# Google Drive Link of Prototype Video
https://drive.google.com/drive/folders/15P3v2yMIQmAtSPdY8zMQgd9ZZrXyIJbc?usp=sharing

# Pitch Deck 
https://docs.google.com/presentation/d/1bh3xu4E6oUvEdnKnGBfooGfmDxkj7JyfnXS8lXLJ4N4/edit?usp=sharing


## Features

✨ **Real-time Protection**
- Intercepts SMS and call events instantly
- Flags suspicious content using AI-powered semantic analysis
- Displays sender, message, and detection reason in detail view
- Timestamped threat logs with full date and time (e.g., “Nov 9, 2025 at 2:45 PM”)

📊 **Comprehensive Dashboard**
- Color-coded threat cards:
-   🟥 Red for blocked threats
-   🟧 Orange for suspicious (unblocked)
-   🟩 Green for legitimate messages
- Weekly summary with threat counts and activity trends
- Suspicious vs Blocked stats with live updates

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



## Roadmap

- [X] Mock data implementation
- [X] SMS detection UI
- [X] Call detection UI
- [X] Settings management
- [X] Backend API integration
- [X] AI model training (BERT-tiny) --- Model is yet to be connected to the UI
- [ ] Real-time SMS interception
- [ ] Call audio transcription
- [ ] Cloud intelligence sync

## Model (Too large for GitHub)
https://drive.google.com/drive/folders/13kFkpjBmDtcxkK2XVPmjuD_Ql2vrmPYa?usp=sharing

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request


## Support

For issues and questions, email:
-   qarsantos02@tip.edu.ph
-   qhamanuel@tip.edu.ph
-   qmjkegob@tip.edu.ph


**Made with ❤️ by the SMGyupsal Team**
