import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'resumen_tab.dart';
import 'avances_tab.dart';
import 'registros_tab.dart';
import 'sesiones_tab.dart';
import 'tareas_tab.dart';
import 'actividades_tab.dart';

/// Full follow-up view for one patient, reached from `PsychologistHomeWidget`.
/// Six tabs: Resumen | Avances | Registros | Sesiones | Tareas |
/// Actividades. Every write here is gated by firestore.rules to the
/// patient's currently assigned psychologist -- this screen never assumes
/// permission, it just reflects what the backend already enforces.
class PsychologistPatientDetailWidget extends StatelessWidget {
  const PsychologistPatientDetailWidget({super.key, required this.patient});

  final UsersRecord patient;

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
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
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
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                              font:
                                  GoogleFonts.outfit(fontWeight: FontWeight.bold),
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(width: 40.0),
                  ],
                ),
              ),
              TabBar(
                isScrollable: true,
                labelColor: FlutterFlowTheme.of(context).primary,
                unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
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
    );
  }
}
