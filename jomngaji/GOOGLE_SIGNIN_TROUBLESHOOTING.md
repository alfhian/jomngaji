# Google Sign-In Troubleshooting (Android)

Jika muncul error seperti:
- `network_error`
- `com.google.android.gms.common.api.ApiException: 7`

itu **umumnya bukan** karena URL backend (`API_BASE_URL`), melainkan koneksi perangkat ke layanan Google.

## Checklist cepat

1. **Internet emulator/perangkat**
   - Buka browser di emulator dan coba akses `https://accounts.google.com`.
   - Jika tidak bisa, perbaiki koneksi emulator/device dulu.

2. **Tanggal/Jam otomatis**
   - Aktifkan `Automatic date & time` + `Automatic time zone`.
   - Waktu yang meleset bisa membuat auth Google gagal.

3. **Google Play Services**
   - Gunakan emulator image yang ada Play Store.
   - Update Google Play Services dari Play Store.
   - Restart emulator setelah update.

4. **Login akun Google di emulator**
   - Pastikan emulator sudah login akun Google.

5. **Cek OAuth/Firebase config (untuk error code 10)**
   - Pastikan `google-services.json` sesuai package name app.
   - Tambahkan SHA-1 & SHA-256 debug/release ke Firebase.
   - Pastikan Web Client ID sesuai yang dipakai app (`GOOGLE_WEB_CLIENT_ID`).

6. **Bersihkan build**
   - `flutter clean`
   - `flutter pub get`
   - run ulang app.

## Catatan penting

- Error `ApiException: 7` biasanya masalah koneksi ke layanan Google, **bukan** endpoint API backend Anda.
- Jadi biasanya **tidak perlu ganti URL backend** untuk menyelesaikan error ini.
