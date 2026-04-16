# CarSah — Vehicle Maintenance Tracker

**TestSprite Hackathon Season 2 Submission**

## What We Built

CarSah is a bilingual (Arabic/English) vehicle maintenance tracking app built with Flutter. It helps car owners track maintenance schedules, predict costs, and never miss a service.

### Key Features
- **Vehicle Management** — Add, edit, and track multiple vehicles
- **Maintenance Scheduling** — Service tasks with mileage/time intervals
- **Cost Prediction** — Z-Score based cost trend analysis
- **Bilingual** — Full Arabic (RTL) and English support, zero hardcoded strings
- **Offline-First** — Local Isar database, no cloud dependency
- **Clean Architecture** — Domain/Data/Presentation separation with Riverpod

### Tech Stack
- **Flutter** (Dart)
- **Isar** — Local NoSQL database
- **Riverpod** — State management
- **fl_chart** — Cost trend visualizations
- **Google Fonts** — Typography

### Architecture
```
lib/
├── core/          — Constants, utilities (cost predictor, Z-score)
├── data/          — Isar models, repositories, data sources
├── domain/        — Abstract repository interfaces
├── presentation/  — Pages, providers, widgets
└── main.dart      — App entry point
```

## How We Used TestSprite

1. **Round 1**: TestSprite MCP auto-generated test cases covering core functionality
   - Result: 20/28 passed (71.4%)
2. **Round 2**: Fixed 8 bugs, re-ran tests to verify improvements
   - Result: 29/32 passed (90.6%)
3. **Round 2.5**: Fixed edge case in Z-Score outlier detection (boundary + zero-variance)
   - Result: 30/32 passed (93.8%)
4. **Remaining**: 2 failures are Isar DB initialization in headless test environment (not code bugs)

```
Round 1:   20/28  (71.4%)  ████████████░░░░░░░░
Round 2:   29/32  (90.6%)  ██████████████████░░
Round 2.5: 30/32  (93.8%)  ███████████████████░
```

See `testsprite_tests/` for all generated test cases and reports.

## Links
- **GitHub:** https://github.com/jahfaliabdulrahman-dev/carsah
- **Discord:** TestSprite Hackathon Season 2
