# JomNgaji Mobile

Flutter client application for the JomNgaji platform. The app uses `go_router` for navigation, centralised theming, and `get_it` for dependency injection.

## Getting Started

```bash
cd apps/mobile
flutter pub get
flutter run
```

### Tooling

- Routing is defined in `lib/src/config/router.dart`.
- The global theme lives in `lib/src/config/theme.dart`.
- Service dependencies are registered inside `lib/src/di/service_locator.dart`.

Run linting and tests with:

```bash
flutter analyze
flutter test
```
