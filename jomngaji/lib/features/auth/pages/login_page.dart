import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/localization/app_localization.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../features/auth/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const String _googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool isGoogleLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      await AuthService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          backgroundColor: Colors.redAccent,
          content: Text(
            _friendlyLoginError(e),
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => isGoogleLoading = true);
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email'],
        serverClientId: _googleWebClientId.isEmpty ? null : _googleWebClientId,
      );

      await googleSignIn.signOut();
      final account = await googleSignIn.signIn();
      if (account == null) return;

      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'ID token Google tidak tersedia. '
          'Pastikan Web Client ID benar via '
          '--dart-define=GOOGLE_WEB_CLIENT_ID=<web-client-id>.',
        );
      }

      await AuthService.loginWithGoogle(
        idToken,
        accessToken: accessToken,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          backgroundColor: Colors.redAccent,
          content: Text(
            _friendlyGoogleError(e),
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => isGoogleLoading = false);
    }
  }

  String _friendlyGoogleError(Object error) {
    final raw = error.toString();
    if (error is PlatformException && error.code == 'network_error') {
      return 'Koneksi ke Google Play Services bermasalah. Cek internet, tanggal/jam otomatis, lalu coba lagi.';
    }
    if (raw.contains('ApiException: 7') || raw.contains('network_error')) {
      return 'Tidak bisa terhubung ke Google (ApiException: 7).';
    }
    if (raw.contains('10')) {
      return 'Konfigurasi OAuth Google belum valid. Pastikan packageName + SHA-1 sesuai.';
    }
    return 'Google login gagal. Silakan coba lagi.';
  }

  String _friendlyLoginError(Object error) {
    final raw = error.toString();
    if (raw.contains('TimeoutException')) {
      return 'Koneksi ke server timeout. Cek internet lalu coba lagi.';
    }
    if (raw.contains('Failed host lookup') || raw.contains('SocketException')) {
      return 'Backend tidak bisa diakses. Cek koneksi internet anda.';
    }
    return 'Login gagal. Periksa email/password dan koneksi internet.';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return WillPopScope(
      onWillPop: () async {
        await SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _logoHeader(),
                const SizedBox(height: 32),
                Text(
                  l10n.text('login.welcome'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.text('login.subtitle'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                _loginForm(l10n),
                const SizedBox(height: 32),
                _footer(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoHeader() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.medium,
      ),
      child: Center(
        child: Container(
          width: 70,
          height: 70,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Image.asset(
            'assets/images/icon-jomngaji.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _loginForm(AppLocalization l10n) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: emailController,
            label: l10n.text('login.email'),
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Email wajib diisi';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: passwordController,
            label: l10n.text('login.password'),
            icon: Icons.lock_rounded,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password wajib diisi';
              }
              if (value.length < 6) {
                return 'Password minimal 6 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (isLoading || isGoogleLoading) ? null : _handleLogin,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(l10n.text('login.button')),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "atau lanjut dengan",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textPlaceholder,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: isGoogleLoading
                  ? const SizedBox.shrink()
                  : const Icon(Icons.g_mobiledata_rounded, size: 28),
              label: isGoogleLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.text('login.googleButton')),
              onPressed: (isLoading || isGoogleLoading) ? null : _handleGoogleLogin,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            hintText: "Masukkan ${label.toLowerCase()}",
            hintStyle: GoogleFonts.plusJakartaSans(
              color: AppColors.textPlaceholder,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _footer(AppLocalization l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.text('login.noAccount'),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
          child: Text(
            "Daftar Sekarang",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
