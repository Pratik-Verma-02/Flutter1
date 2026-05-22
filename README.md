# PrimeXKey

Professional offline Android utility for generating JKS keystores and extracting SHA fingerprints.

## Features

- Generate JKS keystore files with real RSA key pairs
- Extract SHA-1 and SHA-256 fingerprints
- Import existing JKS/keystore files
- Manage keystore history
- Export/share keystores
- View certificate details
- Fully offline operation

## Getting Started

### Prerequisites

- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher

### Installation

1. Clone the repository
2. Run `flutter pub get`
3. Run `flutter run`

### Building

```bash
# Debug
flutter run

# Release APK
flutter build apk --release

# Release App Bundle
flutter build appbundle --release
```

## Architecture

The app uses Clean Architecture with the following structure:

- `lib/core/` - Core configuration, theme, routing, services
- `lib/features/` - Feature modules (splash, home, keystores, details, about, scanner)
- `lib/shared/` - Shared widgets and utilities

## Technologies

- Flutter
- Riverpod (State Management)
- GoRouter (Navigation)
- Hive (Local Storage)
- PointyCastle (Cryptography)
- Flutter Animate (Animations)

## License

Copyright © 2024 PrimeXKey Team. All rights reserved.
