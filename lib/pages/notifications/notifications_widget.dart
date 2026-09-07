import 'dart:async';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/tablet_bounded.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/date_format_es.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared by all three roles: a patient sees replies from their
/// psychologist (chat, observations on records, feedback on tasks, new
/// tasks/activities assigned); a psychologist sees messages from their
/// consultantes plus new records and completed tasks/activities; an admin
/// sees new self-service patient-psychologist links and logged app errors.
/// Every notification here is written by a Cloud Function -- see
/// firebase/functions/notifications.js for the full list of `type`s and
/// exactly when each is created. The client only ever reads and toggles
/// `read`.
class NotificationsWidget extends StatefulWidget {
  const NotificationsWidget({super.key});

  static String routeName = 'Notifications';
  static String routePath = '/notifications';

  @override
  State<NotificationsWidget> createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  Future<void> _markAllRead(List<NotificationsRecord> notifications) async {
    final unread = notifications.where((n) => !n.read).toList();
    if (unread.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final n in unread) {
      batch.update(n.reference, {'read': true});
    }
    try {
      await batch.commit();
    } catch (_) {
      // Best-effort -- if it fails, the bell badge just stays as-is; no
      // need to surface an error for a purely cosmetic action.
    }
  }

  Future<void> _handleTap(NotificationsRecord notification) async {
    if (!notification.read) {
      unawaited(notification.reference.update({'read': true}));
    }
    if (notification.type == 'chat_message' &&
        notification.conversationId.isNotEmpty) {
      if (!mounted) return;
      context.pushNamed(
        PsychologistChatWidget.routeName,
        extra: notification.conversationId,
      );
      return;
    }
    // A psychologist tapping a notification about one of their consultantes
    // (a new record, a completed task/activity) jumps straight to that
    // patient's detail screen. Admin notifications never carry a role this
    // screen knows how to deep-link into, so they just get marked read.
    if (notification.subjectRef != null &&
        currentUserDocument?.role == 'psicologo') {
      try {
        final patient =
            await UsersRecord.getDocumentOnce(notification.subjectRef!);
        if (!mounted) return;
        context.pushNamed(
          PsychologistPatientDetailWidget.routeName,
          extra: patient,
        );
      } catch (_) {
        // Patient may no longer exist/be assigned to this psychologist --
        // nothing to navigate to, but the tap still marked it read above.
      }
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'chat_message':
        return Icons.forum_rounded;
      case 'psychologist_comment':
        return Icons.comment_rounded;
      case 'task_assigned':
      case 'task_completed':
        return Icons.assignment_rounded;
      case 'task_feedback':
        return Icons.rate_review_rounded;
      case 'activity_assigned':
      case 'activity_completed':
        return Icons.self_improvement_rounded;
      case 'record_created':
      case 'behavioral_record_created':
        return Icons.mood_rounded;
      case 'new_link':
        return Icons.link_rounded;
      case 'app_error':
        return Icons.error_outline_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final myRef = currentUserReference;
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: TabletBounded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 16.0, 24.0, 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FlutterFlowIconButton(
                      borderRadius: 20.0,
                      buttonSize: 40.0,
                      fillColor: Colors.transparent,
                      icon: Icon(Icons.arrow_back_rounded,
                          color: theme.primaryText, size: 24.0),
                      onPressed: () => context.safePop(),
                    ),
                    Expanded(
                      child: Text(
                        'Notificaciones',
                        textAlign: TextAlign.center,
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
              if (myRef == null)
                Expanded(
                  child: Center(
                    child: Text(
                      'Debes iniciar sesión para ver tus notificaciones.',
                      style: theme.bodyMedium.override(
                        font: GoogleFonts.outfit(),
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: StreamBuilder<List<NotificationsRecord>>(
                    stream: queryNotificationsRecord(
                      queryBuilder: (q) =>
                          q.where('recipientRef', isEqualTo: myRef),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'No se pudieron cargar tus notificaciones.',
                              textAlign: TextAlign.center,
                              style: theme.bodyMedium.override(
                                font: GoogleFonts.outfit(),
                                color: theme.error,
                                letterSpacing: 0.0,
                              ),
                            ),
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final notifications = snapshot.data!.toList()
                        ..sort((a, b) => (b.createdTime ?? DateTime(2000))
                            .compareTo(a.createdTime ?? DateTime(2000)));
                      if (notifications.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'Todavía no tienes notificaciones.',
                              textAlign: TextAlign.center,
                              style: theme.bodyMedium.override(
                                font: GoogleFonts.outfit(),
                                color: theme.secondaryText,
                                letterSpacing: 0.0,
                              ),
                            ),
                          ),
                        );
                      }
                      final hasUnread = notifications.any((n) => !n.read);
                      return Column(
                        children: [
                          if (hasUnread)
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 24.0, 8.0),
                                child: TextButton(
                                  onPressed: () => _markAllRead(notifications),
                                  child: Text(
                                    'Marcar todo como leído',
                                    style: theme.bodySmall.override(
                                      font: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold),
                                      color: theme.primary,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 16.0),
                              itemCount: notifications.length,
                              itemBuilder: (context, index) {
                                final n = notifications[index];
                                return _NotificationTile(
                                  notification: n,
                                  icon: _iconFor(n.type),
                                  onTap: () => _handleTap(n),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.icon,
    required this.onTap,
  });

  final NotificationsRecord notification;
  final IconData icon;
  final VoidCallback onTap;

  /// Today: just the time ("14:32"). Any other day: the short date -- a
  /// notification feed doesn't need full precision, just enough to tell
  /// entries apart at a glance.
  String _formatCompact(DateTime date) {
    final now = DateTime.now();
    final sameDay =
        date.year == now.year && date.month == now.month && date.day == now.day;
    return sameDay ? formatTime24(date) : formatDateEs(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isUnread = !notification.read;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isUnread ? theme.primary10 : theme.secondaryBackground,
            borderRadius: BorderRadius.circular(16.0),
            border: isUnread ? Border.all(color: theme.primary) : null,
          ),
          padding: const EdgeInsets.all(14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: theme.primary, size: 20.0),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.bodyMedium.override(
                              font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold),
                              color: theme.primaryText,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (notification.createdTime != null)
                          Text(
                            _formatCompact(notification.createdTime!),
                            style: theme.bodySmall.override(
                              font: GoogleFonts.outfit(),
                              color: theme.secondaryText,
                              letterSpacing: 0.0,
                            ),
                          ),
                      ],
                    ),
                    if (notification.body.isNotEmpty) ...[
                      const SizedBox(height: 4.0),
                      Text(
                        notification.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.bodySmall.override(
                          font: GoogleFonts.outfit(),
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ],
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
