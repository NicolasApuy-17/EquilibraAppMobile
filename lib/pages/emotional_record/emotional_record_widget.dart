import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/bottom_nav/bottom_nav_widget.dart';
import '/components/button/button_widget.dart';
import '/components/emotion_pill_clean_widget.dart';
import '/components/slider/slider_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'emotional_record_model.dart';
export 'emotional_record_model.dart';

class EmotionalRecordWidget extends StatefulWidget {
  const EmotionalRecordWidget({super.key});

  static String routeName = 'EmotionalRecord';
  static String routePath = '/emotionalRecord';

  @override
  State<EmotionalRecordWidget> createState() => _EmotionalRecordWidgetState();
}

class _EmotionalRecordWidgetState extends State<EmotionalRecordWidget> {
  late EmotionalRecordModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmotionalRecordModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<String?> _promptForLabel({
    required String title,
    required String hint,
  }) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          title: Text(
            title,
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  color: FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 40,
            style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  TextStyle(color: FlutterFlowTheme.of(context).secondaryText),
            ),
            onSubmitted: (value) =>
                Navigator.of(dialogContext).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                    color: FlutterFlowTheme.of(context).secondaryText),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: Text(
                'Agregar',
                style: TextStyle(color: FlutterFlowTheme.of(context).primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDuplicateSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
        ),
        duration: Duration(milliseconds: 3000),
        backgroundColor: FlutterFlowTheme.of(context).alternate,
      ),
    );
  }

  Future<void> _showAddEmotionDialog() async {
    final label = await _promptForLabel(
      title: 'Agregar estado de ánimo',
      hint: 'Ej. Ansioso',
    );
    if (label == null || label.isEmpty || !context.mounted) return;

    final added = _model.addCustomEmotion(label);
    if (!added) {
      _showDuplicateSnackBar('Ese estado de ánimo ya está en la lista.');
      return;
    }
    safeSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                            shape: BoxShape.rectangle,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                    'Registro Emocional',
                                    style: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          font: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleLarge
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleLarge
                                                  .fontStyle,
                                          lineHeight: 1.4,
                                        ),
                                  ),
                                  Container(
                                    width: 40.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              24.0, 0.0, 24.0, 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '¿Cómo te sientes ahora?',
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          font: GoogleFonts.outfit(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                          lineHeight: 1.45,
                                        ),
                                  ),
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    direction: Axis.horizontal,
                                    runAlignment: WrapAlignment.center,
                                    verticalDirection: VerticalDirection.down,
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 88.0,
                                        height: 40.0,
                                        decoration: BoxDecoration(),
                                        child: wrapWithModel(
                                          model: _model.emotionPillCleanModel1,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: EmotionPillCleanWidget(
                                            label: 'Alegría',
                                            isSelected:
                                                _model.selectedEmotion ==
                                                    'Alegría',
                                            onTap: () async {
                                              if (_model.selectedEmotion ==
                                                  'Alegría') {
                                                _model.selectedEmotion = '';
                                                safeSetState(() {});
                                              } else {
                                                _model.selectedEmotion =
                                                    'Alegría';
                                                safeSetState(() {});
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 88.0,
                                        height: 40.0,
                                        decoration: BoxDecoration(),
                                        child: wrapWithModel(
                                          model: _model.emotionPillCleanModel2,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: EmotionPillCleanWidget(
                                            label: 'Miedo',
                                            isSelected:
                                                _model.selectedEmotion ==
                                                    'Miedo',
                                            onTap: () async {
                                              if (_model.selectedEmotion ==
                                                  'Miedo') {
                                                _model.selectedEmotion = '';
                                                safeSetState(() {});
                                              } else {
                                                _model.selectedEmotion =
                                                    'Miedo';
                                                safeSetState(() {});
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 88.0,
                                        height: 40.0,
                                        decoration: BoxDecoration(),
                                        child: wrapWithModel(
                                          model: _model.emotionPillCleanModel3,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: EmotionPillCleanWidget(
                                            label: 'Tristeza',
                                            isSelected:
                                                _model.selectedEmotion ==
                                                    'Tristeza',
                                            onTap: () async {
                                              if (_model.selectedEmotion ==
                                                  'Tristeza') {
                                                _model.selectedEmotion = '';
                                                safeSetState(() {});
                                              } else {
                                                _model.selectedEmotion =
                                                    'Tristeza';
                                                safeSetState(() {});
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 88.0,
                                        height: 40.0,
                                        decoration: BoxDecoration(),
                                        child: wrapWithModel(
                                          model: _model.emotionPillCleanModel4,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: EmotionPillCleanWidget(
                                            label: 'Enojo',
                                            isSelected:
                                                _model.selectedEmotion ==
                                                    'Enojo',
                                            onTap: () async {
                                              if (_model.selectedEmotion ==
                                                  'Enojo') {
                                                _model.selectedEmotion = '';
                                                safeSetState(() {});
                                              } else {
                                                _model.selectedEmotion =
                                                    'Enojo';
                                                safeSetState(() {});
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 40.0,
                                        decoration: BoxDecoration(),
                                        child: wrapWithModel(
                                          model: _model.emotionPillCleanModel5,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: EmotionPillCleanWidget(
                                            label: 'Vergüenza',
                                            isSelected:
                                                _model.selectedEmotion ==
                                                    'Vergüenza',
                                            onTap: () async {
                                              if (_model.selectedEmotion ==
                                                  'Vergüenza') {
                                                _model.selectedEmotion = '';
                                                safeSetState(() {});
                                              } else {
                                                _model.selectedEmotion =
                                                    'Vergüenza';
                                                safeSetState(() {});
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 40.0,
                                        decoration: BoxDecoration(),
                                        child: wrapWithModel(
                                          model: _model.emotionPillCleanModel6,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: EmotionPillCleanWidget(
                                            label: 'Tranquilo',
                                            isSelected:
                                                _model.selectedEmotion ==
                                                    'Tranquilo',
                                            onTap: () async {
                                              if (_model.selectedEmotion ==
                                                  'Tranquilo') {
                                                _model.selectedEmotion = '';
                                                safeSetState(() {});
                                              } else {
                                                _model.selectedEmotion =
                                                    'Tranquilo';
                                                safeSetState(() {});
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      ..._model.customEmotions.map(
                                        (emotionLabel) => GestureDetector(
                                          key: ValueKey(emotionLabel),
                                          onLongPress: () {
                                            _model.removeCustomEmotion(
                                                emotionLabel);
                                            safeSetState(() {});
                                          },
                                          child: EmotionPillCleanWidget(
                                            label: emotionLabel,
                                            isSelected:
                                                _model.selectedEmotion ==
                                                    emotionLabel,
                                            onTap: () async {
                                              if (_model.selectedEmotion ==
                                                  emotionLabel) {
                                                _model.selectedEmotion = '';
                                              } else {
                                                _model.selectedEmotion =
                                                    emotionLabel;
                                              }
                                              safeSetState(() {});
                                            },
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        onTap: _showAddEmotionDialog,
                                        child: Container(
                                          constraints:
                                              BoxConstraints(minWidth: 88.0),
                                          height: 40.0,
                                          padding: EdgeInsetsDirectional
                                              .fromSTEB(12.0, 0.0, 12.0, 0.0),
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(
                                                    context)
                                                .tertiary,
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            border: Border.all(
                                              color: FlutterFlowTheme.of(
                                                      context)
                                                  .primary,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_rounded,
                                                color: FlutterFlowTheme.of(
                                                        context)
                                                    .primary,
                                                size: 16.0,
                                              ),
                                              Text(
                                                'Agregar',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.outfit(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primary,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                            ].divide(SizedBox(width: 4.0)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ].divide(SizedBox(height: 16.0)),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Intensidad',
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMedium
                                                      .fontStyle,
                                              lineHeight: 1.45,
                                            ),
                                      ),
                                      Text(
                                        '${_model.intensityValue.round()}/10',
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .onSurface,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMedium
                                                      .fontStyle,
                                              lineHeight: 1.45,
                                            ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(24.0),
                                      shape: BoxShape.rectangle,
                                      border: Border.all(
                                        color: Color(0x401D1D1B),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 0.0, 16.0, 0.0),
                                      child: Container(
                                        child: wrapWithModel(
                                          model: _model.sliderModel,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: SliderWidget(
                                            label: '',
                                            labelPresent: false,
                                            description: '',
                                            descriptionPresent: false,
                                            valueLabel: '',
                                            valueLabelPresent: false,
                                            step: 1.0,
                                            divisions: 9,
                                            valuePercentage: 1.0,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            variant: 'Material',
                                            disabled: false,
                                            showTicks: false,
                                            onValueChanged: (value) async {
                                              _model.intensityValue = value;
                                              safeSetState(() {});
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 16.0)),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    '¿Qué ocurrió hoy?',
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          font: GoogleFonts.outfit(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                          lineHeight: 1.45,
                                        ),
                                  ),
                                  wrapWithModel(
                                    model: _model.textFieldModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: TextFieldWidget(
                                      label: 'Descripción',
                                      labelPresent: true,
                                      helper: '',
                                      helperPresent: false,
                                      leadingIconPresent: false,
                                      trailingIconPresent: false,
                                      hint: 'Escribe brevemente lo que pasó...',
                                      value: '',
                                      onChange: '',
                                      onSubmit: '',
                                      variant: 'outlined',
                                      error: false,
                                    ),
                                  ),
                                ].divide(SizedBox(height: 16.0)),
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
                                  if (_model.isSaving) return;
                                  if (_model.selectedEmotion == null ||
                                      _model.selectedEmotion!.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Selecciona una emoción antes de guardar.',
                                          style: TextStyle(
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                          ),
                                        ),
                                        duration: Duration(milliseconds: 3000),
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .alternate,
                                      ),
                                    );
                                    return;
                                  }

                                  safeSetState(() => _model.isSaving = true);
                                  try {
                                    final description = _model.textFieldModel
                                            .inputTextController?.text
                                            .trim() ??
                                        '';
                                    await RecordsRecord.collection.doc().set(
                                          createRecordsRecordData(
                                            emotion: _model.selectedEmotion,
                                            description: description,
                                            timestamp: getCurrentTimestamp,
                                            intensity: _model.intensityValue,
                                            userRef: currentUserReference,
                                          ),
                                        );

                                    if (!context.mounted) return;
                                    _model.resetForm();
                                    safeSetState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Registro guardado correctamente.',
                                          style: TextStyle(
                                            color: FlutterFlowTheme.of(context)
                                                .onPrimary,
                                          ),
                                        ),
                                        duration: Duration(milliseconds: 3000),
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .success,
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'No se pudo guardar el registro. Intenta nuevamente.',
                                          style: TextStyle(
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                          ),
                                        ),
                                        duration: Duration(milliseconds: 3000),
                                        backgroundColor:
                                            FlutterFlowTheme.of(context).error,
                                      ),
                                    );
                                  } finally {
                                    if (context.mounted) {
                                      safeSetState(
                                          () => _model.isSaving = false);
                                    }
                                  }
                                },
                                child: wrapWithModel(
                                  model: _model.buttonModel,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ButtonWidget(
                                    iconPresent: false,
                                    iconEndPresent: false,
                                    content: 'Guardar Registro',
                                    variant: 'primary',
                                    size: 'large',
                                    fullWidth: true,
                                    loading: _model.isSaving,
                                    disabled: _model.isSaving,
                                  ),
                                ),
                              ),
                              Container(
                                height: 32.0,
                              ),
                            ].divide(SizedBox(height: 32.0)),
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
                child: BottomNavWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
