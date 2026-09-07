import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bell icon with a live unread-count badge, opening [NotificationsWidget].
/// Shared by the patient/psychologist home headers and the admin panel --
/// the same widget works for all three roles because [NotificationsWidget]
/// itself just reads whatever `notifications` exist for the current user.
///
/// The live `.snapshots()` listener here is safe (unlike the
/// records/behavioral_records/tasks listeners this app deliberately avoids
/// -- see registros_tab.dart): `notifications` docs are never rewritten by
/// a background trigger the way a patient's `users/{uid}` doc is, so there
/// is no flicker-to-empty risk.
class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key, this.iconColor});

  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final myRef = currentUserReference;
    return InkWell(
      borderRadius: BorderRadius.circular(24.0),
      onTap: () => context.pushNamed(NotificationsWidget.routeName),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications_rounded,
              color: iconColor ?? FlutterFlowTheme.of(context).primaryText,
              size: 26.0,
            ),
            if (myRef != null)
              StreamBuilder<List<NotificationsRecord>>(
                stream: queryNotificationsRecord(
                  queryBuilder: (q) => q
                      .where('recipientRef', isEqualTo: myRef)
                      .where('read', isEqualTo: false),
                ),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  if (count == 0) return const SizedBox.shrink();
                  return Positioned(
                    right: -2.0,
                    top: -2.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 1.0),
                      constraints: const BoxConstraints(minWidth: 16.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).error,
                        borderRadius: BorderRadius.circular(999.0),
                      ),
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold),
                              color: Colors.white,
                              fontSize: 10.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
