import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/utils/date_format_es.dart';
import '/utils/error_messages.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shared_widgets.dart';

class _TimelineEvent {
  const _TimelineEvent(this.date, this.text);
  final DateTime date;
  final String text;
}

class _ResumenData {
  const _ResumenData({
    required this.lastSession,
    required this.lastRecord,
    required this.recordsThisWeek,
    required this.tasksAssigned,
    required this.tasksCompleted,
    required this.activitiesCompleted,
    required this.avgIntensityThisWeek,
    required this.avgIntensityLastWeek,
    required this.timeline,
    required this.note,
  });

  final SessionsRecord? lastSession;
  final RecordsRecord? lastRecord;
  final int recordsThisWeek;
  final int tasksAssigned;
  final int tasksCompleted;
  final int activitiesCompleted;
  final double? avgIntensityThisWeek;
  final double? avgIntensityLastWeek;
  final List<_TimelineEvent> timeline;
  final String note;
}

class ResumenTab extends StatefulWidget {
  const ResumenTab({super.key, required this.patient});

  final UsersRecord patient;

  @override
  State<ResumenTab> createState() => _ResumenTabState();
}

class _ResumenTabState extends State<ResumenTab> {
  late Future<_ResumenData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  DocumentReference get _noteRef =>
      FirebaseFirestore.instance.collection('patient_notes').doc(widget.patient.reference.id);

  Future<_ResumenData> _load() async {
    final patientRef = widget.patient.reference;
    final myRef = currentUserReference;
    final now = DateTime.now();
    final startOfWeek =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek = startOfWeek.subtract(const Duration(days: 7));

    final sessionsSnap = await SessionsRecord.collection
        .where('patientRef', isEqualTo: patientRef)
        .where('psychologistRef', isEqualTo: myRef)
        .get();
    final sessions =
        sessionsSnap.docs.map((d) => SessionsRecord.fromSnapshot(d)).toList()
          ..sort((a, b) =>
              (b.sessionDate ?? DateTime(2000)).compareTo(a.sessionDate ?? DateTime(2000)));

    final recordsSnap =
        await RecordsRecord.collection.where('userRef', isEqualTo: patientRef).get();
    final records = recordsSnap.docs.map((d) => RecordsRecord.fromSnapshot(d)).toList()
      ..sort((a, b) => (b.timestamp ?? DateTime(2000)).compareTo(a.timestamp ?? DateTime(2000)));

    final behavioralSnap = await BehavioralRecordsRecord.collection
        .where('userRef', isEqualTo: patientRef)
        .get();
    final behaviors =
        behavioralSnap.docs.map((d) => BehavioralRecordsRecord.fromSnapshot(d)).toList();

    final tasksSnap =
        await TasksRecord.collection.where('userRef', isEqualTo: patientRef).get();
    final tasks = tasksSnap.docs.map((d) => TasksRecord.fromSnapshot(d)).toList();

    final activitiesSnap = await ActivityAssignmentsRecord.collection
        .where('patientRef', isEqualTo: patientRef)
        .where('psychologistRef', isEqualTo: myRef)
        .get();
    final activityAssignments = activitiesSnap.docs
        .map((d) => ActivityAssignmentsRecord.fromSnapshot(d))
        .toList();

    final noteSnap = await _noteRef.get();
    final note = (noteSnap.data() as Map<String, dynamic>?)?['notes'] as String? ?? '';

    final recordsThisWeek =
        records.where((r) => (r.timestamp ?? DateTime(2000)).isAfter(startOfWeek)).toList();
    final recordsLastWeek = records
        .where((r) =>
            (r.timestamp ?? DateTime(2000)).isAfter(startOfLastWeek) &&
            (r.timestamp ?? DateTime(2000)).isBefore(startOfWeek))
        .toList();
    final avgThisWeek = recordsThisWeek.isEmpty
        ? null
        : recordsThisWeek.map((r) => r.intensity).reduce((a, b) => a + b) /
            recordsThisWeek.length;
    final avgLastWeek = recordsLastWeek.isEmpty
        ? null
        : recordsLastWeek.map((r) => r.intensity).reduce((a, b) => a + b) /
            recordsLastWeek.length;

    final tasksAssignedByMe =
        tasks.where((t) => t.createdByRef?.id == myRef?.id).toList();

    final timeline = <_TimelineEvent>[
      for (final s in sessions)
        if (s.sessionDate != null)
          _TimelineEvent(s.sessionDate!, 'Sesión N.º ${s.sessionNumber} realizada'),
      for (final t in tasksAssignedByMe)
        if (t.assignedDate != null)
          _TimelineEvent(t.assignedDate!, 'Tarea asignada: ${t.title}'),
      for (final t in tasks)
        if (t.completedTime != null)
          _TimelineEvent(t.completedTime!, 'Tarea completada: ${t.title}'),
      for (final r in records)
        if (r.timestamp != null)
          _TimelineEvent(r.timestamp!, 'Registro emocional realizado'),
      for (final b in behaviors)
        if (b.createdAt != null)
          _TimelineEvent(b.createdAt!, 'Registro de conducta realizado'),
      for (final a in activityAssignments)
        if (a.completedAt != null)
          _TimelineEvent(a.completedAt!, 'Realizó actividad: ${a.activityName}'),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return _ResumenData(
      lastSession: sessions.isEmpty ? null : sessions.first,
      lastRecord: records.isEmpty ? null : records.first,
      recordsThisWeek: recordsThisWeek.length,
      tasksAssigned: tasksAssignedByMe.length,
      tasksCompleted: tasksAssignedByMe.where((t) => t.status == 'completada').length,
      activitiesCompleted:
          activityAssignments.where((a) => a.status == 'completada').length,
      avgIntensityThisWeek: avgThisWeek,
      avgIntensityLastWeek: avgLastWeek,
      timeline: timeline.take(8).toList(),
      note: note,
    );
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _future = future);
    await future;
  }

  Future<void> _editNote(String current) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Observaciones importantes'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 4,
          maxLines: 8,
          maxLength: 2000,
          decoration: const InputDecoration(
            hintText: 'Notas privadas sobre este consultante...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (result != true || !mounted) return;
    try {
      await _noteRef.set({'notes': controller.text.trim()}, SetOptions(merge: true));
      _refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(genericSaveErrorMessage('guardar la observación'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<_ResumenData>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final theme = FlutterFlowTheme.of(context);
          return ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 24.0, 24.0),
            children: [
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: [
                  StatTile(
                    label: 'Última sesión',
                    value: data.lastSession?.sessionDate != null
                        ? formatDateEs(data.lastSession!.sessionDate!)
                        : 'Sin sesiones',
                    icon: Icons.event_note_rounded,
                  ),
                  StatTile(
                    label: 'Último registro emocional',
                    value: data.lastRecord?.timestamp != null
                        ? formatDateEs(data.lastRecord!.timestamp!)
                        : 'Sin registros',
                    icon: Icons.mood_rounded,
                  ),
                  StatTile(
                    label: 'Registros esta semana',
                    value: '${data.recordsThisWeek}',
                    icon: Icons.calendar_view_week_rounded,
                  ),
                  StatTile(
                    label: 'Tareas asignadas',
                    value: '${data.tasksAssigned}',
                    icon: Icons.assignment_rounded,
                  ),
                  StatTile(
                    label: 'Tareas completadas',
                    value: '${data.tasksCompleted}',
                    icon: Icons.task_alt_rounded,
                  ),
                  StatTile(
                    label: 'Actividades realizadas',
                    value: '${data.activitiesCompleted}',
                    icon: Icons.self_improvement_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              SectionTitle('Evolución semanal'),
              Container(
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: Text(_evolutionText(data), style: theme.bodyMedium.override(
                  font: GoogleFonts.outfit(),
                  color: theme.primaryText,
                  letterSpacing: 0.0,
                )),
              ),
              const SizedBox(height: 24.0),
              SectionTitle(
                'Observaciones importantes',
                trailing: TextButton(
                  onPressed: () => _editNote(data.note),
                  child: Text(data.note.isEmpty ? 'Agregar' : 'Editar'),
                ),
              ),
              if (data.note.isEmpty)
                const EmptyHint('Aún no has dejado observaciones sobre este consultante.')
              else
                Container(
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Text(data.note),
                ),
              const SizedBox(height: 24.0),
              SectionTitle('Historial reciente'),
              if (data.timeline.isEmpty)
                const EmptyHint('Todavía no hay actividad registrada.')
              else
                ...data.timeline.map((event) => Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatDateEs(event.date),
                            style: theme.bodySmall.override(
                              font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                              color: theme.secondaryText,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              event.text,
                              style: theme.bodySmall.override(
                                font: GoogleFonts.outfit(),
                                color: theme.primaryText,
                                letterSpacing: 0.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }

  String _evolutionText(_ResumenData data) {
    if (data.avgIntensityThisWeek == null) {
      return 'Sin registros emocionales esta semana todavía.';
    }
    final thisWeek = data.avgIntensityThisWeek!.toStringAsFixed(1);
    if (data.avgIntensityLastWeek == null) {
      return 'Intensidad promedio esta semana: $thisWeek/10 (sin datos de la semana anterior para comparar).';
    }
    final diff = data.avgIntensityThisWeek! - data.avgIntensityLastWeek!;
    final trend = diff.abs() < 0.3
        ? 'similar a'
        : (diff > 0 ? 'más alta que' : 'más baja que');
    return 'Intensidad promedio esta semana: $thisWeek/10 — $trend la semana anterior '
        '(${data.avgIntensityLastWeek!.toStringAsFixed(1)}/10).';
  }
}
