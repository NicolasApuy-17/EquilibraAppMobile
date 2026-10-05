import '/backend/backend.dart';
import '/components/tablet_bounded.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'resumen_tab.dart';
import 'avances_tab.dart';
import 'registros_tab.dart';
import 'sesiones_tab.dart';
import 'tareas_tab.dart';
import 'actividades_tab.dart';

/// Loads a patient for direct links while preserving existing in-memory callers.
class PatientDetailRoute extends StatefulWidget {
  const PatientDetailRoute(
      {super.key, this.patient, this.patientId, this.initialTabIndex = 0});
  final UsersRecord? patient;
  final String? patientId;
  final int initialTabIndex;

  @override
  State<PatientDetailRoute> createState() => _PatientDetailRouteState();
}

class _PatientDetailRouteState extends State<PatientDetailRoute> {
  late Future<UsersRecord?> _patient = _load();

  @override
  void didUpdateWidget(covariant PatientDetailRoute oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patientId != widget.patientId ||
        !identical(oldWidget.patient, widget.patient)) {
      _patient = _load();
    }
  }

  Future<UsersRecord?> _load() async {
    if (widget.patient != null) return widget.patient;
    final id = widget.patientId;
    if (id == null || id.isEmpty || id.contains('/')) return null;
    final snapshot = await UsersRecord.collection.doc(id).get();
    return snapshot.exists ? UsersRecord.fromSnapshot(snapshot) : null;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<UsersRecord?>(
        future: _patient,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Consultante')),
              body: const Center(
                  child: Text('No se pudo abrir este consultante.')),
            );
          }
          return PsychologistPatientDetailWidget(
            patient: snapshot.data!,
            initialTabIndex: widget.initialTabIndex,
          );
        },
      );
}

/// Full follow-up view for one patient, reached from `PsychologistHomeWidget`.
/// Six tabs: Resumen | Avances | Registros | Sesiones | Tareas |
/// Actividades. Every write here is gated by firestore.rules to the
/// patient's currently assigned psychologist -- this screen never assumes
/// permission, it just reflects what the backend already enforces.
class PsychologistPatientDetailWidget extends StatelessWidget {
  const PsychologistPatientDetailWidget({
    super.key,
    required this.patient,
    this.initialTabIndex = 0,
  });

  final UsersRecord patient;

  /// Which of the 6 tabs to open on first build -- lets a notification
  /// ("nuevo registro", "tarea completada", ...) land directly on the tab
  /// it's about instead of always starting at Resumen. See nav.dart, which
  /// reads this from a `?tab=` query parameter.
  final int initialTabIndex;

  static String routeName = 'PsychologistPatientDetail';
  static String routePath = '/psychologistPatientDetail';

  static const _tabs = [
    'Resumen',
    'Avances',
    'Registros',
    'Sesiones',
    'Tareas',
    'Actividades',
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      initialIndex: initialTabIndex.clamp(0, _tabs.length - 1),
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          child: TabletBounded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FlutterFlowIconButton(
                        borderRadius: 8.0,
                        buttonSize: 40.0,
                        fillColor: Colors.transparent,
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                        onPressed: () => context.safePop(),
                      ),
                      Expanded(
                        child: Text(
                          patient.displayName.isEmpty
                              ? patient.email
                              : patient.displayName,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FlutterFlowTheme.of(context)
                              .titleLarge
                              .override(
                                font: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold),
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      FlutterFlowIconButton(
                        borderRadius: 8.0,
                        buttonSize: 40.0,
                        fillColor: Colors.transparent,
                        icon: Icon(
                          Icons.forum_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 24.0,
                        ),
                        // Resolve the patient UID to the current conversation.
                        onPressed: () => context.pushNamed(
                          PsychologistChatWidget.routeName,
                          extra: patient.reference.id,
                        ),
                      ),
                    ],
                  ),
                ),
                TabBar(
                  isScrollable: true,
                  labelColor: FlutterFlowTheme.of(context).primary,
                  unselectedLabelColor:
                      FlutterFlowTheme.of(context).secondaryText,
                  indicatorColor: FlutterFlowTheme.of(context).primary,
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      ResumenTab(patient: patient),
                      AvancesTab(patient: patient),
                      RegistrosTab(patient: patient),
                      SesionesTab(patient: patient),
                      TareasTab(patient: patient),
                      ActividadesTab(patient: patient),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
