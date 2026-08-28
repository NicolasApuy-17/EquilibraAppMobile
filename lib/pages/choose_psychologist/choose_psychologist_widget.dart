import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/psychologist_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Lets a patient browse the directory of psychologists (any `users` doc
/// with `role == 'psicologo'`, readable by any authenticated user per
/// firestore.rules) and pick one. On confirm, calls `assignPsychologist`
/// and opens the resulting chat — this is where the home screen's chat
/// button sends a patient who doesn't have one assigned yet.
class ChoosePsychologistWidget extends StatefulWidget {
  const ChoosePsychologistWidget({super.key});

  static String routeName = 'ChoosePsychologist';
  static String routePath = '/choosePsychologist';

  @override
  State<ChoosePsychologistWidget> createState() =>
      _ChoosePsychologistWidgetState();
}

class _ChoosePsychologistWidgetState extends State<ChoosePsychologistWidget> {
  final _service = PsychologistService();
  bool _isAssigning = false;

  Future<void> _choose(UsersRecord psychologist) async {
    if (_isAssigning) return;
    setState(() => _isAssigning = true);
    try {
      final conversationId =
          await _service.assignPsychologist(psychologist.reference.id);
      if (!mounted) return;
      context.pushReplacementNamed(
        PsychologistChatWidget.routeName,
        extra: conversationId,
      );
    } on PsychologistServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _isAssigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
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
                      'Elige tu psicólogo',
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
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 12.0),
              child: Text(
                'Para chatear necesitas elegir primero al psicólogo que va a '
                'acompañar tu proceso.',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.outfit(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<UsersRecord>>(
                stream: queryUsersRecord(
                  queryBuilder: (usersRecord) =>
                      usersRecord.where('role', isEqualTo: 'psicologo'),
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'No se pudo cargar la lista de psicólogos.',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.outfit(),
                              color: FlutterFlowTheme.of(context).error,
                              letterSpacing: 0.0,
                            ),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final psychologists = snapshot.data!;
                  if (psychologists.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          'Todavía no hay psicólogos disponibles. Vuelve a '
                          'intentarlo más tarde.',
                          textAlign: TextAlign.center,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.outfit(),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        24.0, 0.0, 24.0, 24.0),
                    itemCount: psychologists.length,
                    itemBuilder: (context, index) {
                      final psychologist = psychologists[index];
                      return Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 12.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20.0),
                          onTap: _isAssigning
                              ? null
                              : () => _choose(psychologist),
                          child: Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    psychologist.displayName.isEmpty
                                        ? psychologist.email
                                        : psychologist.displayName,
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  if (psychologist.specialty.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(0.0, 4.0, 0.0, 0.0),
                                      child: Text(
                                        psychologist.specialty,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.outfit(),
                                              color: FlutterFlowTheme.of(
                                                      context)
                                                  .secondaryText,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
