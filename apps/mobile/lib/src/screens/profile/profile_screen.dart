import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../data/home_repository.dart';
import '../../models/home_overview.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
                    Text('Gagal memuat profil santri', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _refresh, child: const Text('Coba Lagi')),
                  ],
                ),
              );
            }

            final overview = snapshot.data!;
            final profile = overview.profile;
            final dateFormat = DateFormat('d MMM yyyy');

            return RefreshIndicator(
              onRefresh: _refresh,
              color: theme.colorScheme.primary,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  Text('Profil Santri', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                              child: Text(
                                profile.name.substring(0, 1),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(profile.name,
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                Text(profile.level, style: theme.textTheme.bodySmall),
                                Text('Zona waktu ${profile.timezone}', style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Tujuan utama', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(profile.primaryGoal, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: [
                            _StatTile(label: 'Streak', value: '${profile.streakDays} hari'),
                            _StatTile(label: 'Sesi selesai', value: '${profile.completedSessions}x'),
                            _StatTile(
                              label: 'Check-in berikutnya',
                              value: dateFormat.format(profile.nextCheckIn),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Highlight Perjalanan', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _JourneyInsightCard(overview: overview),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _JourneyInsightCard extends StatelessWidget {
  const _JourneyInsightCard({required this.overview});

  final HomeOverview overview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Program aktif', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 6),
          Text(overview.journey.program.title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(overview.journey.focusStatement, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          Text('Sorotan assessment terakhir', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(overview.assessment.summary, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: overview.assessment.focusAreas
                .map((focus) => Chip(label: Text(focus)))
                .toList(),
          ),
        ],
      ),
    );
  }
}
