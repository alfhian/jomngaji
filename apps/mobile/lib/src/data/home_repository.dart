import 'dart:async';

import 'package:flutter/material.dart';

import '../models/assessment_summary.dart';
import '../models/coach_session.dart';
import '../models/community_highlight.dart';
import '../models/home_overview.dart';
import '../models/journey.dart';
import '../models/learning_program.dart';
import '../models/student_profile.dart';

class HomeRepository {
  Future<HomeOverview> fetchOverview() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    const programModules = [
      ProgramModule(
        id: 'module-intro',
        order: 1,
        title: 'Fondasi Tajwid Harian',
        description: 'Penguatan makhraj hijaiyah dan pengucapan panjang-pendek dasar.',
        focusSurah: 'Al-Fatihah',
        ayahRange: '1-7',
        estimatedMinutes: 45,
        outcomes: [
          'Memahami pola mad thabi\'i',
          'Menjaga keseimbangan nafas',
          'Mengenali kesalahan umum bacaan awal',
        ],
      ),
      ProgramModule(
        id: 'module-flow',
        order: 2,
        title: 'Kelancaran Tilawah',
        description: 'Latihan kesinambungan ayat pilihan juz 30 dengan tempo stabil.',
        focusSurah: 'An-Naba\'',
        ayahRange: '1-20',
        estimatedMinutes: 60,
        outcomes: [
          'Kelancaran tanpa terhenti',
          'Penguasaan irama dasar murattal',
        ],
      ),
      ProgramModule(
        id: 'module-mastery',
        order: 3,
        title: 'Mastery dan Sertifikasi',
        description: 'Simulasi ujian akhir bersama coach dan AI feedback realtime.',
        focusSurah: 'Yasin',
        ayahRange: '1-40',
        estimatedMinutes: 75,
        outcomes: [
          'Siap menghadapi ujian akhir',
          'Mampu menjaga konsistensi bacaan panjang',
        ],
      ),
    ];

    final heroProgram = LearningProgram(
      id: 'program-personal-tajwid',
      slug: 'tajwid-pro-intake',
      title: 'Ngaji.ai Personal Tajwid',
      subtitle: 'Pendampingan adaptif dengan AI dan coach bersertifikat',
      focusArea: 'Tahsin & kelancaran tilawah',
      level: 'Intermediate',
      estimatedWeeks: 12,
      accentColor: const Color(0xFF6750A4),
      sellingPoints: const [
        'Penilaian awal otomatis dalam 3 menit',
        'Rencana belajar disesuaikan ritme harian',
        'Coach eksklusif tiap pekan',
      ],
      modules: programModules,
    );

    final complementaryPrograms = [
      heroProgram,
      LearningProgram(
        id: 'program-family',
        slug: 'keluarga-harmonis',
        title: 'Kelas Keluarga Harmonis',
        subtitle: 'Sesi interaktif untuk ayah bunda dan anak usia 7-12 tahun',
        focusArea: 'Ngaji keluarga & character building',
        level: 'Beginner',
        estimatedWeeks: 8,
        accentColor: const Color(0xFF3B82F6),
        sellingPoints: const [
          'Metode belajar gamified untuk anak',
          'Progress tracker bersama orang tua',
          'Live class akhir pekan',
        ],
        modules: const [],
      ),
      LearningProgram(
        id: 'program-hafalan',
        slug: 'hafalan-rutin',
        title: 'Hafalan & Murajaah Intensif',
        subtitle: 'Target hafalan 1 juz per 6 minggu dengan monitoring AI',
        focusArea: 'Tahfidz & murajaah',
        level: 'Advance',
        estimatedWeeks: 18,
        accentColor: const Color(0xFF0EA5E9),
        sellingPoints: const [
          'Laporan hafalan mingguan otomatis',
          'Partner murajaah daring',
          'Pendampingan coach spesialis tahfidz',
        ],
        modules: const [],
      ),
    ];

    final journey = LearningJourney(
      id: 'journey-1',
      program: heroProgram,
      completionPercent: 42,
      focusStatement: 'Memperhalus mad dan menjaga tempo stabil untuk sesi sertifikasi.',
      stages: const [
        JourneyStage(
          title: 'Assessment & Goal Setting',
          description: 'AI benchmarking & konsultasi awal',
          state: JourneyStageState.completed,
        ),
        JourneyStage(
          title: 'Bootcamp Foundations',
          description: 'Drill tajwid inti bersama coach',
          state: JourneyStageState.current,
        ),
        JourneyStage(
          title: 'AI Guided Practice',
          description: 'Latihan mandiri adaptif & penguatan',
          state: JourneyStageState.upcoming,
        ),
        JourneyStage(
          title: 'Mastery & Certification',
          description: 'Ujian akhir & sertifikasi internal',
          state: JourneyStageState.upcoming,
        ),
      ],
      todayMissions: [
        DailyMission(
          id: 'mission-ai',
          title: 'AI Drill Mad Thabi\'i',
          type: MissionType.aiPractice,
          status: MissionStatus.inProgress,
          scheduledFor: DateTime.now(),
          durationMinutes: 12,
          surah: 'Al-Fatihah',
          ayahRange: '1-7',
          repetitionGoal: 3,
          resources: ['video:mad-basics', 'pdf:panduan-tajwid'],
          ctaLabel: 'Mulai latihan',
        ),
        DailyMission(
          id: 'mission-live',
          title: 'Coaching Clinic Makhraj',
          type: MissionType.liveSession,
          status: MissionStatus.upcoming,
          scheduledFor: DateTime.now().add(const Duration(hours: 3)),
          durationMinutes: 30,
          surah: 'Al-Baqarah',
          ayahRange: '1-10',
          resources: ['checklist:makhraj'],
          ctaLabel: 'Konfirmasi kehadiran',
        ),
        DailyMission(
          id: 'mission-reflect',
          title: 'Catatan Refleksi Pasca Latihan',
          type: MissionType.reflection,
          status: MissionStatus.upcoming,
          scheduledFor: DateTime.now().add(const Duration(hours: 8)),
          durationMinutes: 10,
          resources: ['template:jurnal'],
          ctaLabel: 'Tulis insight',
        ),
      ],
      nextAssessment: DateTime.now().add(const Duration(days: 5)),
      activeModule: programModules[1],
    );

    final assessment = AssessmentSummary(
      overallScore: 83,
      tajwid: 80,
      fluency: 78,
      makhraj: 85,
      pacing: 76,
      recordedAt: DateTime.now().subtract(const Duration(days: 2)),
      summary:
          'AI mendeteksi peningkatan mad 12% dari pekan lalu. Fokuskan latihan pada transisi huruf qolqolah.',
      focusAreas: const [
        'Perkuat ghunnah saat membaca nun tasydid',
        'Stabilkan tempo 95 bpm ketika berpindah ayat panjang',
      ],
    );

    final sessions = [
      CoachSession(
        id: 'session-1',
        coachName: 'Ustadzah Hana',
        scheduledAt: DateTime.now().add(const Duration(hours: 4)),
        status: 'SCHEDULED',
        mode: 'Google Meet',
        meetingUrl: 'https://meet.ngaji.ai/hana-session',
        agenda: 'Review tajwid module 2 & simulasi ujian.',
      ),
      CoachSession(
        id: 'session-2',
        coachName: 'Ustadz Rahman',
        scheduledAt: DateTime.now().add(const Duration(days: 2, hours: 1)),
        status: 'SCHEDULED',
        mode: 'Onsite Studio',
        agenda: 'Praktik maqamat & nada.',
      ),
    ];

    final highlights = [
      const CommunityHighlight(
        id: 'highlight-1',
        title: 'Santri Batch Ramadhan capai 92% kelulusan',
        description:
            'Program intensif 6 minggu dengan kombinasi AI feedback dan halaqah hybrid sukses bantu 320 santri.',
        tag: 'Kisah Sukses',
      ),
      const CommunityHighlight(
        id: 'highlight-2',
        title: 'Fitur baru: Heatmap Kesalahan Tajwid',
        description:
            'Visualisasi detail kesalahan huruf tebal vs tipis yang siap membantu Anda berlatih lebih fokus.',
        tag: 'Produk',
      ),
    ];

    final profile = StudentProfile(
      name: 'Aisyah Rahma',
      level: 'Intermediate',
      primaryGoal: 'Siap sertifikasi tilawah akhir Ramadhan',
      streakDays: 8,
      completedSessions: 27,
      timezone: 'Asia/Jakarta',
      nextCheckIn: DateTime.now().add(const Duration(days: 1)),
    );

    return HomeOverview(
      profile: profile,
      journey: journey,
      recommendedPrograms: complementaryPrograms,
      assessment: assessment,
      upcomingSessions: sessions,
      communityHighlights: highlights,
    );
  }
}
