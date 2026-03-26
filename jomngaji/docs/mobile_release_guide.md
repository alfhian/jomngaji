# Mobile Release Guide (APK, Google Play, App Store)

Panduan ini menyiapkan proyek Flutter JomNgaji untuk:
- build `.apk` testing internal,
- build `.aab` upload Google Play,
- build iOS archive untuk App Store Connect.

## 1) Prasyarat umum

1. Flutter SDK terpasang (`flutter --version`).
2. Android Studio + Android SDK + Java 11+.
3. Xcode terbaru (untuk build iOS, hanya di macOS).
4. Akun:
   - Google Play Console.
   - Apple Developer Program.

## 2) Build APK untuk testing (Android)

```bash
flutter clean
flutter pub get
flutter build apk --release
```

Output:
- `build/app/outputs/flutter-apk/app-release.apk`

Untuk testing internal cepat (tanpa optimasi release), bisa gunakan:

```bash
flutter build apk --debug
```

## 3) Persiapan signing Android (wajib untuk Play Store)

### 3.1 Buat keystore upload

```bash
keytool -genkey -v \
  -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

### 3.2 Simpan keystore & key.properties

1. Pindahkan `upload-keystore.jks` ke folder `jomngaji/android/`.
2. Copy template:

```bash
cp android/key.properties.example android/key.properties
```

3. Isi nilai asli di `android/key.properties`.

> `android/key.properties` dan file `.jks/.keystore` sudah di-ignore git.

## 4) Build Android App Bundle (.aab) untuk Google Play

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

Output:
- `build/app/outputs/bundle/release/app-release.aab`

## 5) Checklist upload Google Play

Sebelum submit:
1. Naikkan `version` di `pubspec.yaml` (contoh `1.0.1+2`).
2. Lengkapi Data Safety form.
3. Siapkan privacy policy URL.
4. Upload icon, feature graphic, screenshot hp/tablet.
5. Isi content rating & target audience.
6. Aktifkan Play App Signing (disarankan).

## 6) Persiapan iOS untuk App Store

> Wajib dilakukan di macOS.

1. Buka:
   - `ios/Runner.xcworkspace`
2. Xcode > Runner > Signing & Capabilities:
   - Team: Apple Developer team.
   - Bundle Identifier: `com.jomngaji.app`.
3. Pastikan App Store profile/certificate valid (Automatic Signing direkomendasikan).

Build archive:

```bash
flutter clean
flutter pub get
flutter build ipa --release
```

Atau lewat Xcode:
1. Product > Archive.
2. Distribute App > App Store Connect > Upload.

## 7) Checklist upload Apple App Store

1. Naikkan `version` + `build number` di Flutter (`pubspec.yaml` atau argumen build).
2. Lengkapi App Privacy (tracking/data collection).
3. Siapkan App Store screenshot (semua ukuran wajib).
4. Isi metadata lokal (deskripsi, keyword, support URL, privacy URL).
5. Pastikan tidak ada placeholder URL/key di app.

## 8) Quality gate sebelum release

Jalankan minimal:

```bash
flutter analyze
flutter test
```

Opsional sangat disarankan:
- smoke test login/register/google sign-in di device fisik,
- smoke test seluruh fitur audio/recording,
- verifikasi endpoint production wajib HTTPS.
