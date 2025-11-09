import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../data/home_repository.dart';
import '../../models/home_overview.dart';
import '../../models/journey.dart';
import '../../models/learning_program.dart';

class BelajarScreen extends StatefulWidget {
  const BelajarScreen({super.key});

  @override
  State<BelajarScreen> createState() => _BelajarScreenState();
}

class _BelajarScreenState extends State<BelajarScreen> {
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Tidak dapat memuat rencana belajar', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _refresh, child: const Text('Coba Lagi')),
                  ],
                ),
              );
            }

            final overview = snapshot.data!;
            final program = overview.journey.program;

            return RefreshIndicator(
              onRefresh: _refresh,
              color: theme.colorScheme.primary,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _Header(program: program, journey: overview.journey),
                  const SizedBox(height: 24),
                  if (overview.journey.activeModule != null)
                    _ActiveModuleCard(module: overview.journey.activeModule!),
                  const SizedBox(height: 28),
                  Text('Struktur Program', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...program.modules.map((module) => _ModuleTile(module: module)).toList(),
                  const SizedBox(height: 32),
                  Text('Rencana Misi', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ..._groupMissions(overview.journey.todayMissions).entries.map(
                    (entry) => _MissionGroup(
                      title: entry.key,
                      missions: entry.value,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Map<String, List<DailyMission>> _groupMissions(List<DailyMission> missions) {
    final groups = <String, List<DailyMission>>{};
    for (final mission in missions) {
      late final String label;
      switch (mission.type) {
        case MissionType.aiPractice:
          label = 'Latihan AI Adaptif';
          break;
        case MissionType.liveSession:
          label = 'Sesi bersama Coach';
          break;
        case MissionType.reflection:
          label = 'Refleksi & Catatan';
          break;
      }
      groups.putIfAbsent(label, () => []).add(mission);
    }
    return groups;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.program, required this.journey});

  final LearningProgram program;
  final LearningJourney journey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.compact();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [program.accentColor.withOpacity(0.95), program.accentColor.withOpacity(0.65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(program.title,
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text(program.subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progress', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: journey.completionPercent / 100,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      color: Colors.amberAccent,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${journey.completionPercent.toStringAsFixed(0)}%',
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  Text('${program.estimatedWeeks} pekan',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _HeaderChip(icon: Icons.auto_awesome, label: program.level),
              _HeaderChip(icon: Icons.people_alt_rounded, label: '${formatter.format(32)} santri batch ini'),
              _HeaderChip(icon: Icons.schedule, label: 'Assessment ${DateFormat('d MMM').format(journey.nextAssessment)}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

class _ActiveModuleCard extends StatelessWidget {
  const _ActiveModuleCard({required this.module});

  final ProgramModule module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.layers_rounded, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Text('Modul aktif sekarang', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(module.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(module.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _DetailTag(icon: Icons.menu_book_rounded, label: module.focusSurah),
              _DetailTag(icon: Icons.my_library_books_rounded, label: 'Ayat ${module.ayahRange}'),
              _DetailTag(icon: Icons.timer_rounded, label: '${module.estimatedMinutes} menit'),
            ],
          ),
          const SizedBox(height: 16),
          Text('Outcome yang ditargetkan', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...module.outcomes.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item, style: theme.textTheme.bodySmall)),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          FilledButton.tonal(onPressed: () {}, child: const Text('Lihat bahan ajar lengkap')),
        ],
      ),
    );
  }
}

class _DetailTag extends StatelessWidget {
  const _DetailTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.module});

  final ProgramModule module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Text('${module.order}', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(module.description, style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Chip(label: Text('Fokus ${module.focusSurah}')), 
                    Chip(label: Text('Target ${module.estimatedMinutes} menit/sesi')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionGroup extends StatelessWidget {
  const _MissionGroup({required this.title, required this.missions});

  final String title;
  final List<DailyMission> missions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...missions.map((mission) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.play_circle_fill_rounded, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mission.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              Text('Jam ${timeFormat.format(mission.scheduledFor)}', style: theme.textTheme.bodySmall),
                              if (mission.surah != null)
                                Text('${mission.surah} ${mission.ayahRange}', style: theme.textTheme.bodySmall),
                              Text('${mission.durationMinutes} menit', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
