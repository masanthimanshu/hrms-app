# Employee HRMS — Mobile Attendance & Facial Verification

A modern, intuitive employee mobile application engineered in Flutter with a **clean monochrome (black-and-white / grayscale) aesthetic**. Built specifically for organizational workforce members to seamlessly log into their enterprise accounts, capture live facial selfie proof, and record geo-verified attendance against assigned facility branches.

---

## Key Features

- **Employee-First Workflow**: Designed strictly for workforce personnel with zero administrative clutter.
- **Live Camera Selfie Verification**: Real-time front-facing camera capture with face positioning reticles; gallery uploads are disabled for tamper-proof attendance integrity.
- **Geo-Tagged Check-Ins**: Detects real-time device coordinates (latitude & longitude) and matches against the employee's assigned store branch geofence.
- **Dual-Token JWT Security**: Automatic token rotation via short-lived access tokens (2-day) and refresh tokens (10-day).
- **Personal Timesheet History**: Complete audit trail of past attendance check-ins, timestamps, and verified proof status.
- **Overflow-Proof Responsive UI**: Built with flexible constraints and keyboard-safe layouts that adapt smoothly across mobile viewports.

---

## Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev/) (Material 3, iOS & Android ready)
- **State Management**: [Riverpod 3](https://riverpod.dev/) (`Notifier` & `NotifierProvider`)
- **Networking**: [Dio](https://pub.dev/packages/dio) with automated 401 refresh interceptor
- **Local Persistence**: [Hive](https://pub.dev/packages/hive_flutter) for fast local storage
- **Camera Capture**: [image_picker](https://pub.dev/packages/image_picker) restricted strictly to live camera capture
- **Typography**: [Google Fonts](https://pub.dev/packages/google_fonts) (Plus Jakarta Sans & Monospace)

---

## Directory Structure

```text
lib/
├── handler/
│   └── session_handler.dart       # Reactive auth routing (Splash -> Onboarding / Home)
├── models/
│   ├── attendance_model.dart      # Geo-punch records & proof data
│   ├── store_model.dart           # Store facility coordinates & address
│   └── user_model.dart            # Employee profile model
├── network/
│   ├── api_response.dart          # Standardized API response wrapper
│   ├── endpoints.dart             # API route definitions
│   ├── interceptor.dart           # Dual-token auto-refresh interceptor
│   └── requests.dart              # Base HTTP request mixin
├── providers/
│   ├── attendance_provider.dart   # Camera capture state & check-in actions
│   ├── auth_provider.dart         # Authentication state, login & session
│   ├── health_provider.dart       # Live server connectivity monitor
│   └── store_provider.dart        # Store branches catalog state
├── services/
│   ├── attendance_service.dart    # Haversine distance & local persistence
│   ├── auth_service.dart          # Login & token storage in Hive
│   ├── health_service.dart        # Live /health and /jwt/health checks
│   └── store_service.dart         # Store branch fetch service
├── utils/
│   ├── colors.dart                # Zinc/grayscale monochrome palette
│   ├── formatters.dart            # Timestamps, coordinates & token masking
│   ├── routes.dart                # Central named routes table
│   └── theme.dart                 # High-contrast monochrome ThemeData
├── view/
│   ├── splash/
│   │   └── splash_screen.dart     # Startup splash & session verification
│   ├── onboarding/
│   │   └── onboarding_screen.dart # Employee login portal (keyboard-safe)
│   └── home/
│       ├── home_screen.dart       # 3-tab employee shell
│       ├── tabs/
│       │   ├── attendance_tab.dart# Live digital clock, camera viewfinder & punch in
│       │   ├── history_tab.dart   # Timesheet history & audit logs
│       │   └── profile_tab.dart   # Digital employee pass & sign out
│       └── widgets/
│           ├── attendance_log_tile.dart
│           ├── home_app_bar.dart
│           └── home_navigation.dart
└── widgets/
    ├── empty_state.dart           # Empty state placeholders
    ├── monochrome_button.dart     # Tactile black/outline buttons
    ├── monochrome_card.dart       # 1px bordered cards
    ├── monochrome_text_field.dart # High-contrast input fields
    ├── section_header.dart        # Section titles with actions
    ├── stat_card.dart             # Compact KPI metric tiles
    └── status_pill.dart           # Status chips with indicator dots
```

---

## API Endpoints Integrated

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/health` | Live backend connectivity health check |
| `GET` | `/jwt/health` | Subservice JWT token health check |
| `POST` | `/account/auth/login` | Employee authentication & dual JWT issuance |
| `GET` | `/account/store/get` | Facility catalog & assigned branch resolution |
| `GET` | `/jwt/refresh` | Seamless access token renewal via refresh token |
| `GET` | `/secure/verify` | Dual-token signature verification |

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.13.0` or higher
- Dart SDK `^3.13.0` or higher

### Running the App

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run code analysis:
   ```bash
   flutter analyze
   ```

3. Run widget tests:
   ```bash
   flutter test
   ```

4. Launch the application:
   ```bash
   flutter run
   ```

---

## Demo Credentials

You can tap the **"Fill Demo Account (Alex Vance)"** shortcut on the login screen or manually enter:

- **Work Email**: `alex.vance@example.com`
- **Password**: `Password123!`
