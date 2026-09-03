import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/psychologist_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Lets a patient link to their psychologist by entering the unique code
/// the psychologist gave them (e.g. "FABRIZZIO-4821") — replaces the old
/// "choose from a list" flow so a patient can never accidentally pick the
/// wrong professional. On success, calls `linkPsychologistByCode` and opens
/// the resulting chat, same as the flow it replaces.
class LinkPsychologistWidget extends StatefulWidget {
  const LinkPsychologistWidget({super.key});

  static String routeName = 'LinkPsychologist';
  static String routePath = '/linkPsychologist';

  @override
  State<LinkPsychologistWidget> createState() =>
      _LinkPsychologistWidgetState();
}

class _LinkPsychologistWidgetState extends State<LinkPsychologistWidget> {
  final _service = PsychologistService();
  final _codeController = TextEditingController();
  bool _isLinking = false;
  String? _errorText;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _link() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorText = 'Ingresa el código de tu psicólogo.');
      return;
    }
    setState(() {
      _isLinking = true;
      _errorText = null;
    });
    try {
      final conversationId = await _service.linkPsychologistByCode(code);
      if (!mounted) return;
      context.pushReplacementNamed(
        PsychologistChatWidget.routeName,
        extra: conversationId,
      );
    } on PsychologistServiceException catch (e) {
      if (mounted) setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _isLinking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                        'Vincula a tu psicólogo',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                              font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold),
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
                padding:
                    const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pide a tu psicólogo su código de vinculación (por '
                      'ejemplo, NOMBRE-1234) e ingrésalo aquí para conectar '
                      'tu cuenta con la suya.',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.outfit(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 24.0),
                    TextField(
                      controller: _codeController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _link(),
                      onChanged: (_) {
                        if (_errorText != null) {
                          setState(() => _errorText = null);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Código de tu psicólogo',
                        hintText: 'NOMBRE-1234',
                        errorText: _errorText,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    InkWell(
                      onTap: _isLinking ? null : _link,
                      child: Container(
                        height: 48.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary,
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: _isLinking
                            ? SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation(
                                      FlutterFlowTheme.of(context).onPrimary),
                                ),
                              )
                            : Text(
                                'Vincular',
                                style: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      font: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold),
                                      color:
                                          FlutterFlowTheme.of(context).onPrimary,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                      ),
                    ),
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
