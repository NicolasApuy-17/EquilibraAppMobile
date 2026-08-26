import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _ContactOption {
  const _ContactOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.url,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final String url;
  final bool highlight;
}

// Recursos reales de salud mental y emergencia disponibles en Perú
// (Ministerio de Salud - MINSA). Fuente: gob.pe/minsa.
const _kEmergencyOptions = [
  _ContactOption(
    icon: Icons.support_agent_rounded,
    title: 'Línea 113, opción 5 · Salud Mental (MINSA)',
    subtitle:
        'Orientación psicológica gratuita, las 24 horas, los 365 días del '
        'año. Atendida por profesionales de salud mental del Ministerio '
        'de Salud. Gratis desde cualquier operador en Perú.',
    actionLabel: 'Llamar al 113',
    url: 'tel:113',
    highlight: true,
  ),
  _ContactOption(
    icon: Icons.emergency_rounded,
    title: 'SAMU · Emergencias médicas',
    subtitle:
        'Si tu vida o la de otra persona está en riesgo inmediato, llama '
        'a la línea de emergencias médicas del Ministerio de Salud.',
    actionLabel: 'Llamar al 106',
    url: 'tel:106',
  ),
  _ContactOption(
    icon: Icons.diversity_3_rounded,
    title: 'Línea 100 · Contención emocional (MIMP)',
    subtitle:
        'Línea gratuita del Ministerio de la Mujer y Poblaciones '
        'Vulnerables para violencia familiar y apoyo emocional.',
    actionLabel: 'Llamar al 100',
    url: 'tel:100',
  ),
];

const _kOtherChannels = [
  _ContactOption(
    icon: Icons.chat_bubble_outline_rounded,
    title: 'WhatsApp Infosalud (MINSA)',
    subtitle: 'Escribe por WhatsApp para recibir orientación en salud.',
    actionLabel: 'Escribir por WhatsApp',
    url: 'https://wa.me/51955557000',
  ),
  _ContactOption(
    icon: Icons.mail_outline_rounded,
    title: 'Correo Infosalud',
    subtitle: 'infosalud@minsa.gob.pe',
    actionLabel: 'Enviar correo',
    url: 'mailto:infosalud@minsa.gob.pe',
  ),
];

class SupportContactWidget extends StatelessWidget {
  const SupportContactWidget({super.key});

  static String routeName = 'SupportContact';
  static String routePath = '/supportContact';

  Future<void> _open(BuildContext context, String url) async {
    try {
      await launchURL(url);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el enlace.')),
        );
      }
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
              padding: EdgeInsets.all(24.0),
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
                      'Contacto de Apoyo',
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
                  SizedBox(width: 40.0),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 24.0),
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).warning15,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: FlutterFlowTheme.of(context).warning,
                          size: 20.0,
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                12.0, 0.0, 0.0, 0.0),
                            child: Text(
                              'Si tú o alguien más está en peligro inmediato, '
                              'llama ahora a una línea de emergencia. Estos '
                              'recursos son gratuitos y confidenciales.',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.outfit(),
                                    color:
                                        FlutterFlowTheme.of(context)
                                            .primaryText,
                                    letterSpacing: 0.0,
                                    lineHeight: 1.4,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(4.0, 24.0, 4.0, 8.0),
                    child: Text(
                      'Líneas de emergencia (Perú)',
                      style: FlutterFlowTheme.of(context).labelLarge.override(
                            font: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  for (final option in _kEmergencyOptions)
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                      child: _ContactCard(
                        option: option,
                        onTap: () => _open(context, option.url),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(4.0, 12.0, 4.0, 8.0),
                    child: Text(
                      'Otros canales',
                      style: FlutterFlowTheme.of(context).labelLarge.override(
                            font: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  for (final option in _kOtherChannels)
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                      child: _ContactCard(
                        option: option,
                        onTap: () => _open(context, option.url),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 0.0),
                    child: Text(
                      'Equilibra es una herramienta de apoyo y no reemplaza '
                      'la atención médica o psicológica profesional.',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.outfit(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.option, required this.onTap});

  final _ContactOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: option.highlight
            ? FlutterFlowTheme.of(context).primary10
            : FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(20.0),
        border: option.highlight
            ? Border.all(color: FlutterFlowTheme.of(context).primary)
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary15,
                borderRadius: BorderRadius.circular(16.0),
              ),
              alignment: Alignment.center,
              child: Icon(
                option.icon,
                color: FlutterFlowTheme.of(context).primary,
                size: 22.0,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            font: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600),
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 12.0),
                      child: Text(
                        option.subtitle,
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                              font: GoogleFonts.outfit(),
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                              lineHeight: 1.4,
                            ),
                      ),
                    ),
                    InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            14.0, 8.0, 14.0, 8.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          option.actionLabel,
                          style: FlutterFlowTheme.of(context)
                              .labelMedium
                              .override(
                                font: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold),
                                color: FlutterFlowTheme.of(context).onPrimary,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
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
