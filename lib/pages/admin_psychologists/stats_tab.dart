import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _AdminStats {
  const _AdminStats({
    required this.totalPatients,
    required this.totalPsychologists,
    required this.activePatientsThisWeek,
    required this.deactivatedAccounts,
    required this.emotionalRecordsCount,
    required this.behavioralRecordsCount,
    required this.tasksAssigned,
    required this.tasksCompleted,
    required this.topActivities,
  });

  final int totalPatients;
  final int totalPsychologists;
  final int activePatientsThisWeek;
  final int deactivatedAccounts;
  final int emotionalRecordsCount;
  final int behavioralRecordsCount;
  final int tasksAssigned;
  final int tasksCompleted;
  final List<MapEntry<String, int>> topActivities;
}

/// Admin-only usage stats. Deliberately never touches `sessions` or
/// `patient_notes` -- those stay 100% private to each psychologist, even
/// from the admin (see firestore.rules). Everything here is one-shot
/// (`.get()`/`.count()`), not live, with pull-to-refresh -- these are
/// summary numbers, not something that needs to update in real time.
class AdminStatsTab extends StatefulWidget {
  const AdminStatsTab({super.key});

  @override
  State<AdminStatsTab> createState() => _AdminStatsTabState();
}

class _AdminStatsTabState extends State<AdminStatsTab> {
  late Future<_AdminStats> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_AdminStats> _load() async {
    final usersSnap = await UsersRecord.collection
        .where('role', whereIn: ['paciente', 'psicologo'])
        .get();
    final users = usersSnap.docs.map((d) => UsersRecord.fromSnapshot(d)).toList();
    final patients = users.where((u) => u.role == 'paciente').toList();
    final psychologists = users.where((u) => u.role == 'psicologo').toList();
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final activePatientsThisWeek = patients
        .where((p) => p.hasLastActivityAt() && p.lastActivityAt!.isAfter(weekAgo))
        .length;
    final deactivatedAccounts = users.where((u) => !u.active).length;

    final recordsCount =
        (await RecordsRecord.collection.count().get()).count ?? 0;
    final behavioralCount =
        (await BehavioralRecordsRecord.collection.count().get()).count ?? 0;

    final tasksSnap = await TasksRecord.collection.get();
    final tasks = tasksSnap.docs.map((d) => TasksRecord.fromSnapshot(d)).toList();
    final assignedTasks =
        tasks.where((t) => t.createdByRef?.id != t.userRef?.id).toList();
    final completedAssignedTasks =
        assignedTasks.where((t) => t.status == 'completada').length;

    final activitiesSnap = await ActivityAssignmentsRecord.collection.get();
    final activityCounts = <String, int>{};
    for (final doc in activitiesSnap.docs) {
      final assignment = ActivityAssignmentsRecord.fromSnapshot(doc);
      if (assignment.activityName.isEmpty) continue;
      activityCounts[assignment.activityName] =
          (activityCounts[assignment.activityName] ?? 0) + 1;
    }
    final topActivities = activityCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _AdminStats(
      totalPatients: patients.length,
      totalPsychologists: psychologists.length,
      activePatientsThisWeek: activePatientsThisWeek,
      deactivatedAccounts: deactivatedAccounts,
      emotionalRecordsCount: recordsCount,
      behavioralRecordsCount: behavioralCount,
      tasksAssigned: assignedTasks.length,
      tasksCompleted: completedAssignedTasks,
      topActivities: topActivities.take(5).toList(),
    );
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<_AdminStats>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No se pudieron cargar las estadísticas.'),
                ),
              ],
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = snapshot.data!;
          final theme = FlutterFlowTheme.of(context);
          final compliance = stats.tasksAssigned == 0
              ? null
              : (stats.tasksCompleted / stats.tasksAssigned * 100).round();

          return ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 24.0, 24.0),
            children: [
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: [
                  _StatCard(label: 'Consultantes registrados', value: '${stats.totalPatients}'),
                  _StatCard(label: 'Psicólogos registrados', value: '${stats.totalPsychologists}'),
                  _StatCard(
                      label: 'Consultantes activos (7 días)',
                      value: '${stats.activePatientsThisWeek}'),
                  _StatCard(label: 'Cuentas desactivadas', value: '${stats.deactivatedAccounts}'),
                  _StatCard(
                      label: 'Registros emocionales', value: '${stats.emotionalRecordsCount}'),
                  _StatCard(
                      label: 'Registros de conducta', value: '${stats.behavioralRecordsCount}'),
                  _StatCard(label: 'Tareas asignadas', value: '${stats.tasksAssigned}'),
                  _StatCard(
                      label: 'Cumplimiento de tareas',
                      value: compliance == null ? '—' : '$compliance%'),
                ],
              ),
              const SizedBox(height: 24.0),
              Text(
                'Actividades más utilizadas',
                style: theme.titleSmall.override(
                  font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  color: theme.primaryText,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              if (stats.topActivities.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'Aún no se han asignado actividades.',
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.outfit(),
                      color: theme.secondaryText,
                      letterSpacing: 0.0,
                    ),
                  ),
                )
              else
                ...stats.topActivities.map((entry) => Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14.0, vertical: 10.0),
                        child: Row(
                          children: [
                            Expanded(child: Text(entry.key)),
                            Text(
                              '${entry.value}',
                              style: theme.bodyMedium.override(
                                font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                color: theme.primaryText,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 150.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: theme.headlineSmall.override(
              font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              color: theme.primaryText,
              letterSpacing: 0.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.bodySmall.override(
              font: GoogleFonts.outfit(),
              color: theme.secondaryText,
              letterSpacing: 0.0,
            ),
          ),
        ],
      ),
    );
  }
}
