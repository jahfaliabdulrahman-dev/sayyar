# 🚗 Sayyar — Smart Vehicle Maintenance Tracker

A bilingual (AR/EN) mobile app that transforms vehicle maintenance from reactive guesswork into **strategic, data-driven planning**.

## Features

### Core Engine
- **3-Tier Task System** — Overdue / Upcoming / Future with smart sorting
- **Drift-Based Tracking** — Next due calculated from actual service records, not theoretical OEM schedules
- **Smart Deletion with Rollback Engine** — Deleting a record automatically recalculates all associated task states
- **Edit Engine** — Atomic update with rollback old parts + recalculate new parts
- **Fat-Finger Protection** — Odometer mismatch confirmation before saving

### Analytics
- **Cost Trend Chart** — Monthly expense visualization with `fl_chart`
- **Z-Score Outlier Detection** — Flags unusually expensive services automatically
- **Financial Forecasting** — 12-month spending projection

### UX & Localization
- **Full AR/EN Bilingual** — Every string, task name, unit, and currency localized
- **Language Toggle** — Switch between Arabic and English instantly
- **Light/Dark Mode** — Navy Teal theme, adaptive to system settings
- **Accent-Border Cards** — Premium Fintech-style history cards
- **Responsive Feedback Hub** — BottomSheet on phone, Dialog on tablet

### Data Layer
- **Local-First** — Isar database, offline-capable
- **Custom Tasks** — Create OEM tasks with dynamic baseline
- **Historical Logging** — Backdate services with date picker
- **Silent Telemetry** — Crowdsourced price data (append-only)

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.41 |
| State Management | Riverpod (Standard AsyncNotifier) |
| Database | Isar 3.1 (local-first) |
| Charts | fl_chart |
| Icons | font_awesome_flutter |
| URLs | url_launcher |

## Architecture

Clean Architecture with clear separation:
```
lib/
├── core/              # Constants, utilities (Z-Score)
├── data/              # Models, repositories, datasources
│   ├── models/        # Isar @collection entities
│   ├── repositories/  # Business logic (rollback, telemetry)
│   └── datasources/   # Isar provider
├── domain/            # Abstract repository contracts
└── presentation/      # UI, providers, pages
    ├── providers/     # Riverpod AsyncNotifiers
    └── pages/         # Dashboard, Tasks, History
```

## Building

```bash
# Get dependencies
flutter pub get

# Debug
flutter run

# Release APK
flutter build apk --release
```

**Requirements:**
- Flutter 3.41+
- Android SDK 36 + BuildTools 28.0.3
- Java 17 (Temurin recommended)

## Project Origin

Born from real frustration maintaining a **Tank 300** — factory manuals are rigid, life is not. Sayyar makes invisible technical debt visible and manageable.

---

*Built with discipline. Zero technical debt.*
