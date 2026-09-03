import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/utils/date_format_es.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Admin-only log of app errors/incidents (see
/// lib/utils/error_logging.dart). This is a *summary* log for quick
/// triage inside the app -- the full native stack trace for any of these
/// lives in Crashlytics, in the Firebase Console, not here.
class AdminIncidentsTab extends StatelessWidget {
  const AdminIncidentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppErrorsRecord>>(
      stream: queryAppErrorsRecord(limit: 100),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No se pudieron cargar las incidencias.'),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final errors = snapshot.data!
          ..sort((a, b) =>
              (b.createdTime ?? DateTime(2000)).compareTo(a.createdTime ?? DateTime(2000)));
        if (errors.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Sin incidencias registradas. Buena señal.',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.outfit(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 24.0, 24.0),
          itemCount: errors.length,
          itemBuilder: (context, index) => _IncidentTile(error: errors[index]),
        );
      },
    );
  }
}

class _IncidentTile extends StatelessWidget {
  const _IncidentTile({required this.error});

  final AppErrorsRecord error;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14.0),
          childrenPadding: const EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 14.0),
          backgroundColor: theme.secondaryBackground,
          collapsedBackgroundColor: theme.secondaryBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
          title: Text(
            error.context.isEmpty ? 'Error' : error.context,
            style: theme.bodyMedium.override(
              font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              color: theme.primaryText,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            [
              if (error.createdTime != null) formatDateEs(error.createdTime!),
              if (error.role.isNotEmpty) error.role,
            ].join(' · '),
            style: theme.bodySmall.override(
              font: GoogleFonts.outfit(),
              color: theme.secondaryText,
              letterSpacing: 0.0,
            ),
          ),
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                error.message.isEmpty ? 'Sin mensaje.' : error.message,
                style: theme.bodySmall.override(
                  font: GoogleFonts.outfit(),
                  color: theme.primaryText,
                  letterSpacing: 0.0,
                ),
              ),
            ),
            if (error.stackTrace.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      error.stackTrace,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11.0),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
