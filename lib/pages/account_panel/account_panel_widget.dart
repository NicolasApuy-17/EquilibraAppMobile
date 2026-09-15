import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Minimal account panel opened from the admin/psychologist header's own
/// profile-photo button (see ProfileAvatarButton) -- unlike the patient's
/// "Mi Perfil" (UserProfileWidget), which is full of patient-only content
/// (metas, centro de ayuda, etc.), an admin or psychologist has nothing
/// role-appropriate to show here yet. Deliberately kept small: photo, name,
/// email/role, and the one thing they actually need -- a way into
/// EditProfileWidget to change their name/phone/photo. More account-level
/// options belong here as they're built, rather than back on the header
/// button itself.
class AccountPanelWidget extends StatelessWidget {
  const AccountPanelWidget({super.key});

  static String routeName = 'AccountPanel';
  static String routePath = '/accountPanel';

  bool _hasValidUrl(String url) =>
      url.isNotEmpty &&
      (url.startsWith('http://') || url.startsWith('https://'));

  String _roleLabel(String? role) {
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'psicologo':
        return 'Psicólogo';
      case 'paciente':
        return 'Paciente';
      default:
        return '';
    }
  }

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
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: theme.primaryText,
                      size: 24.0,
                    ),
                    onPressed: () => context.safePop(),
                  ),
                  Expanded(
                    child: Text(
                      'Mi cuenta',
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
              child: AuthUserStreamWidget(
                builder: (context) {
                  final photoUrl = currentUserPhoto;
                  final displayName = currentUserDisplayName;
                  final fallbackText =
                      displayName.isNotEmpty ? displayName : currentUserEmail;
                  final roleLabel = _roleLabel(currentUserDocument?.role);
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    children: [
                      const SizedBox(height: 12.0),
                      Center(
                        child: Container(
                          width: 96.0,
                          height: 96.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.primary20,
                              width: 3.0,
                            ),
                          ),
                          child: ClipOval(
                            child: _hasValidUrl(photoUrl)
                                ? CachedNetworkImage(
                                    imageUrl: photoUrl,
                                    width: 84.0,
                                    height: 84.0,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        _InitialsCircle(text: fallbackText),
                                    placeholder: (context, url) =>
                                        _InitialsCircle(text: fallbackText),
                                  )
                                : _InitialsCircle(text: fallbackText),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        displayName.isNotEmpty ? displayName : currentUserEmail,
                        textAlign: TextAlign.center,
                        style: theme.titleMedium.override(
                          font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                          color: theme.primaryText,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (roleLabel.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            roleLabel,
                            textAlign: TextAlign.center,
                            style: theme.bodyMedium.override(
                              font: GoogleFonts.outfit(),
                              color: theme.secondaryText,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                      const SizedBox(height: 28.0),
                      _AccountOptionTile(
                        icon: Icons.settings_outlined,
                        label: 'Configurar perfil',
                        subtitle: 'Nombre, teléfono y foto de perfil',
                        onTap: () =>
                            context.pushNamed(EditProfileWidget.routeName),
                      ),
                    ],
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

class _AccountOptionTile extends StatelessWidget {
  const _AccountOptionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: theme.primary, size: 24.0),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      color: theme.primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      subtitle,
                      style: theme.bodySmall.override(
                        font: GoogleFonts.outfit(),
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: theme.secondaryText, size: 22.0),
          ],
        ),
      ),
    );
  }
}

class _InitialsCircle extends StatelessWidget {
  const _InitialsCircle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84.0,
      height: 84.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary,
        shape: BoxShape.circle,
      ),
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Text(
        functions.getInitials(text),
        textAlign: TextAlign.center,
        maxLines: 1,
        style: FlutterFlowTheme.of(context).labelMedium.override(
              font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              color: FlutterFlowTheme.of(context).onPrimary,
              fontSize: 30.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
            ),
        overflow: TextOverflow.clip,
      ),
    );
  }
}
