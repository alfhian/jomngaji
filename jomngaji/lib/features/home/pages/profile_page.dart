import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../core/localization/app_localization.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';
import '../../../core/widgets/premium_upgrade_dialog.dart';
import '../../../routes/app_routes.dart';
import '../../auth/services/auth_service.dart';
import '../../../services/prayer_reminder_service.dart';
import '../widgets/app_bottom_nav.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  String _name = 'Pengguna';

  double _iqra = 0;
  double _tajwid = 0;
  double _tilawah = 0;
  double _tahfidz = 0;
  double _tadarus = 0;

  int _iqraScore = 0;
  int _tajwidScore = 0;
  int _tilawahScore = 0;
  int _tahfidzScore = 0;
  bool _isPremium = false;
  bool _prayerReminderEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileProgress();
      _loadPrayerReminderStatus();
    });
  }

  Future<void> _loadPrayerReminderStatus() async {
    final enabled = await PrayerReminderService.isEnabled();
    if (!mounted) return;
    setState(() => _prayerReminderEnabled = enabled);
  }

  Future<void> _togglePrayerReminder(bool value) async {
    try {
      if (value) {
        await PrayerReminderService.enableDefaultReminders();
      } else {
        await PrayerReminderService.disableReminders();
      }
      if (!mounted) return;
      setState(() => _prayerReminderEnabled = value);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Pengingat sholat aktif. Notifikasi harian telah dijadwalkan.'
                : 'Pengingat sholat dimatikan.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengatur pengingat sholat: $e')),
      );
    }
  }

  Widget _prayerReminderCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_rounded, color: Color(0xFF16A34A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pengingat Waktu Sholat',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Switch.adaptive(
                value: _prayerReminderEnabled,
                activeColor: const Color(0xFF16A34A),
                onChanged: _togglePrayerReminder,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Aktifkan notifikasi untuk Subuh, Dzuhur, Ashar, Maghrib, dan Isya setiap hari.',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  double _normalizeProgress(dynamic value) {
    final raw = double.tryParse('${value ?? 0}') ?? 0;
    if (raw > 1) return (raw / 100).clamp(0, 1);
    return raw.clamp(0, 1);
  }

  int _normalizeScore(dynamic value) {
    final raw = double.tryParse('${value ?? 0}') ?? 0;
    if (raw > 100) return 100;
    if (raw < 0) return 0;
    return raw.round();
  }

  double _extractProgress(Map<String, dynamic> json) {
    for (final key in const [
      'progress',
      'percentage',
      'completion',
      'completion_rate',
      'overall_progress',
    ]) {
      if (json.containsKey(key)) {
        return _normalizeProgress(json[key]);
      }
    }

    final completed = double.tryParse('${json['completed'] ?? json['completed_questions'] ?? json['completed_ayah'] ?? 0}') ?? 0;
    final total = double.tryParse('${json['total'] ?? json['total_questions'] ?? json['total_ayah'] ?? 0}') ?? 0;
    if (total > 0) return (completed / total).clamp(0, 1);

    return 0;
  }

  Future<void> _loadProfileProgress() async {
    setState(() => _loading = true);
    try {
      final token = await AuthService.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Session login tidak ditemukan. Silakan login ulang.');
      }

      final headers = {'Authorization': 'Bearer $token'};
      final userName = (await AuthService.getUserName()) ?? 'Pengguna';
      final moduleProgressResponse = await http.get(
        Uri.parse('${AuthService.baseUrl}/progress/modules'),
        headers: headers,
      );
      final summaryResponse = await http.get(
        Uri.parse('${AuthService.baseUrl}/progress/summary'),
        headers: headers,
      );
      final tadarusResponse = await http.get(
        Uri.parse('${AuthService.baseUrl}/tadarus/global-progress'),
        headers: headers,
      );

      final moduleJson = moduleProgressResponse.statusCode == 200
          ? (jsonDecode(moduleProgressResponse.body) as Map<String, dynamic>)
          : <String, dynamic>{};
      final summaryJson = summaryResponse.statusCode == 200
          ? (jsonDecode(summaryResponse.body) as Map<String, dynamic>)
          : <String, dynamic>{};
      final tadarusJson = tadarusResponse.statusCode == 200
          ? (jsonDecode(tadarusResponse.body) as Map<String, dynamic>)
          : <String, dynamic>{};

      if (!mounted) return;
      setState(() {
        _name = userName;
        _isPremium = (summaryJson['is_premium'] == true) ||
            (summaryJson['pro'] == true);
        _iqra = _extractProgress(
          (moduleJson['iqra'] as Map<String, dynamic>?) ?? <String, dynamic>{},
        );
        _tajwid = _extractProgress(
          (moduleJson['tajwid'] as Map<String, dynamic>?) ?? <String, dynamic>{},
        );
        _tilawah = _extractProgress(
          (moduleJson['tilawah'] as Map<String, dynamic>?) ?? <String, dynamic>{},
        );
        _tahfidz = _extractProgress(
          (moduleJson['tahfidz'] as Map<String, dynamic>?) ?? <String, dynamic>{},
        );
        _tadarus = _extractProgress(tadarusJson);

        _iqraScore = _normalizeScore(summaryJson['iqra_score']);
        _tajwidScore = _normalizeScore(summaryJson['tajwid_score']);
        _tilawahScore = _normalizeScore(summaryJson['tilawah_score']);
        _tahfidzScore = _normalizeScore(summaryJson['tahfidz_score']);
      });
      final localPremium = await AuthService.isPremiumUser();
      if (!mounted) return;
      setState(() {
        _isPremium = _isPremium || localPremium;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal load profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _progressTile({
    required String label,
    required double value,
    required Color color,
  }) {
    final percent = (value * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Semantics(
        label: 'Progress $label',
        value: '$percent persen',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),
                Text('$percent%',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    )),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.grey.shade300,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _examScoreCard({
    required String title,
    required int score,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white24,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$score',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileHeader() {
    final avg = ((_iqra + _tajwid + _tilawah + _tahfidz + _tadarus) / 5) * 100;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.text(
                    'profile.avgProgress',
                    params: {'value': avg.toStringAsFixed(1)},
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.l10n.text('profile.refreshTooltip'),
            onPressed: _loadProfileProgress,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _languageCard() {
    final languageController = AppLocalizationScope.controllerOf(context);
    final currentLanguageLabel = context.l10n.text(languageController.value.key);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.language_rounded,
              color: Color(0xFF0F172A),
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.text('profile.languageTitle'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<AppLanguage>(
              value: languageController.value,
              isDense: true,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
              ),
              selectedItemBuilder: (context) {
                return AppLanguage.values.map((_) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      currentLanguageLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList();
              },
              items: AppLanguage.values.map((language) {
                return DropdownMenuItem(
                  value: language,
                  child: Text(context.l10n.text(language.key)),
                );
              }).toList(),
              onChanged: (language) {
                if (language != null) {
                  languageController.setLanguage(language);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _planCard() {
    final planLabel = _isPremium ? 'PRO' : 'FREE';
    final planColor = _isPremium ? const Color(0xFF16A34A) : const Color(0xFF2563EB);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_rounded, color: planColor),
              const SizedBox(width: 8),
              Text(
                context.l10n.text('profile.currentPlan'),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: planColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  planLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: planColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _isPremium
                ? context.l10n.text('profile.planActivePro')
                : context.l10n.text('profile.planFreePrompt'),
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Semantics(
              button: true,
              label: _isPremium ? 'Kelola Plan PRO' : 'Update Plan ke PRO',
              child: ElevatedButton.icon(
                onPressed: () => showPremiumUpgradeDialog(
                  context,
                  featureName: _isPremium
                      ? context.l10n.text('profile.managePlan')
                      : context.l10n.text('profile.updatePlan'),
                ),
                icon: const Icon(Icons.autorenew_rounded),
                label: Text(
                  _isPremium
                      ? context.l10n.text('profile.managePlan')
                      : context.l10n.text('profile.updatePlan'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: planColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(context.l10n.text('profile.logoutConfirmTitle')),
          content: Text(context.l10n.text('profile.logoutConfirmMessage')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.l10n.text('common.cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(context.l10n.text('profile.logout')),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CustomGradientAppBar(title: context.l10n.text('profile.title')),
      extendBody: true,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfileProgress,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _profileHeader(),
                  const SizedBox(height: 20),
                  Text(
                    context.l10n.text('profile.latestExam'),
                    style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  _examScoreCard(
                    title: 'Exam Iqra',
                    score: _iqraScore,
                    icon: Icons.auto_stories_rounded,
                    gradient: const [Color(0xFF22C55E), Color(0xFF16A34A)],
                  ),
                  const SizedBox(height: 10),
                  _examScoreCard(
                    title: 'Exam Tajwid',
                    score: _tajwidScore,
                    icon: Icons.graphic_eq_rounded,
                    gradient: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
                  ),
                  const SizedBox(height: 10),
                  _examScoreCard(
                    title: 'Exam Tilawah',
                    score: _tilawahScore,
                    icon: Icons.multitrack_audio_rounded,
                    gradient: const [Color(0xFFA78BFA), Color(0xFF7C3AED)],
                  ),
                  const SizedBox(height: 10),
                  _examScoreCard(
                    title: 'Exam Tahfidz',
                    score: _tahfidzScore,
                    icon: Icons.school_rounded,
                    gradient: const [Color(0xFFF59E0B), Color(0xFFEA580C)],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.l10n.text('profile.learningProgress'),
                    style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  _progressTile(
                    label: 'Iqra',
                    value: _iqra,
                    color: const Color(0xFF42C88A),
                  ),
                  _progressTile(
                    label: 'Tajwid',
                    value: _tajwid,
                    color: Colors.blueAccent,
                  ),
                  _progressTile(
                    label: 'Tilawah',
                    value: _tilawah,
                    color: Colors.deepPurple,
                  ),
                  _progressTile(
                    label: 'Tahfidz',
                    value: _tahfidz,
                    color: Colors.orange,
                  ),
                  _progressTile(
                    label: 'Tadarus',
                    value: _tadarus,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 8),
                  _planCard(),
                  const SizedBox(height: 12),
                  _languageCard(),
                  const SizedBox(height: 12),
                  _prayerReminderCard(),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.resetPassword),
                      icon: const Icon(Icons.lock_reset_rounded),
                      label: Text(context.l10n.text('profile.resetPassword')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F172A),
                        side: const BorderSide(color: Color(0xFFB8C4D8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Semantics(
                      button: true,
                      label: 'Logout akun',
                      child: ElevatedButton.icon(
                        onPressed: _confirmLogout,
                        icon: const Icon(Icons.logout_rounded),
                        label: Text(context.l10n.text('profile.logout')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}
