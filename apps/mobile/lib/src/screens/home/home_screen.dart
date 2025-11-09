import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../data/home_repository.dart';
import '../../models/assessment_summary.dart';
import '../../models/community_highlight.dart';
import '../../models/home_overview.dart';
import '../../models/coach_session.dart';
import '../../models/journey.dart';
import '../../models/learning_program.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeRepository _repository = GetIt.I<HomeRepository>();
  late Future<HomeOverview> _overviewFuture = _repository.fetchOverview();

  Future<void> _refresh() async {
    setState(() {
      _overviewFuture = _repository.fetchOverview();
    });
    await _overviewFuture;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FutureBuilder<HomeOverview>(
          future: _overviewFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _ErrorState(onRetry: _refresh, error: snapshot.error);
            }

            final overview = snapshot.data!;

            return RefreshIndicator(
              onRefresh: _refresh,
              color: theme.colorScheme.primary,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: _HomeHeader(overview: overview),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: _JourneyHeroCard(journey: overview.journey),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _StageTimeline(stages: overview.journey.stages),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: _SectionHeader(
                        title: 'Fokus Hari Ini',
                        subtitle: 'Rangkaian aktivitas dari assessment hingga sesi live.',
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final mission = overview.journey.todayMissions[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child: _MissionCard(mission: mission),
                        );
                      },
                      childCount: overview.journey.todayMissions.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: _AssessmentCard(summary: overview.assessment),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                      child: _SectionHeader(
                        title: 'Jadwal Bersama Coach',
                        subtitle: 'Tetap on-track dengan sesi mentoring privat.',
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 160,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) => _CoachSessionCard(
                          session: overview.upcomingSessions[index],
                        ),
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemCount: overview.upcomingSessions.length,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                      child: _SectionHeader(
                        title: 'Program Rekomendasi',
                        subtitle: 'Pilih jalur tambahan untuk memperkaya perjalanan Anda.',
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 200,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) => _ProgramCard(
                          program: overview.recommendedPrograms[index],
                        ),
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemCount: overview.recommendedPrograms.length,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                      child: _SectionHeader(
                        title: 'Sorotan Komunitas',
                        subtitle: 'Belajar dari santri lain dan update fitur terbaru.',
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final highlight = overview.communityHighlights[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child: _CommunityHighlightCard(highlight: highlight),
                        );
                      },
                      childCount: overview.communityHighlights.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 48)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.overview});

  final HomeOverview overview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = DateFormat('EEEE, d MMM').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Assalamualaikum, ${overview.profile.name.split(' ').first}',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _InfoChip(
              icon: Icons.auto_awesome,
              label: '${overview.profile.level} Journey',
            ),
            _InfoChip(
              icon: Icons.star_rounded,
              label: '${overview.profile.streakDays} hari konsisten',
            ),
            _InfoChip(
              icon: Icons.timelapse_rounded,
              label: 'Check-in berikutnya ${DateFormat('d MMM').format(overview.profile.nextCheckIn)}',
            ),
          ],
        ),
      ],
    );
  }
}

class _JourneyHeroCard extends StatelessWidget {
  const _JourneyHeroCard({required this.journey});

  final LearningJourney journey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = journey.program.accentColor;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.85), color.withOpacity(0.65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            journey.program.title,
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            journey.focusStatement,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: journey.completionPercent / 100,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    color: Colors.amberAccent,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${journey.completionPercent.toStringAsFixed(0)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.event_available, color: Colors.white.withOpacity(0.9)),
              const SizedBox(width: 8),
              Text(
                "Assessment selanjutnya ${DateFormat('d MMM').format(journey.nextAssessment)}",
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
              ),
            ],
          ),
          if (journey.activeModule != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.layers, color: Colors.white.withOpacity(0.9)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Modul aktif: ${journey.activeModule!.title}",
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StageTimeline extends StatelessWidget {
  const _StageTimeline({required this.stages});

  final List<JourneyStage> stages;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final stage = stages[index];
          return _StageCard(stage: stage);
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: stages.length,
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.stage});

  final JourneyStage stage;

  Color _resolveBackground(BuildContext context) {
    final theme = Theme.of(context);
    switch (stage.state) {
      case JourneyStageState.completed:
        return theme.colorScheme.primaryContainer.withOpacity(0.6);
      case JourneyStageState.current:
        return theme.colorScheme.primaryContainer;
      case JourneyStageState.upcoming:
        return theme.colorScheme.surface;
    }
  }

  IconData _resolveIcon() {
    switch (stage.state) {
      case JourneyStageState.completed:
        return Icons.check_circle_rounded;
      case JourneyStageState.current:
        return Icons.bolt_rounded;
      case JourneyStageState.upcoming:
        return Icons.lock_clock_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _resolveBackground(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: stage.state == JourneyStageState.current
              ? theme.colorScheme.primary.withOpacity(0.4)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_resolveIcon(), color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            stage.title,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            stage.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission});

  final DailyMission mission;

  Color _resolveColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (mission.type) {
      case MissionType.aiPractice:
        return scheme.primaryContainer;
      case MissionType.liveSession:
        return scheme.tertiaryContainer;
      case MissionType.reflection:
        return scheme.secondaryContainer;
    }
  }

  IconData _resolveIcon() {
    switch (mission.type) {
      case MissionType.aiPractice:
        return Icons.graphic_eq_rounded;
      case MissionType.liveSession:
        return Icons.people_alt_rounded;
      case MissionType.reflection:
        return Icons.edit_note_rounded;
    }
  }

  String _resolveTypeLabel() {
    switch (mission.type) {
      case MissionType.aiPractice:
        return 'Latihan AI';
      case MissionType.liveSession:
        return 'Sesi Coach';
      case MissionType.reflection:
        return 'Refleksi';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeLabel = DateFormat('HH:mm').format(mission.scheduledFor);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _resolveColor(context).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _resolveColor(context),
                child: Icon(_resolveIcon(), color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _resolveTypeLabel(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    mission.title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${mission.durationMinutes} mnt',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text('$timeLabel WIB', style: theme.textTheme.bodySmall),
              if (mission.surah != null) ...[
                const SizedBox(width: 16),
                Icon(Icons.menu_book_rounded, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text('${mission.surah} ${mission.ayahRange}', style: theme.textTheme.bodySmall),
              ],
            ],
          ),
          if (mission.resources.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: mission.resources
                  .map((item) => Chip(
                        label: Text(item.split(':').last.replaceAll('-', ' ')),
                      ))
                  .toList(),
            ),
          ],
          if (mission.ctaLabel != null) ...[
            const SizedBox(height: 14),
            FilledButton.tonal(
              onPressed: () {},
              child: Text(mission.ctaLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({required this.summary});

  final AssessmentSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('d MMMM yyyy').format(summary.recordedAt);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Ringkasan Penilaian AI',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(dateLabel, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _ScorePill(label: 'Overall', value: summary.overallScore),
              _ScorePill(label: 'Tajwid', value: summary.tajwid),
              _ScorePill(label: 'Fluency', value: summary.fluency),
              _ScorePill(label: 'Makhraj', value: summary.makhraj),
              _ScorePill(label: 'Pacing', value: summary.pacing),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            summary.summary,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: summary.focusAreas
                .map(
                  (focus) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.radio_button_checked,
                            size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            focus,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CoachSessionCard extends StatelessWidget {
  const _CoachSessionCard({required this.session});

  final CoachSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeLabel = DateFormat('EEE, d MMM • HH:mm').format(session.scheduledAt);

    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Coach ${session.coachName}',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(timeLabel, style: theme.textTheme.bodySmall),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(session.mode, style: theme.textTheme.bodySmall),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            session.agenda ?? 'Agenda akan dikonfirmasi coach.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program});

  final LearningProgram program;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: program.accentColor.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: program.accentColor.withOpacity(0.1),
            child: Icon(Icons.auto_awesome_rounded, color: program.accentColor),
          ),
          const SizedBox(height: 12),
          Text(program.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(program.subtitle, style: theme.textTheme.bodySmall),
          const Spacer(),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: program.sellingPoints
                .map((point) => Chip(label: Text(point)))
                .toList(),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: () {}, child: const Text('Lihat detail')),
        ],
      ),
    );
  }
}

class _CommunityHighlightCard extends StatelessWidget {
  const _CommunityHighlightCard({required this.highlight});

  final CommunityHighlight highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Chip(
            label: Text(highlight.tag),
          ),
          const SizedBox(height: 10),
          Text(
            highlight.title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            highlight.description,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.chevron_right_rounded),
            label: const Text('Pelajari kisah lengkap'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.65),
          ),
        ),
      ],
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text('${value.toStringAsFixed(0)}', style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({this.error, required this.onRetry});

  final Object? error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_tethering_error_rounded, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat dashboard.',
              style: theme.textTheme.titleMedium,
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}
