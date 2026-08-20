import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/bottom_nav3/bottom_nav3_widget.dart';
import '/components/button/button_widget.dart';
import '/components/profile_menu_item/profile_menu_item_widget.dart';
import '/components/profile_stat/profile_stat_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'user_profile_model.dart';
export 'user_profile_model.dart';

class UserProfileWidget extends StatefulWidget {
  const UserProfileWidget({super.key});

  static String routeName = 'UserProfile';
  static String routePath = '/userProfile';

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  late UserProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserProfileModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _showReminderDialog() async {
    final docRef = UserPrefsRecord.collection.doc(currentUserUid);
    var enabled = false;
    try {
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        enabled = UserPrefsRecord.fromSnapshot(snapshot).dailyReminderEnabled;
      }
    } catch (_) {
      // Sin preferencia guardada todavía: se asume desactivado.
    }

    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text('Recordatorios'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Recibir un recordatorio diario para registrar cómo te sientes.',
                    ),
                  ),
                  Switch(
                    value: enabled,
                    onChanged: (value) async {
                      setDialogState(() => enabled = value);
                      await docRef.set(
                        createUserPrefsRecordData(
                          name: currentUserDisplayName,
                          email: currentUserEmail,
                          dailyReminderEnabled: value,
                        ),
                        SetOptions(merge: true),
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Cerrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showPrivacyDialog() async {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Privacidad y Datos'),
          content: Text(
            'Tus registros emocionales, tareas y preferencias están asociados '
            'únicamente a tu cuenta y protegidos por reglas de acceso: solo tú '
            'puedes leer o modificar tu propia información. Nadie más puede '
            'ver tus registros.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return StreamBuilder<List<RecordsRecord>>(
      stream: queryRecordsRecord(
        queryBuilder: (recordsRecord) =>
            recordsRecord.where('userRef', isEqualTo: currentUserReference),
      ),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        List<RecordsRecord> userProfileRecordsRecordList = snapshot.data!;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 0.0,
                    height: 0.0,
                  ),
                  Expanded(
                    child: Container(
                      child: SingleChildScrollView(
                        primary: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                                shape: BoxShape.rectangle,
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    24.0, 24.0, 24.0, 16.0),
                                child: Container(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      FlutterFlowIconButton(
                                        borderRadius: 8.0,
                                        buttonSize: 40.0,
                                        fillColor: Colors.transparent,
                                        icon: Icon(
                                          Icons.arrow_back_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 24.0,
                                        ),
                                        onPressed: () async {
                                          context.safePop();
                                        },
                                      ),
                                      Text(
                                        'Mi Perfil',
                                        style: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .override(
                                              font: GoogleFonts.comfortaa(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .headlineMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .headlineMedium
                                                      .fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                      FlutterFlowIconButton(
                                        borderRadius: 8.0,
                                        buttonSize: 40.0,
                                        fillColor: Colors.transparent,
                                        icon: Icon(
                                          Icons.settings_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 24.0,
                                        ),
                                        onPressed: () async {
                                          context.pushNamed(
                                              EditProfileWidget.routeName);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Container(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(32.0),
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Container(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 100.0,
                                            height: 100.0,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(9999.0),
                                              shape: BoxShape.rectangle,
                                              border: Border.all(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary20,
                                                width: 4.0,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Container(
                                                child: Container(
                                                  width: 80.0,
                                                  height: 80.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Text(
                                                    functions.getInitials(
                                                        currentUserDisplayName
                                                                .isNotEmpty
                                                            ? currentUserDisplayName
                                                            : currentUserEmail),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .labelMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .outfit(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .onPrimary,
                                                          fontSize: 30.4,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                          lineHeight: 1.4,
                                                        ),
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                currentUserDisplayName
                                                        .isNotEmpty
                                                    ? currentUserDisplayName
                                                    : 'Usuario',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .titleLarge
                                                    .override(
                                                      font: GoogleFonts.outfit(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleLarge
                                                                .fontStyle,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleLarge
                                                              .fontStyle,
                                                      lineHeight: 1.4,
                                                    ),
                                              ),
                                              Text(
                                                currentUserEmail,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.outfit(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                      lineHeight: 1.6,
                                                    ),
                                              ),
                                            ].divide(SizedBox(height: 4.0)),
                                          ),
                                          Divider(
                                            height: 16.0,
                                            thickness: 1.0,
                                            indent: 24.0,
                                            endIndent: 24.0,
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 16.0, 0.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: wrapWithModel(
                                                    model: _model
                                                        .profileStatModel1,
                                                    updateCallback: () =>
                                                        safeSetState(() {}),
                                                    child: ProfileStatWidget(
                                                      value:
                                                          userProfileRecordsRecordList
                                                              .length
                                                              .toString(),
                                                      label: 'Registros',
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: wrapWithModel(
                                                    model: _model
                                                        .profileStatModel2,
                                                    updateCallback: () =>
                                                        safeSetState(() {}),
                                                    child: ProfileStatWidget(
                                                      value: functions
                                                          .calculateStreak(
                                                              userProfileRecordsRecordList
                                                                  .toList())
                                                          .toString(),
                                                      label: 'Días seguidos',
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: wrapWithModel(
                                                    model: _model
                                                        .profileStatModel3,
                                                    updateCallback: () =>
                                                        safeSetState(() {}),
                                                    child: ProfileStatWidget(
                                                      value: functions
                                                          .averageIntensityLabel(
                                                              userProfileRecordsRecordList
                                                                  .toList()),
                                                      label: 'Promedio',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ].divide(SizedBox(height: 16.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  24.0, 0.0, 24.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        4.0, 0.0, 0.0, 8.0),
                                    child: Container(
                                      child: Text(
                                        'Configuración de Bienestar',
                                        style: FlutterFlowTheme.of(context)
                                            .labelLarge
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelLarge
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelLarge
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: _showReminderDialog,
                                    child: wrapWithModel(
                                      model: _model.profileMenuItemModel1,
                                      updateCallback: () => safeSetState(() {}),
                                      child: ProfileMenuItemWidget(
                                        icon: Icon(
                                          Icons.notifications_active_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 22.0,
                                        ),
                                        title: 'Recordatorios',
                                        subtitle: 'Configura alertas diarias',
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: _showPrivacyDialog,
                                    child: wrapWithModel(
                                      model: _model.profileMenuItemModel2,
                                      updateCallback: () => safeSetState(() {}),
                                      child: ProfileMenuItemWidget(
                                        icon: Icon(
                                          Icons.security_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 22.0,
                                        ),
                                        title: 'Privacidad y Datos',
                                        subtitle: 'Gestiona tu seguridad',
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () => context.pushNamed(
                                        MyGoalsWidget.routeName),
                                    child: wrapWithModel(
                                      model: _model.profileMenuItemModel3,
                                      updateCallback: () => safeSetState(() {}),
                                      child: ProfileMenuItemWidget(
                                        icon: Icon(
                                          Icons.favorite_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 22.0,
                                        ),
                                        title: 'Mis Objetivos',
                                        subtitle: 'Metas de autocuidado',
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 16.0,
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        4.0, 0.0, 0.0, 8.0),
                                    child: Container(
                                      child: Text(
                                        'Soporte',
                                        style: FlutterFlowTheme.of(context)
                                            .labelLarge
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelLarge
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelLarge
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.profileMenuItemModel4,
                                    updateCallback: () => safeSetState(() {}),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () => context.pushNamed(
                                          HelpCenterWidget.routeName),
                                      child: ProfileMenuItemWidget(
                                        icon: Icon(
                                          Icons.help_outline_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 22.0,
                                        ),
                                        title: 'Centro de Ayuda',
                                        subtitle: 'Preguntas frecuentes',
                                      ),
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.profileMenuItemModel5,
                                    updateCallback: () => safeSetState(() {}),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () => context.pushNamed(
                                          SupportContactWidget.routeName),
                                      child: ProfileMenuItemWidget(
                                        icon: Icon(
                                          Icons.contact_support_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 22.0,
                                        ),
                                        title: 'Contacto de Apoyo',
                                        subtitle: 'Recursos de emergencia',
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 24.0,
                                  ),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      final confirmDialogResponse =
                                          await showDialog<bool>(
                                                context: context,
                                                builder: (alertDialogContext) {
                                                  return AlertDialog(
                                                    title:
                                                        Text('Cerrar sesión'),
                                                    content: Text(
                                                        '¿Deseas salir de tu cuenta?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                alertDialogContext,
                                                                false),
                                                        child: Text('Cancelar'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                alertDialogContext,
                                                                true),
                                                        child: Text(
                                                            'Cerrar sesión'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ) ??
                                              false;
                                      if (!confirmDialogResponse) return;

                                      GoRouter.of(context).prepareAuthEvent();
                                      await authManager.signOut();
                                      if (!context.mounted) return;
                                      GoRouter.of(context)
                                          .clearRedirectLocation();
                                      context.goNamedAuth(
                                          TestScreenWidget.routeName,
                                          context.mounted);
                                    },
                                    child: wrapWithModel(
                                      model: _model.buttonModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: ButtonWidget(
                                        icon: Icon(
                                          Icons.logout_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 24.0,
                                        ),
                                        iconPresent: true,
                                        iconEndPresent: false,
                                        content: 'Cerrar Sesión',
                                        variant: 'outline',
                                        size: 'medium',
                                        fullWidth: true,
                                        loading: false,
                                        disabled: false,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 32.0,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  wrapWithModel(
                    model: _model.bottomNavModel,
                    updateCallback: () => safeSetState(() {}),
                    child: BottomNav3Widget(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
