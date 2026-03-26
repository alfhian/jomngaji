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
1. **Design system belum konsisten end-to-end**
   - `AppTheme` dan standar visual sudah ada, namun masih banyak style/spacing/color hardcoded per page.
   - Dampak: UI sulit dipelihara saat skala fitur bertambah dan berisiko inkonsisten antar-screen.
2. **Aksesibilitas (a11y) belum menjadi baseline**
   - Belum ada aturan baku untuk dynamic text scale, semantics label, minimum tap target, dan kontras.
   - Dampak: pengalaman pengguna dengan kebutuhan aksesibilitas menurun dan potensi drop-off naik.
3. **Validasi & error UX auth belum seragam**
   - Register sudah menggunakan validasi form, sementara login masih bergantung alur submit langsung.
   - Dampak: UX error handling tidak konsisten dan pengguna sulit memahami cara memperbaiki input.
4. **Lifecycle input controller belum seragam**
   - Beberapa halaman stateful auth masih berpotensi tidak menutup `TextEditingController` secara konsisten.
   - Dampak: risiko memory leak kecil-menengah pada sesi panjang dan maintainability menurun.
5. **Internationalization belum tuntas**
   - Infrastruktur localization sudah ada, namun banyak string masih hardcoded pada layer UI.
   - Dampak: sulit menambah multi-bahasa dan copy update membutuhkan perubahan kode langsung.
6. **Komponen status produk belum konsisten**
   - Label fitur berbayar sempat bercampur antara istilah “Premium” dan “PRO”.
   - Dampak: brand voice kurang konsisten dan berpotensi membingungkan pengguna.

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
5. **Samakan istilah monetisasi menjadi “PRO” di seluruh UI** (menu, badge, CTA, dialog, copy).

### 1-2 minggu
1. Refactor ke **theme system tunggal** (`AppTheme` + design tokens).
2. Terapkan **Form validation** juga di login.
3. Terapkan checklist **aksesibilitas minimum** (semantics, kontras, text scale, tap target).
4. Tambahkan **route guard/auth middleware** di level routing.
5. Sanitasi error message untuk user-friendly output.

### 2-4 minggu
1. Audit aksesibilitas (kontras warna, dynamic text scale, semantics, focus order).
2. Lakukan uji usability cepat (task completion, error rate, time-on-task) untuk alur login, onboarding, dan modul belajar.
3. Tambah automated lint/check untuk mencegah hardcoded secret di commit berikutnya.
4. Bentuk **UX quality gate** pada PR checklist (consistency, a11y, i18n, error UX, performance).

## Rencana perbaikan Gap / Risiko UX (end-to-end)

| Area | Risiko | Aksi Fix | Output |
|---|---|---|---|
| Design System | Inkonsistensi visual antar layar | Migrasi style hardcoded ke token/theme + reusable widget | Konsistensi visual dan refactor lebih cepat |
| Accessibility | Sulit dipakai user dengan kebutuhan khusus | Tambah semantics, kontras minimum, text scale test, tap target min 44dp | Peningkatan aksesibilitas terukur |
| Form & Validation | Error handling tidak konsisten | Login disamakan dengan Form validator register + inline error | Input flow lebih jelas, error rate turun |
| Controller Lifecycle | Potensi leak & debt teknis | Wajib `dispose()` untuk seluruh controller stateful + lint/code review checklist | Stabilitas runtime lebih baik |
| Localization | Sulit scale multi-bahasa | Pindahkan seluruh hardcoded string ke localization keys | Proses terjemahan lebih cepat |
| Terminologi Monetisasi | Copy membingungkan | Standarisasi seluruh label jadi “PRO” | Brand voice konsisten |

## Verdict

- **UI/UX saat ini:** sudah punya fondasi visual yang bagus, **belum matang** untuk standar accessibility & konsistensi skala.
- **Security saat ini:** **belum layak production** sampai isu critical/high ditutup.
