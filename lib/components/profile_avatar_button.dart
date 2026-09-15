import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The signed-in user's own photo (falling back to their initials), shown
/// as a small tappable avatar in a header -- opens [AccountPanelWidget],
/// which itself has a way into [EditProfileWidget] to view/edit their
/// name, phone and photo. Every role gets one: previously
/// only the patient had any way to reach their own profile settings; the
/// admin and psychologist headers had a "cerrar sesión" button and nothing
/// else. Shares the same live-updating approach as `_ProfileAvatar` in
/// user_profile_widget.dart (wrapped in `AuthUserStreamWidget` so it
/// reflects a just-saved photo immediately, no navigation needed) rather
/// than reusing that private widget directly, since this one is sized for
/// an app-bar icon instead of a full profile-screen header.
class ProfileAvatarButton extends StatelessWidget {
  const ProfileAvatarButton({super.key, this.size = 36.0});

  final double size;

  bool _hasValidUrl(String url) =>
      url.isNotEmpty &&
      (url.startsWith('http://') || url.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999.0),
      onTap: () => context.pushNamed(AccountPanelWidget.routeName),
      child: AuthUserStreamWidget(
        builder: (context) {
          final photoUrl = currentUserPhoto;
          final fallbackText = currentUserDisplayName.isNotEmpty
              ? currentUserDisplayName
              : currentUserEmail;
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: FlutterFlowTheme.of(context).primary20,
                width: 2.0,
              ),
            ),
            child: ClipOval(
              child: _hasValidUrl(photoUrl)
                  ? CachedNetworkImage(
                      imageUrl: photoUrl,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          _InitialsCircle(text: fallbackText, size: size),
                      placeholder: (context, url) =>
                          _InitialsCircle(text: fallbackText, size: size),
                    )
                  : _InitialsCircle(text: fallbackText, size: size),
            ),
          );
        },
      ),
    );
  }
}

class _InitialsCircle extends StatelessWidget {
  const _InitialsCircle({required this.text, required this.size});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary,
        shape: BoxShape.circle,
      ),
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Text(
        functions.getInitials(text),
        textAlign: TextAlign.center,
        maxLines: 1,
        style: FlutterFlowTheme.of(context).labelSmall.override(
              font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              color: FlutterFlowTheme.of(context).onPrimary,
              fontSize: size * 0.38,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
            ),
        overflow: TextOverflow.clip,
      ),
    );
  }
}
