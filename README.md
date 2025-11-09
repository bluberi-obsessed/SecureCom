# SecureCom - AI-Powered Anti-Scam Protection

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

## Roadmap

- [ ] Mock data implementation
- [ ] SMS detection UI
- [ ] Call detection UI
- [ ] Settings management
- [ ] Backend API integration
- [ ] AI model training (BERT-tiny)
- [ ] Real-time SMS interception
- [ ] Call audio transcription (Google Speech-to-Text)
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
