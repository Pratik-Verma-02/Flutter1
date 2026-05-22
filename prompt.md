# PrimeXKey — Flutter Project Requirements

## App Information
- **App Name:** PrimeXKey
- **Package Name:** com.primexkey.app
- **Version:** 1.0.0+1
- **Description:** Professional offline Android utility for generating JKS keystores, extracting SHA fingerprints, and managing certificates.
- **Developer:** PrimeXKey Development Team
- **Min SDK:** 21 (Android 5.0)
- **Target SDK:** 34 (Android 14)

## Features
1. Generate JKS keystore files with real RSA key pairs
2. Extract SHA-1 and SHA-256 fingerprints
3. Import existing JKS/keystore files
4. Manage keystore history with Hive
5. Export/share keystores
6. View certificate details
7. Fully offline operation
8. Premium dark-themed UI

## UI Requirements
- Dark theme with blue/purple glow accents
- Glassmorphism-inspired cards
- Premium typography (Google Fonts)
- Rounded corners, elegant shadows
- Smooth animations (flutter_animate)
- Responsive layout
- Play Store quality

## Screens
1. **Splash Screen** — Animated logo, fade/scale, dark bg
2. **Home Screen** — Generate Keystore form with all fields, RSA dropdown, validity slider
3. **Keystores Screen** — List saved keystores with search/sort, CRUD actions
4. **Keystore Details Screen** — Full fingerprint display, cert details, copy/share/export/delete
5. **About Screen** — App info, developer section, features list
6. **Scanner/Import** — File picker, password prompt, extract fingerprints

## Architecture
- Clean Architecture (core/, config/, services/, shared/, features/)
- Riverpod for state management
- GoRouter for navigation
- Repository pattern
- Dependency injection

## Storage
- **Hive** — Metadata/history (file name, date, fingerprints, path)
- **flutter_secure_storage** — Sensitive data (temporary passwords only)
- NEVER store passwords in plain text permanently

## Security
- All crypto operations on-device
- Sanitize inputs
- Secure temporary files
- Clear sensitive memory
- No hardcoded secrets

## Packages
- flutter_riverpod, go_router, hive, hive_flutter
- flutter_secure_storage, file_picker, permission_handler
- path_provider, share_plus, pointycastle, crypto
- flutter_animate, google_fonts, flutter_native_splash, flutter_launcher_icons

## Assets
- App logo at assets/images/
- Use provided logo for launcher icons, splash, about screen

## Development Workflow
1. Create project structure
2. Configure pubspec.yaml
3. Build theme system
4. Build navigation (GoRouter + BottomNav)
5. Build Splash Screen
6. Build Home Screen with form
7. Implement JKS generation with PointyCastle
8. Implement SHA fingerprint extraction
9. Build Keystores Screen with Hive
10. Build Details Screen
11. Build About Screen
12. Implement file import/scanner
13. Implement export/share
14. Add animations
15. Configure Android (Gradle, manifest, permissions)
16. Configure iOS
17. Validate & test

## Task Status
- [x] Project Requirements Documented
- [ ] Flutter Project Structure
- [ ] pubspec.yaml Configuration
- [ ] Theme System
- [ ] Navigation System
- [ ] Splash Screen
- [ ] Home Screen
- [ ] JKS Generation Engine
- [ ] SHA Extraction
- [ ] Keystores Screen
- [ ] Details Screen
- [ ] About Screen
- [ ] Scanner/Import
- [ ] Hive Storage Service
- [ ] Export/Share System
- [ ] Animations
- [ ] Android Configuration
- [ ] iOS Configuration
- [ ] Final Validation
