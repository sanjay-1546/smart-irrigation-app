# Smart Farm Irrigation Platform

A Flutter application for managing a smart farm irrigation system — borewell and
open well pumps, four irrigation zones, soil moisture monitoring, weather data,
scheduling, alerts, analytics, and an automation rule engine. Single codebase
targeting Android, iOS, and Web.

## How to run

```bash
flutter pub get
flutter run            # run on a connected device/emulator or Chrome (-d chrome)
flutter analyze        # static analysis
flutter test           # widget tests
```

## Demo login credentials

The app ships with a mock data layer, so it is fully interactive without a
backend. Any password with at least 4 characters works for these usernames:

| Role        | Username     | Password      |
|-------------|--------------|---------------|
| Admin       | `admin`      | `admin123`    |
| Farmer      | `farmer`     | `farmer123`   |
| Technician  | `technician` | `tech123`     |

Navigation is role-aware: Admin sees every module, Farmer sees
monitoring/control/schedule/alerts/analytics/farm layout, and Technician sees
monitoring/alerts/settings only.

## Architecture overview

The app follows Clean Architecture with four layers under `lib/`:

- **domain/** — entities (`User`, `Farm`, `PumpStatus`, `ZoneStatus`, `Schedule`,
  `AppAlert`, `AutomationRule`, etc.) and repository interfaces, independent of
  any framework or data source.
- **data/** — `Mock*RepositoryImpl` classes implement the domain repository
  interfaces with realistic in-memory data, simulated network delay, and live
  state mutation, so the UI feels fully functional today. A real backend can be
  wired in later by adding `Api*RepositoryImpl` classes (the `ApiClient` in
  `core/services/api_client.dart` already wraps `http` with JWT header
  injection) and swapping the implementation passed into each provider in
  `main.dart` — no UI or provider code needs to change.
- **application/** — `ChangeNotifier` providers (Provider package) per
  feature (`AuthProvider`, `DashboardProvider` with a 10s auto-refresh timer,
  `IrrigationControlProvider`, `ScheduleProvider`, `AlertProvider`,
  `AnalyticsProvider`, `AutomationProvider`, `ThemeProvider`,
  `FarmLayoutProvider`, `SettingsProvider`) that orchestrate repositories and
  expose state to the UI.
- **presentation/** — screens and reusable widgets (gauges, status badges,
  section cards, confirm dialogs) built with Material 3, a green/blue
  agriculture-themed `ColorScheme`, and responsive layouts that switch between
  a bottom navigation bar (mobile) and a navigation rail (tablet/desktop) based
  on screen width.

Other notable pieces:

- `core/services/secure_storage_service.dart` — JWT token and weather API key
  storage via `flutter_secure_storage`.
- `core/services/local_cache_service.dart` — offline cache of the last
  dashboard snapshot, schedules, and farm info via `shared_preferences`;
  toggled from Settings ("Offline Mode") for demo purposes.
- `core/theme/app_theme.dart` — Material 3 light/dark themes seeded from
  green, with blue secondary accents.
