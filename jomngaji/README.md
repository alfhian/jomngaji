# JomNgaji Flutter App

## Development quick start

```bash
flutter pub get
flutter run
```

## Build artifacts

- APK (testing): `flutter build apk --release`
- AAB (Google Play): `flutter build appbundle --release`
- IPA (App Store, macOS): `flutter build ipa --release`

Contoh build APK untuk testing langsung ke VPS via IP publik (tanpa HTTPS):

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=http://187.127.103.60:4000 \
  --dart-define=ALLOW_HTTP_IN_PROD=true
```

Panduan lengkap release Android + iOS:

- `docs/mobile_release_guide.md`
