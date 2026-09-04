import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/utils/date_format_es.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shared_widgets.dart';

enum _Period { thisWeek, lastWeek, lastMonth, custom }

class AvancesTab extends StatefulWidget {
  const AvancesTab({super.key, required this.patient});

  final UsersRecord patient;

  @override
  State<AvancesTab> createState() => _AvancesTabState();
}

class _AvancesData {
  const _AvancesData({
    required this.records,
    required this.behaviors,
    required this.tasks,
    required this.activities,
  });

  final List<RecordsRecord> records;
  final List<BehavioralRecordsRecord> behaviors;
  final List<TasksRecord> tasks;
  final List<ActivityAssignmentsRecord> activities;
}

class _AvancesTabState extends State<AvancesTab> {
  _Period _period = _Period.thisWeek;
  DateTimeRange? _customRange;
  late Future<_AvancesData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  // One-time fetches, not live `.snapshots()` listeners: `records`,
  // `behavioral_records` and `tasks` reads are gated by
  // `isAssignedPsychologist()`, a security rule that does a `get()` on the
  // patient's `users/{uid}` doc -- and that same doc gets written to (its
  // `lastActivityAt`) by a Cloud Function trigger every time one of those
  // is created. A live listener whose rule depends on a document that gets
  // rewritten moments later reliably shows the correct data for an
  // instant, then silently drops to empty with no error (see
  // registros_tab.dart for how this was confirmed). Refreshed manually
  // instead: on pull-to-refresh, and whenever the period filter changes.
  Future<_AvancesData> _load() async {
    final patientRef = widget.patient.reference;
    final results = await Future.wait([
      queryRecordsRecordOnce(
          queryBuilder: (q) => q.where('userRef', isEqualTo: patientRef)),
      queryBehavioralRecordsRecordOnce(
          queryBuilder: (q) => q.where('userRef', isEqualTo: patientRef)),
      queryTasksRecordOnce(
          queryBuilder: (q) => q.where('userRef', isEqualTo: patientRef)),
      queryActivityAssignmentsRecordOnce(
          queryBuilder: (q) => q.where('patientRef', isEqualTo: patientRef)),
    ]);
    return _AvancesData(
      records: results[0] as List<RecordsRecord>,
      behaviors: results[1] as List<BehavioralRecordsRecord>,
      tasks: results[2] as List<TasksRecord>,
      activities: results[3] as List<ActivityAssignmentsRecord>,
    );
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _future = future);
    await future;
  }

  DateTimeRange get _range {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_period) {
      case _Period.thisWeek:
        final start = today.subtract(Duration(days: today.weekday - 1));
        return DateTimeRange(start: start, end: today);
      case _Period.lastWeek:
        final startThisWeek = today.subtract(Duration(days: today.weekday - 1));
        final start = startThisWeek.subtract(const Duration(days: 7));
        final end = startThisWeek.subtract(const Duration(days: 1));
        return DateTimeRange(start: start, end: end);
      case _Period.lastMonth:
        return DateTimeRange(start: today.subtract(const Duration(days: 30)), end: today);
      case _Period.custom:
        return _customRange ??
            DateTimeRange(start: today.subtract(const Duration(days: 7)), end: today);
    }
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: _customRange,
    );
    if (picked != null) {
      setState(() {
        _customRange = picked;
        _period = _Period.custom;
      });
    }
  }

  bool _inRange(DateTime? date) {
    if (date == null) return false;
    final day = DateTime(date.year, date.month, date.day);
    final range = _range;
    final start = DateTime(range.start.year, range.start.month, range.start.day);
    final end = DateTime(range.end.year, range.end.month, range.end.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 24.0, 24.0),
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _PeriodChip(
                label: 'Esta semana',
                selected: _period == _Period.thisWeek,
                onTap: () => setState(() => _period = _Period.thisWeek),
              ),
              _PeriodChip(
                label: 'Semana anterior',
                selected: _period == _Period.lastWeek,
                onTap: () => setState(() => _period = _Period.lastWeek),
              ),
              _PeriodChip(
                label: 'Último mes',
                selected: _period == _Period.lastMonth,
                onTap: () => setState(() => _period = _Period.lastMonth),
              ),
              _PeriodChip(
                label: _period == _Period.custom && _customRange != null
                    ? '${formatDateEs(_customRange!.start)} – ${formatDateEs(_customRange!.end)}'
                    : 'Personalizado',
                selected: _period == _Period.custom,
                onTap: _pickCustomRange,
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          FutureBuilder<_AvancesData>(
            future: _future,
            builder: (context, snapshot) => asyncSection(
              snapshot,
              errorText: 'No se pudo cargar el avance del consultante.',
              (data) => _AvancesContent(
                records: data.records.where((r) => _inRange(r.timestamp)).toList(),
                behaviors:
                    data.behaviors.where((r) => _inRange(r.createdAt)).toList(),
                tasks: data.tasks
                    .where((t) => _inRange(t.assignedDate ?? t.createdTime))
                    .toList(),
                activities:
                    data.activities.where((a) => _inRange(a.assignedTime)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(14.0, 8.0, 14.0, 8.0),
        decoration: BoxDecoration(
          color: selected
              ? FlutterFlowTheme.of(context).primary10
              : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: selected
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate,
          ),
        ),
        child: Text(
          label,
          style: FlutterFlowTheme.of(context).labelMedium.override(
                font: GoogleFonts.outfit(),
                color: selected
                    ? FlutterFlowTheme.of(context).primary
                    : FlutterFlowTheme.of(context).primaryText,
                letterSpacing: 0.0,
              ),
        ),
      ),
    );
  }
}

class _AvancesContent extends StatelessWidget {
  const _AvancesContent({
    required this.records,
    required this.behaviors,
    required this.tasks,
    required this.activities,
  });

  final List<RecordsRecord> records;
  final List<BehavioralRecordsRecord> behaviors;
  final List<TasksRecord> tasks;
  final List<ActivityAssignmentsRecord> activities;

  @override
  Widget build(BuildContext context) {
    final avgIntensity = records.isEmpty
        ? 0.0
        : records.map((r) => r.intensity).reduce((a, b) => a + b) /
            records.length;

    final emotionCounts = <String, int>{};
    for (final r in records) {
      if (r.emotion.isEmpty) continue;
      emotionCounts[r.emotion] = (emotionCounts[r.emotion] ?? 0) + 1;
    }
    final sortedEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final behaviorCounts = <String, int>{};
    for (final b in behaviors) {
      if (b.behaviorType.isEmpty) continue;
      behaviorCounts[b.behaviorType] = (behaviorCounts[b.behaviorType] ?? 0) + 1;
    }
    final sortedBehaviors = behaviorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final completedTasks = tasks.where((t) => t.status == 'completada').length;
    final compliance =
        tasks.isEmpty ? null : (completedTasks / tasks.length * 100).round();

    final toolsUsed = activities.where((a) => a.status == 'completada').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            StatTile(
                label: 'Registros emocionales',
                value: '${records.length}',
                icon: Icons.mood_rounded),
            StatTile(
                label: 'Intensidad promedio',
                value: records.isEmpty ? '—' : avgIntensity.toStringAsFixed(1),
                icon: Icons.speed_rounded),
            StatTile(
                label: 'Registros de conducta',
                value: '${behaviors.length}',
                icon: Icons.checklist_rounded),
            StatTile(
                label: 'Cumplimiento de tareas',
                value: compliance == null ? '—' : '$compliance%',
                icon: Icons.task_alt_rounded),
            StatTile(
                label: 'Herramientas usadas',
                value: '$toolsUsed',
                icon: Icons.self_improvement_rounded),
          ],
        ),
        const SizedBox(height: 24.0),
        SectionTitle('Emociones registradas'),
        if (sortedEmotions.isEmpty)
          const EmptyHint('Sin registros emocionales en este período.')
        else
          _BarList(entries: sortedEmotions, color: FlutterFlowTheme.of(context).primary),
        const SizedBox(height: 24.0),
        SectionTitle('Conductas registradas'),
        if (sortedBehaviors.isEmpty)
          const EmptyHint('Sin registros de conducta en este período.')
        else
          _BarList(entries: sortedBehaviors, color: FlutterFlowTheme.of(context).warning),
      ],
    );
  }
}

class _BarList extends StatelessWidget {
  const _BarList({required this.entries, required this.color});

  final List<MapEntry<String, int>> entries;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxValue = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return Column(
      children: entries
          .map((entry) => Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 96.0,
                      child: Text(
                        entry.key,
                        overflow: TextOverflow.ellipsis,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.outfit(),
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 16.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).alternate,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: entry.value / maxValue,
                            child: Container(
                              height: 16.0,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      '${entry.value}',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
