import 'dart:async';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/task_status.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Actividad recomendada por tu psicólogo": shows the patient's pending
/// `activity_assignments`, lets them jump straight to the assigned tool
/// (via its `routeName`, if any) and mark it as done. Renders nothing when
/// there's nothing pending, so patients without a psychologist -- or with
/// nothing currently assigned -- never see an empty section.
class RecommendedActivitiesSection extends StatelessWidget {
  const RecommendedActivitiesSection({super.key});

  Future<void> _open(BuildContext context, ActivityAssignmentsRecord assignment) async {
    if (!assignment.hasOpenedAt()) {
      unawaited(assignment.reference.update({'openedAt': DateTime.now()}));
    }
    if (assignment.routeName.isNotEmpty) {
      await context.pushNamed(assignment.routeName);
    }
  }

  Future<void> _markCompleted(ActivityAssignmentsRecord assignment) {
    return assignment.reference.update({
      'status': 'completada',
      'completedAt': DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final myRef = currentUserReference;
    if (myRef == null) return const SizedBox.shrink();

    return StreamBuilder<List<ActivityAssignmentsRecord>>(
      stream: queryActivityAssignmentsRecord(
        queryBuilder: (q) => q.where('patientRef', isEqualTo: myRef),
      ),
      builder: (context, snapshot) {
        final pending = (snapshot.data ?? [])
            .where((a) => a.status != 'completada')
            .toList()
          ..sort((a, b) =>
              (b.assignedTime ?? DateTime(2000)).compareTo(a.assignedTime ?? DateTime(2000)));
        if (pending.isEmpty) return const SizedBox.shrink();

        final theme = FlutterFlowTheme.of(context);
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology_alt_rounded, size: 18.0, color: theme.primary),
                  const SizedBox(width: 6.0),
                  Text(
                    'Recomendado por tu psicólogo',
                    style: theme.titleSmall.override(
                      font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      color: theme.primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              ...pending.map((assignment) => Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
                      ),
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignment.activityName,
                            style: theme.bodyMedium.override(
                              font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                              color: theme.primaryText,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (assignment.instructions.isNotEmpty)
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                              child: Text(
                                assignment.instructions,
                                style: theme.bodySmall.override(
                                  font: GoogleFonts.outfit(),
                                  color: theme.secondaryText,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ),
                          if (assignment.hasFrequency() && assignment.frequency.isNotEmpty)
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                              child: Text(
                                'Frecuencia: ${taskFrequencyLabel(assignment.frequency)}',
                                style: theme.bodySmall.override(
                                  font: GoogleFonts.outfit(),
                                  color: theme.secondaryText,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => _markCompleted(assignment),
                                child: const Text('Marcar como realizada'),
                              ),
                              if (assignment.routeName.isNotEmpty)
                                TextButton(
                                  onPressed: () => _open(context, assignment),
                                  child: const Text('Abrir'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
