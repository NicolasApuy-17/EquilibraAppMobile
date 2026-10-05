import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/components/privacy_links.dart';
import '/config/legal_links.dart';

/// Static "Términos y Condiciones" + "Política de Privacidad" page, linked
/// from the welcome, login and create-account screens (pre-authentication,
/// so this route carries no `requireAuth` in nav.dart) and required-reading
/// behind the acceptance checkbox on account creation.
class TermsPrivacyWidget extends StatelessWidget {
  const TermsPrivacyWidget({super.key});

  static String routeName = 'TermsPrivacy';
  static String routePath = '/termsPrivacy';

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
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
                    icon: Icon(Icons.arrow_back_rounded,
                        color: theme.primaryText, size: 24.0),
                    onPressed: () => context.safePop(),
                  ),
                  Expanded(
                    child: Text(
                      'Términos y Privacidad',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.titleLarge.override(
                        font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        color: theme.primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40.0),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 32.0),
                children: [
                  Text(
                    'Última actualización: octubre de 2026',
                    style: theme.bodySmall.override(
                      font: GoogleFonts.outfit(),
                      color: theme.secondaryText,
                      letterSpacing: 0.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const _Paragraph(
                    'Equilibra es una herramienta de apoyo al tratamiento '
                    'psicológico que conecta a un paciente con su psicólogo '
                    'asignado. Al crear una cuenta o iniciar sesión, aceptas '
                    'los siguientes Términos y Condiciones y nuestra Política '
                    'de Privacidad.',
                  ),
                  const _SectionTitle('Términos y Condiciones'),
                  const _SubTitle('1. Aceptación de los términos'),
                  const _Paragraph(
                    'El uso de Equilibra implica la aceptación plena de estos '
                    'términos. Si no estás de acuerdo, no debes usar la '
                    'aplicación.',
                  ),
                  const _SubTitle('2. No es un servicio de emergencia'),
                  const _Paragraph(
                    'Equilibra es un complemento al tratamiento con tu '
                    'psicólogo, no un servicio de urgencias ni de atención '
                    'inmediata. Si tú o alguien más está en riesgo, contacta a '
                    'los servicios de emergencia de tu localidad o usa la '
                    'opción "Ayuda urgente" de la app para ver líneas de '
                    'apoyo.',
                  ),
                  const _SubTitle('Aviso de salud'),
                  const _Paragraph(healthDisclaimer),
                  const _SubTitle('3. Cuentas de usuario'),
                  const _Paragraph(
                    'Eres responsable de mantener la confidencialidad de tu '
                    'contraseña y de toda la actividad realizada desde tu '
                    'cuenta. La información que registras (nombre, correo, '
                    'registros emocionales y de conducta, objetivos, tareas) '
                    'debe ser veraz.',
                  ),
                  const _SubTitle('4. Vínculo con tu psicólogo'),
                  const _Paragraph(
                    'Si te vinculas a un psicólogo mediante un código, por '
                    'defecto le concedes acceso a la información clínica que '
                    'registres en la app, exclusivamente con fines de '
                    'seguimiento de tu tratamiento. Puedes desactivar ese '
                    'acceso a "Mis registros" cuando quieras desde tu perfil, '
                    'sin necesidad de desvincularte de tu psicólogo (ver '
                    '"Quién puede ver tu información" en la Política de '
                    'Privacidad).',
                  ),
                  const _SubTitle('5. Uso aceptable'),
                  const _Paragraph(
                    'No debes usar la app para fines distintos al '
                    'autorregistro y seguimiento de tu bienestar, ni intentar '
                    'acceder a información de otros usuarios.',
                  ),
                  const _SubTitle('6. Cambios en el servicio'),
                  const _Paragraph(
                    'Podemos actualizar estos términos o las funciones de la '
                    'app. Los cambios importantes se comunicarán dentro de la '
                    'aplicación.',
                  ),
                  const _SectionTitle('Política de Privacidad'),
                  const _SubTitle('1. Qué datos recopilamos'),
                  const _Paragraph(
                    'Datos de cuenta (nombre, correo electrónico, teléfono '
                    'opcional), y datos clínicos que tú decides registrar: '
                    'emociones, conductas, objetivos, tareas, sesiones y '
                    'novedades de tu psicólogo.',
                  ),
                  const _SubTitle('2. Para qué usamos tus datos'),
                  const _Paragraph(
                    'Tus datos se usan exclusivamente para brindarte el '
                    'servicio de la aplicación y apoyar tu tratamiento '
                    'psicológico: mostrarte tu propio historial, y permitir '
                    'que tu psicólogo asignado dé seguimiento a tu proceso. '
                    'No usamos tus datos con fines publicitarios ni los '
                    'vendemos ni compartimos con terceros.',
                  ),
                  const _SubTitle('3. Quién puede ver tu información'),
                  const _Paragraph(
                    'Solo tú y el psicólogo al que te vincules pueden ver tus '
                    'registros clínicos. Un administrador de la plataforma '
                    'puede acceder a datos operativos limitados '
                    '(por ejemplo, para soporte técnico), nunca con fines '
                    'comerciales.',
                  ),
                  const _Paragraph(
                    'Tú tienes el control: desde tu perfil, en "Privacidad y '
                    'Datos", puedes activar o desactivar en cualquier momento '
                    'que tu psicólogo vea "Mis registros" (emociones, '
                    'conductas y objetivos), incluso si ya estás vinculado a '
                    'él. Al desactivarlo, deja de ver tanto los registros '
                    'nuevos como los que ya habías hecho; al reactivarlo, '
                    'vuelve a verlos todos. Esto no afecta el agendamiento de '
                    'sesiones ni las tareas que te asigne.',
                  ),
                  const _SubTitle('4. Seguridad'),
                  const _Paragraph(
                    'Tu información se almacena de forma segura en '
                    'infraestructura de Firebase/Google Cloud, con reglas de '
                    'acceso que restringen cada dato solo a las personas '
                    'autorizadas a verlo. Toda la comunicación entre la app y '
                    'nuestros servidores está cifrada.',
                  ),
                  const _SubTitle('5. Tus derechos'),
                  const _Paragraph(
                    'Puedes acceder, corregir o eliminar tu información desde '
                    'tu perfil, o solicitando la eliminación de tu cuenta y '
                    'los datos asociados desde "Privacidad y Datos" → '
                    '"Solicitar eliminación de cuenta", o mediante nuestra '
                    'página pública de eliminación de cuenta. Desactivar la '
                    'cuenta no equivale a eliminarla.',
                  ),
                  const SizedBox(height: 12.0),
                  const PrivacyLinks(),
                  const _SubTitle('6. Conservación de datos'),
                  const _Paragraph(
                    'Conservamos tu información mientras tu cuenta esté '
                    'activa. Si solicitas la eliminación de tu cuenta, '
                    'borramos tus datos personales de nuestros sistemas, '
                    'salvo que la ley exija conservarlos por más tiempo.',
                  ),
                  const SizedBox(height: 8.0),
                  const _Paragraph(
                    '¿Tienes preguntas sobre estos términos o tu privacidad? '
                    'Escríbenos desde "Contacto de Apoyo" en tu perfil.',
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 8.0),
      child: Text(
        text,
        style: theme.titleMedium.override(
          font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          color: theme.primaryText,
          letterSpacing: 0.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 4.0),
      child: Text(
        text,
        style: theme.bodyMedium.override(
          font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          color: theme.primaryText,
          letterSpacing: 0.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Text(
      text,
      style: theme.bodySmall.override(
        font: GoogleFonts.outfit(),
        color: theme.secondaryText,
        letterSpacing: 0.0,
        lineHeight: 1.5,
      ),
    );
  }
}
