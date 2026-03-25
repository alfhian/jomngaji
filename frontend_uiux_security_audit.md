# Frontend UI/UX & Security Audit (JomNgaji)

Tanggal audit: 2026-03-25
Scope: folder `jomngaji/` (Flutter frontend)

## Ringkasan status

- **UI/UX: Cukup baik** untuk visual dasar dan alur utama (login/register), tetapi belum konsisten terhadap aksesibilitas dan skala maintainability.
- **Security: Belum aman untuk production** karena ditemukan kredensial/API key di sisi client, penggunaan HTTP plaintext, dan penyimpanan token pada storage non-secure.

## Temuan UI/UX

### Kekuatan
1. Desain visual login/register sudah modern (gradient, hierarchy, spacing, state loading).
2. Sudah menggunakan Material 3 dan Google Fonts sehingga basis desain cukup rapi.
3. Register sudah memakai validasi form dasar (required, email format, minimum password length).

### Gap / Risiko UX
1. **Theme terpusat belum dipakai konsisten**
   - `AppTheme` tersedia tetapi `MaterialApp` masih membuat `ThemeData` inline di `main.dart`.
2. **Aksesibilitas belum optimal**
   - Banyak ukuran font dan warna hardcoded pada login/register, belum terlihat strategi text scaling atau semantic labels.
3. **Login belum berbasis Form validator**
   - Login memakai `TextField` biasa, bukan `TextFormField + Form` seperti register.
4. **Stateful controller belum di-dispose**
   - `TextEditingController` dibuat pada halaman auth namun tidak terlihat override `dispose()`.
5. **Internationalization belum konsisten**
   - Infrastruktur localization ada, tetapi string UI auth banyak yang hardcoded Indonesia.

## Temuan Security

### Critical
1. **Hardcoded OpenAI API key di source code client**
   - API key bisa diekstrak dari APK/IPA dan disalahgunakan.
2. **Hardcoded AssemblyAI API key di source code client**
   - Risiko billing abuse, data leakage, dan revocation paksa.

### High
3. **Banyak endpoint masih HTTP (tanpa TLS/HTTPS)**
   - Token dan payload sensitif bisa disadap (MITM), terutama di jaringan publik.
4. **Auth token disimpan di `SharedPreferences`**
   - Untuk token akses, sebaiknya gunakan secure storage (Android Keystore / iOS Keychain).

### Medium
5. **Error mentah dari backend ditampilkan ke pengguna**
   - Potensi informasi internal server terekspos ke UI.
6. **Tidak ada route guard eksplisit untuk halaman privat**
   - Akses halaman sensitif bergantung flow awal, bukan guard per-route.

## Rekomendasi prioritas

### 0-3 hari (wajib sebelum production)
1. **Rotate semua API key yang terlanjur terekspos** (OpenAI, AssemblyAI).
2. **Pindahkan seluruh panggilan API ber-key ke backend proxy** (jangan dari app client langsung).
3. **Wajibkan HTTPS untuk seluruh endpoint API**.
4. **Migrasikan token ke secure storage**.

### 1-2 minggu
1. Refactor ke **theme system tunggal** (`AppTheme` + design tokens).
2. Terapkan **Form validation** juga di login.
3. Tambahkan **route guard/auth middleware** di level routing.
4. Sanitasi error message untuk user-friendly output.

### 2-4 minggu
1. Audit aksesibilitas (kontras warna, dynamic text scale, semantics, focus order).
2. Lakukan uji usability cepat (task completion, error rate, time-on-task).
3. Tambah automated lint/check untuk mencegah hardcoded secret di commit berikutnya.

## Verdict

- **UI/UX saat ini:** sudah punya fondasi visual yang bagus, **belum matang** untuk standar accessibility & konsistensi skala.
- **Security saat ini:** **belum layak production** sampai isu critical/high ditutup.
