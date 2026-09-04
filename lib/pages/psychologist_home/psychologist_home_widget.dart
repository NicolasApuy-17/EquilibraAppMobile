import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/utils/date_format_es.dart';
import '/utils/error_logging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Emotional records at or above this intensity (out of 10) during the last
/// 7 days show up as dashboard alerts.
const kIntensityAlertThreshold = 8.0;

/// Runs one query per patient in parallel and flattens the results. A
/// single-value `==` query per patient, rather than one `whereIn` query
/// across all of them -- see the comment at its call site for why. Any one
/// patient's query failing is logged and treated as "no documents for that
/// patient" rather than failing the whole dashboard.
Future<List<T>> _fetchPerPatient<T>(
  List<DocumentReference> patientRefs,
  Future<QuerySnapshot> Function(DocumentReference ref) query,
  T Function(DocumentSnapshot) fromSnapshot, {
  required String context,
}) async {
  final results = await Future.wait(patientRefs.map((ref) async {
    try {
      final snap = await query(ref);
      return snap.docs.map(fromSnapshot).toList();
    } catch (e, stackTrace) {
      logAppError(context: '$context (${ref.id})', error: e, stackTrace: stackTrace);
      return <T>[];
    }
  }));
  return results.expand((list) => list).toList();
}

/// One recent emotional record, kept together with the patient it belongs
/// to so the dashboard can show "Ana · Tristeza · 8/10" without a second
/// lookup per card.
class _PatientRecord {
  const _PatientRecord({required this.patient, required this.record});
  final UsersRecord patient;
  final RecordsRecord record;
}

/// A patient's next scheduled session, from their most recently logged
/// `SessionsRecord.nextSessionDate` (only kept when it's still upcoming).
class _UpcomingSession {
  const _UpcomingSession({required this.patient, required this.date});
  final UsersRecord patient;
  final DateTime date;
}

class _DashboardData {
  const _DashboardData({
    required this.patients,
    required this.patientsWithRecordThisWeek,
    required this.recentRecords,
    required this.alerts,
    required this.pendingTasksByPatient,
    required this.recentlyCompletedTasks,
    required this.upcomingSessions,
  });

  final List<UsersRecord> patients;
  final int patientsWithRecordThisWeek;
  final List<_PatientRecord> recentRecords;
  final List<_PatientRecord> alerts;
  final Map<String, int> pendingTasksByPatient;
  final List<TasksRecord> recentlyCompletedTasks;
  final List<_UpcomingSession> upcomingSessions;

  int get totalPendingTasks =>
      pendingTasksByPatient.values.fold(0, (a, b) => a + b);
}

/// Landing screen for a signed-in user with `role == 'psicologo'`: a
/// dashboard with caseload metrics/alerts, and "Mis consultantes" below it
/// with search. Reached either right after login or, if the app is
/// reopened already authenticated, via the role redirect in
/// `HomeScreenWidget`.
class PsychologistHomeWidget extends StatefulWidget {
  const PsychologistHomeWidget({super.key});

  static String routeName = 'PsychologistHome';
  static String routePath = '/psychologistHome';

  @override
  State<PsychologistHomeWidget> createState() =>
      _PsychologistHomeWidgetState();
}

class _PsychologistHomeWidgetState extends State<PsychologistHomeWidget> {
  final _searchController = TextEditingController();
  String _query = '';
  late Future<_DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const _emptyDashboard = _DashboardData(
    patients: [],
    patientsWithRecordThisWeek: 0,
    recentRecords: [],
    alerts: [],
    pendingTasksByPatient: {},
    recentlyCompletedTasks: [],
    upcomingSessions: [],
  );

  /// Never throws -- always resolves to *some* `_DashboardData`, even if a
  /// sub-query fails, so a single broken collection can't leave the whole
  /// dashboard (or, before this fix, the "Mis consultantes" section below
  /// it) stuck on a spinner forever. The patient list itself comes from an
  /// independent `StreamBuilder` and never depended on this future, but the
  /// per-card "tareas pendientes"/"próxima sesión" fields do.
  Future<_DashboardData> _loadDashboard() async {
    try {
      return await _loadDashboardOrThrow();
    } catch (e, stackTrace) {
      logAppError(
        context: 'PsychologistHomeWidget._loadDashboard',
        error: e,
        stackTrace: stackTrace,
      );
      return _emptyDashboard;
    }
  }

  Future<_DashboardData> _loadDashboardOrThrow() async {
    final myRef = currentUserReference;
    if (myRef == null) return _emptyDashboard;

    final patientsSnap = await UsersRecord.collection
        .where('role', isEqualTo: 'paciente')
        .where('psychologistRef', isEqualTo: myRef)
        .get();
    final patients =
        patientsSnap.docs.map((d) => UsersRecord.fromSnapshot(d)).toList();
    final patientsById = {for (final p in patients) p.reference.id: p};
    final patientRefs = patients.map((p) => p.reference).toList();

    if (patientRefs.isEmpty) return _emptyDashboard;

    // One query *per patient*, not a single `userRef whereIn patientRefs`
    // query: Firestore security rules aren't a post-hoc filter -- a query
    // is only allowed if Firestore can prove every document it could
    // possibly return satisfies the rule, and it can't prove that for a
    // multi-value `whereIn` when the rule needs a `get()` (like
    // `isAssignedPsychologist` does here) to decide each document. A
    // single-value `==` query it *can* prove, which is exactly what the
    // per-patient detail tabs already do successfully. Each collection's
    // fetch is wrapped so one patient's (or one collection's) failure
    // doesn't blank out data that did load correctly.
    final records = await _fetchPerPatient(
      patientRefs,
      (ref) => RecordsRecord.collection.where('userRef', isEqualTo: ref).get(),
      RecordsRecord.fromSnapshot,
      context: 'dashboard records',
    );
    final behavioralRecords = await _fetchPerPatient(
      patientRefs,
      (ref) =>
          BehavioralRecordsRecord.collection.where('userRef', isEqualTo: ref).get(),
      BehavioralRecordsRecord.fromSnapshot,
      context: 'dashboard behavioral records',
    );
    final tasks = await _fetchPerPatient(
      patientRefs,
      (ref) => TasksRecord.collection.where('userRef', isEqualTo: ref).get(),
      TasksRecord.fromSnapshot,
      context: 'dashboard tasks',
    );
    // `sessions` reads are rules-gated on `psychologistRef == me` alone (see
    // firestore.rules) -- a single equality filter both satisfies the rule
    // (Firestore *can* prove it) and already scopes this to every session
    // across all of this psychologist's patients, so no per-patient split
    // is needed here.
    List<SessionsRecord> sessions;
    try {
      final sessionsSnap = await SessionsRecord.collection
          .where('psychologistRef', isEqualTo: myRef)
          .get();
      sessions = sessionsSnap.docs.map((d) => SessionsRecord.fromSnapshot(d)).toList();
    } catch (e, stackTrace) {
      logAppError(context: 'dashboard sessions', error: e, stackTrace: stackTrace);
      sessions = [];
    }

    final weekAgo = DateTime.now().subtract(const Duration(days: 7));

    final recordsThisWeek =
        records.where((r) => (r.timestamp ?? DateTime(2000)).isAfter(weekAgo));
    final behavioralThisWeek = behavioralRecords
        .where((r) => (r.createdAt ?? DateTime(2000)).isAfter(weekAgo));
    final patientsWithRecordThisWeek = <String>{
      for (final r in recordsThisWeek) r.userRef?.id ?? '',
      for (final r in behavioralThisWeek) r.userRef?.id ?? '',
    }..remove('');

    final sortedRecords = [...records]
      ..sort((a, b) =>
          (b.timestamp ?? DateTime(2000)).compareTo(a.timestamp ?? DateTime(2000)));
    final recentRecords = sortedRecords
        .take(5)
        .where((r) => patientsById.containsKey(r.userRef?.id))
        .map((r) => _PatientRecord(
              patient: patientsById[r.userRef!.id]!,
              record: r,
            ))
        .toList();

    final alerts = recordsThisWeek
        .where((r) =>
            r.intensity >= kIntensityAlertThreshold &&
            patientsById.containsKey(r.userRef?.id))
        .map((r) => _PatientRecord(
              patient: patientsById[r.userRef!.id]!,
              record: r,
            ))
        .toList()
      ..sort((a, b) => (b.record.timestamp ?? DateTime(2000))
          .compareTo(a.record.timestamp ?? DateTime(2000)));

    final pendingTasksByPatient = <String, int>{};
    for (final task in tasks) {
      final id = task.userRef?.id;
      if (id == null || task.status == 'completada') continue;
      pendingTasksByPatient[id] = (pendingTasksByPatient[id] ?? 0) + 1;
    }

    final recentlyCompletedTasks = tasks.where((t) => t.status == 'completada').toList()
      ..sort((a, b) => (b.completedTime ?? b.createdTime ?? DateTime(2000))
          .compareTo(a.completedTime ?? a.createdTime ?? DateTime(2000)));

    // For each patient, their most recent session's `nextSessionDate` (if
    // still upcoming) is what shows up here -- an older session's next-date
    // gets superseded once a newer session is logged.
    final nowForSessions = DateTime.now();
    final todayDateOnly =
        DateTime(nowForSessions.year, nowForSessions.month, nowForSessions.day);
    final sessionsByPatient = <String, List<SessionsRecord>>{};
    for (final session in sessions) {
      final id = session.patientRef?.id;
      if (id == null) continue;
      (sessionsByPatient[id] ??= []).add(session);
    }
    final upcomingSessions = <_UpcomingSession>[];
    sessionsByPatient.forEach((patientId, patientSessions) {
      patientSessions.sort((a, b) =>
          (b.sessionDate ?? DateTime(2000)).compareTo(a.sessionDate ?? DateTime(2000)));
      final nextDate = patientSessions.first.nextSessionDate;
      final patient = patientsById[patientId];
      if (nextDate != null && patient != null && !nextDate.isBefore(todayDateOnly)) {
        upcomingSessions.add(_UpcomingSession(patient: patient, date: nextDate));
      }
    });
    upcomingSessions.sort((a, b) => a.date.compareTo(b.date));

    return _DashboardData(
      patients: patients,
      patientsWithRecordThisWeek: patientsWithRecordThisWeek.length,
      recentRecords: recentRecords,
      alerts: alerts,
      pendingTasksByPatient: pendingTasksByPatient,
      recentlyCompletedTasks: recentlyCompletedTasks.take(5).toList(),
      upcomingSessions: upcomingSessions.take(5).toList(),
    );
  }

  Future<void> _refresh() async {
    final data = _loadDashboard();
    setState(() => _dashboardFuture = data);
    await data;
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text('¿Deseas salir de tu cuenta?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;

    GoRouter.of(context).prepareAuthEvent();
    await authManager.signOut();
    if (!context.mounted) return;
    GoRouter.of(context).clearRedirectLocation();
    context.goNamedAuth(TestScreenWidget.routeName, context.mounted);
  }

  @override
  Widget build(BuildContext context) {
    final myRef = currentUserReference;

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      currentUserDisplayName.isEmpty
                          ? 'Panel del psicólogo'
                          : 'Hola, ${currentUserDisplayName.split(' ').first}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            font:
                                GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: _confirmSignOut,
                    icon: Icon(
                      Icons.logout_rounded,
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: myRef == null
                  ? const SizedBox.shrink()
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            24.0, 0.0, 24.0, 24.0),
                        children: [
                          FutureBuilder<_DashboardData>(
                            future: _dashboardFuture,
                            builder: (context, snapshot) {
                              // `_loadDashboard` never completes with an
                              // error (it catches everything internally),
                              // but this still guards against an eternal
                              // spinner if that ever stops being true.
                              if (snapshot.connectionState == ConnectionState.done &&
                                  !snapshot.hasData) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: Text(
                                    'No se pudo cargar el resumen. Desliza hacia abajo para reintentar.',
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.outfit(),
                                          color: FlutterFlowTheme.of(context).error,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                );
                              }
                              if (!snapshot.hasData) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32.0),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              }
                              return _DashboardSection(data: snapshot.data!);
                            },
                          ),
                          const SizedBox(height: 24.0),
                          Text(
                            'Mis consultantes',
                            style: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold),
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12.0),
                          TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(
                                () => _query = value.trim().toLowerCase()),
                            decoration: InputDecoration(
                              hintText: 'Buscar consultante por nombre...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              filled: true,
                              fillColor:
                                  FlutterFlowTheme.of(context).secondaryBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          StreamBuilder<List<UsersRecord>>(
                            stream: queryUsersRecord(
                              queryBuilder: (usersRecord) => usersRecord
                                  .where('role', isEqualTo: 'paciente')
                                  .where('psychologistRef', isEqualTo: myRef),
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text(
                                  'No se pudieron cargar tus consultantes.',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.outfit(),
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        letterSpacing: 0.0,
                                      ),
                                );
                              }
                              if (!snapshot.hasData) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24.0),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              }
                              final patients = snapshot.data!.where((p) {
                                if (_query.isEmpty) return true;
                                return p.displayName
                                        .toLowerCase()
                                        .contains(_query) ||
                                    p.email.toLowerCase().contains(_query);
                              }).toList();
                              if (patients.isEmpty) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 24.0),
                                  child: Text(
                                    snapshot.data!.isEmpty
                                        ? 'Aún no tienes consultantes vinculados.'
                                        : 'No se encontraron consultantes.',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.outfit(),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                );
                              }
                              return FutureBuilder<_DashboardData>(
                                future: _dashboardFuture,
                                builder: (context, dashboardSnapshot) {
                                  final pendingByPatient = dashboardSnapshot
                                          .data?.pendingTasksByPatient ??
                                      const <String, int>{};
                                  final nextSessionByPatient = {
                                    for (final upcoming in dashboardSnapshot
                                            .data?.upcomingSessions ??
                                        const <_UpcomingSession>[])
                                      upcoming.patient.reference.id: upcoming.date,
                                  };
                                  return Column(
                                    children: patients
                                        .map((patient) => _PatientCard(
                                              patient: patient,
                                              pendingTasks: pendingByPatient[
                                                      patient.reference.id] ??
                                                  0,
                                              nextSessionDate: nextSessionByPatient[
                                                  patient.reference.id],
                                            ))
                                        .toList(),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({required this.data});

  final _DashboardData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'Consultantes activos',
                value: '${data.patients.length}',
                icon: Icons.groups_rounded,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _StatTile(
                label: 'Con registro esta semana',
                value: '${data.patientsWithRecordThisWeek}',
                icon: Icons.event_available_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'Tareas pendientes',
                value: '${data.totalPendingTasks}',
                icon: Icons.pending_actions_rounded,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _StatTile(
                label: 'Alertas (7 días)',
                value: '${data.alerts.length}',
                icon: Icons.warning_amber_rounded,
                highlight: data.alerts.isNotEmpty,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24.0),
        if (data.alerts.isNotEmpty) ...[
          _DashboardCard(
            title: 'Alertas importantes',
            icon: Icons.warning_amber_rounded,
            iconColor: FlutterFlowTheme.of(context).error,
            children: data.alerts.map((entry) => _AlertRow(entry: entry)).toList(),
          ),
          const SizedBox(height: 16.0),
        ],
        _DashboardCard(
          title: 'Registros emocionales recientes',
          icon: Icons.mood_rounded,
          emptyText: 'Sin registros emocionales recientes.',
          children:
              data.recentRecords.map((entry) => _RecentRecordRow(entry: entry)).toList(),
        ),
        const SizedBox(height: 16.0),
        _DashboardCard(
          title: 'Tareas cumplidas recientemente',
          icon: Icons.task_alt_rounded,
          emptyText: 'Sin tareas cumplidas todavía.',
          children: data.recentlyCompletedTasks
              .map((task) => _SimpleRow(title: task.title, subtitle: 'Cumplida'))
              .toList(),
        ),
        const SizedBox(height: 16.0),
        _DashboardCard(
          title: 'Próximas sesiones',
          icon: Icons.event_rounded,
          emptyText: 'No tienes próximas sesiones programadas.',
          children: data.upcomingSessions
              .map((upcoming) => _SimpleRow(
                    title: upcoming.patient.displayName.isEmpty
                        ? upcoming.patient.email
                        : upcoming.patient.displayName,
                    subtitle: formatDateEs(upcoming.date),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

/// Groups one dashboard section (a title with an icon, plus its rows) into
/// a single visually distinct surface, so the dashboard reads as a set of
/// organized cards rather than one long flat list of text.
class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.children,
    this.iconColor,
    this.emptyText,
  });

  final String title;
  final IconData icon;
  final Color? iconColor;
  final String? emptyText;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.0, color: iconColor ?? theme.primary),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  title,
                  style: theme.titleSmall.override(
                    font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    color: theme.primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          if (children.isEmpty)
            Text(
              emptyText ?? 'Nada por aquí todavía.',
              style: theme.bodySmall.override(
                font: GoogleFonts.outfit(),
                color: theme.secondaryText,
                letterSpacing: 0.0,
              ),
            )
          else
            ...children,
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: highlight
            ? theme.error.withValues(alpha: 0.08)
            : theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: highlight ? Border.all(color: theme.error.withValues(alpha: 0.3)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: highlight ? theme.error : theme.primary, size: 22.0),
          const SizedBox(height: 8.0),
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

class _SimpleRow extends StatelessWidget {
  const _SimpleRow({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(14.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title.isEmpty ? 'Sin título' : title,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.outfit(),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            Text(
              subtitle,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.outfit(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.entry});
  final _PatientRecord entry;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final name = entry.patient.displayName.isEmpty
        ? entry.patient.email
        : entry.patient.displayName;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.0),
        onTap: () => context.pushNamed(
          PsychologistPatientDetailWidget.routeName,
          extra: entry.patient,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.error, size: 20.0),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  '$name · ${entry.record.emotion} · ${entry.record.intensity.round()}/10',
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                    color: theme.primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (entry.record.timestamp != null)
                Text(
                  formatDateEs(entry.record.timestamp!),
                  style: theme.bodySmall.override(
                    font: GoogleFonts.outfit(),
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentRecordRow extends StatelessWidget {
  const _RecentRecordRow({required this.entry});
  final _PatientRecord entry;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final name = entry.patient.displayName.isEmpty
        ? entry.patient.email
        : entry.patient.displayName;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.0),
        onTap: () => context.pushNamed(
          PsychologistPatientDetailWidget.routeName,
          extra: entry.patient,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(14.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$name · ${entry.record.emotion} · ${entry.record.intensity.round()}/10',
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.outfit(),
                    color: theme.primaryText,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
              if (entry.record.timestamp != null)
                Text(
                  formatDateEs(entry.record.timestamp!),
                  style: theme.bodySmall.override(
                    font: GoogleFonts.outfit(),
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name, required this.photoUrl});

  final String name;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    if (photoUrl.isNotEmpty) {
      return CircleAvatar(radius: 22.0, backgroundImage: NetworkImage(photoUrl));
    }
    final trimmed = name.trim();
    final initials = trimmed.isEmpty
        ? '?'
        : trimmed
            .split(RegExp(r'\s+'))
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join();
    return CircleAvatar(
      radius: 22.0,
      backgroundColor: FlutterFlowTheme.of(context).primary,
      child: Text(
        initials,
        style: TextStyle(
          color: FlutterFlowTheme.of(context).onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({
    required this.patient,
    required this.pendingTasks,
    this.nextSessionDate,
  });

  final UsersRecord patient;
  final int pendingTasks;
  final DateTime? nextSessionDate;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final name =
        patient.displayName.isEmpty ? patient.email : patient.displayName;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.0),
        onTap: () => context.pushNamed(
          PsychologistPatientDetailWidget.routeName,
          extra: patient,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InitialsAvatar(name: name, photoUrl: patient.photoUrl),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.titleSmall.override(
                          font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                          color: theme.primaryText,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        patient.hasPsychologistLinkedAt()
                            ? 'Desde ${formatDateEs(patient.psychologistLinkedAt!)}'
                            : 'Fecha de inicio no disponible',
                        style: theme.bodySmall.override(
                          font: GoogleFonts.outfit(),
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                        ),
                      ),
                      Text(
                        patient.hasLastActivityAt()
                            ? 'Última actividad: ${formatDateEs(patient.lastActivityAt!)}'
                            : 'Sin actividad todavía',
                        style: theme.bodySmall.override(
                          font: GoogleFonts.outfit(),
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Row(
                        children: [
                          Icon(Icons.pending_actions_rounded,
                              size: 14.0, color: theme.secondaryText),
                          const SizedBox(width: 4.0),
                          Text(
                            '$pendingTasks tareas pendientes',
                            style: theme.bodySmall.override(
                              font: GoogleFonts.outfit(),
                              color: theme.secondaryText,
                              letterSpacing: 0.0,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Icon(Icons.event_rounded,
                              size: 14.0, color: theme.secondaryText),
                          const SizedBox(width: 4.0),
                          Text(
                            nextSessionDate != null
                                ? 'Próxima sesión: ${formatDateEs(nextSessionDate!)}'
                                : 'Próxima sesión: —',
                            style: theme.bodySmall.override(
                              font: GoogleFonts.outfit(),
                              color: theme.secondaryText,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: theme.secondaryText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
