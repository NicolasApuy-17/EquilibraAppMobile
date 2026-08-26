import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/behavior_chip/behavior_chip_widget.dart';
import '/components/bottom_nav/bottom_nav_widget.dart';
import '/components/button/button_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'behavioral_record_model.dart';
export 'behavioral_record_model.dart';

class BehavioralRecordWidget extends StatefulWidget {
  const BehavioralRecordWidget({super.key});

  static String routeName = 'BehavioralRecord';
  static String routePath = '/behavioralRecord';

  @override
  State<BehavioralRecordWidget> createState() =>
      _BehavioralRecordWidgetState();
}

class _BehavioralRecordWidgetState extends State<BehavioralRecordWidget> {
  late BehavioralRecordModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BehavioralRecordModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _showAddBehaviorTypeDialog() async {
    final controller = TextEditingController();
    String? errorText;
    final label = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            void trySubmit() {
              final error = validateLabel(controller.text);
              if (error != null) {
                setDialogState(() => errorText = error);
                return;
              }
              Navigator.of(dialogContext).pop(controller.text.trim());
            }

            return AlertDialog(
              backgroundColor:
                  FlutterFlowTheme.of(context).secondaryBackground,
              title: Text(
                'Agregar conducta',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    maxLength: 30,
                    style: TextStyle(
                        color: FlutterFlowTheme.of(context).primaryText),
                    decoration: InputDecoration(
                      hintText: 'Ej. Meditación',
                      hintStyle: TextStyle(
                          color: FlutterFlowTheme.of(context).secondaryText),
                    ),
                    onChanged: (_) {
                      if (errorText != null) {
                        setDialogState(() => errorText = null);
                      }
                    },
                    onSubmitted: (_) => trySubmit(),
                  ),
                  if (errorText != null)
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          4.0, 0.0, 4.0, 0.0),
                      child: Text(
                        errorText!,
                        style: TextStyle(
                          color: FlutterFlowTheme.of(context).error,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                ],
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
                  onPressed: trySubmit,
                  child: Text(
                    'Agregar',
                    style:
                        TextStyle(color: FlutterFlowTheme.of(context).primary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    if (label == null || label.isEmpty || !context.mounted) return;

    final added = _model.addCustomBehaviorType(label);
    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Esa conducta ya está en la lista.',
            style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
          ),
          duration: Duration(milliseconds: 3000),
          backgroundColor: FlutterFlowTheme.of(context).alternate,
        ),
      );
      return;
    }
    safeSetState(() {});
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: FlutterFlowTheme.of(context).titleMedium.override(
            font: GoogleFonts.outfit(
              fontWeight: FlutterFlowTheme.of(context).titleMedium.fontWeight,
              fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
            ),
            color: FlutterFlowTheme.of(context).primaryText,
            letterSpacing: 0.0,
            fontWeight: FlutterFlowTheme.of(context).titleMedium.fontWeight,
            fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
            lineHeight: 1.45,
          ),
    );
  }

  Widget _addChip(String label, VoidCallback onTap) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(24.0),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 4.0, 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(24.0),
            shape: BoxShape.rectangle,
            border: Border.all(
              color: FlutterFlowTheme.of(context).primary,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(8.0, 16.0, 8.0, 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_rounded,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 18.0,
                ),
                Text(
                  label,
                  style: FlutterFlowTheme.of(context).labelMedium.override(
                        font: GoogleFonts.outfit(),
                        color: FlutterFlowTheme.of(context).primary,
                        letterSpacing: 0.0,
                      ),
                ),
              ].divide(SizedBox(width: 4.0)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _model.selectedConfig;

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
                                    color:
                                        FlutterFlowTheme.of(context)
                                            .primaryText,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    context.safePop();
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    'Registro de Conductas',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          font: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FlutterFlowTheme.of(
                                                    context)
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
                                ),
                                Container(
                                  width: 40.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              24.0, 0.0, 24.0, 24.0),
                          child: Form(
                            key: _model.formKey,
                            autovalidateMode: AutovalidateMode.disabled,
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
                                  _sectionTitle('¿Qué conducta registras?'),
                                  Text(
                                    'Este registro es independiente de tus '
                                    'registros emocionales.',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          font: GoogleFonts.outfit(),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  Wrap(
                                    spacing: 0.0,
                                    runSpacing: 0.0,
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.start,
                                    direction: Axis.horizontal,
                                    runAlignment: WrapAlignment.start,
                                    verticalDirection: VerticalDirection.down,
                                    clipBehavior: Clip.none,
                                    children: [
                                      for (final type
                                          in kPredeterminedBehaviorTypes)
                                        BehaviorChipWidget(
                                          selected:
                                              _model.selectedBehaviorType ==
                                                  type.label,
                                          onTap: () async {
                                            _model.selectBehaviorType(
                                                type.label);
                                            safeSetState(() {});
                                          },
                                          icon: Icon(
                                            type.icon,
                                            color: FlutterFlowTheme.of(
                                                    context)
                                                .primaryText,
                                            size: 18.0,
                                          ),
                                          label: type.label,
                                        ),
                                      for (final label
                                          in _model.customBehaviorTypes)
                                        GestureDetector(
                                          key: ValueKey(label),
                                          onLongPress: () {
                                            _model.removeCustomBehaviorType(
                                                label);
                                            safeSetState(() {});
                                          },
                                          child: BehaviorChipWidget(
                                            selected:
                                                _model.selectedBehaviorType ==
                                                    label,
                                            onTap: () async {
                                              _model.selectBehaviorType(label);
                                              safeSetState(() {});
                                            },
                                            icon: Icon(
                                              Icons.label_rounded,
                                              color: FlutterFlowTheme.of(
                                                      context)
                                                  .primaryText,
                                              size: 18.0,
                                            ),
                                            label: label,
                                          ),
                                        ),
                                      _addChip(
                                          'Agregar', _showAddBehaviorTypeDialog),
                                    ],
                                  ),
                                ].divide(SizedBox(height: 16.0)),
                              ),
                              if (config != null) ...[
                                Container(height: 24.0),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _sectionTitle('¿Cómo estuvo?'),
                                    Wrap(
                                      spacing: 0.0,
                                      runSpacing: 0.0,
                                      alignment: WrapAlignment.start,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.start,
                                      direction: Axis.horizontal,
                                      runAlignment: WrapAlignment.start,
                                      verticalDirection:
                                          VerticalDirection.down,
                                      clipBehavior: Clip.none,
                                      children: [
                                        for (final option
                                            in config.statusOptions)
                                          BehaviorChipWidget(
                                            selected: _model.selectedValue ==
                                                option.label,
                                            onTap: () async {
                                              safeSetState(() {
                                                _model.selectedValue =
                                                    _model.selectedValue ==
                                                            option.label
                                                        ? null
                                                        : option.label;
                                              });
                                            },
                                            icon: Icon(
                                              option.icon,
                                              color: FlutterFlowTheme.of(
                                                      context)
                                                  .primaryText,
                                              size: 18.0,
                                            ),
                                            label: option.label,
                                          ),
                                      ],
                                    ),
                                  ].divide(SizedBox(height: 16.0)),
                                ),
                                if (config.quantityLabel != null) ...[
                                  Container(height: 24.0),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _sectionTitle(config.quantityLabel!),
                                      wrapWithModel(
                                        model: _model.quantityFieldModel,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: TextFieldWidget(
                                          label: '',
                                          labelPresent: false,
                                          helper: '',
                                          helperPresent: false,
                                          leadingIconPresent: false,
                                          trailingIconPresent: false,
                                          hint: config.quantityHint ??
                                              (config.quantityUnit != null
                                                  ? 'Cantidad en ${config.quantityUnit}'
                                                  : 'Cantidad (opcional)'),
                                          value: '',
                                          onChange: '',
                                          onSubmit: '',
                                          variant: 'outlined',
                                          error: false,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(
                                                  decimal: true),
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 8.0)),
                                  ),
                                ],
                                Container(height: 24.0),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _sectionTitle('Notas (opcional)'),
                                    wrapWithModel(
                                      model: _model.notesFieldModel,
                                      updateCallback: () =>
                                          safeSetState(() {}),
                                      child: TextFieldWidget(
                                        label: '',
                                        labelPresent: false,
                                        helper: '',
                                        helperPresent: false,
                                        leadingIconPresent: false,
                                        trailingIconPresent: false,
                                        hint: 'Algo más que quieras anotar...',
                                        value: '',
                                        onChange: '',
                                        onSubmit: '',
                                        variant: 'outlined',
                                        error: false,
                                        minLines: 3,
                                        maxLines: 6,
                                      ),
                                    ),
                                  ].divide(SizedBox(height: 8.0)),
                                ),
                              ],
                              Container(height: 32.0),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  if (_model.isSaving) return;
                                  if (_model.formKey.currentState != null &&
                                      !_model.formKey.currentState!
                                          .validate()) {
                                    return;
                                  }
                                  if (_model.selectedBehaviorType == null ||
                                      _model.selectedBehaviorType!.isEmpty) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Selecciona una conducta antes de guardar.',
                                          style: TextStyle(
                                            color: FlutterFlowTheme.of(
                                                    context)
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
                                  if (_model.selectedValue == null ||
                                      _model.selectedValue!.isEmpty) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Indica cómo estuvo esa conducta hoy.',
                                          style: TextStyle(
                                            color: FlutterFlowTheme.of(
                                                    context)
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
                                    final quantityText = _model
                                            .quantityFieldModel
                                            .inputTextController
                                            ?.text
                                            .trim() ??
                                        '';
                                    final notesText = _model.notesFieldModel
                                            .inputTextController?.text
                                            .trim() ??
                                        '';
                                    await BehavioralRecordsRecord.collection
                                        .doc()
                                        .set(
                                      createBehavioralRecordsRecordData(
                                        date: getCurrentTimestamp,
                                        behaviorType:
                                            _model.selectedBehaviorType,
                                        value: _model.selectedValue,
                                        quantity: quantityText.isEmpty
                                            ? null
                                            : double.tryParse(
                                                quantityText.replaceAll(
                                                    ',', '.')),
                                        notes:
                                            notesText.isEmpty ? null : notesText,
                                        createdAt: getCurrentTimestamp,
                                        userRef: currentUserReference,
                                      ),
                                    );

                                    if (!context.mounted) return;
                                    _model.resetForm();
                                    safeSetState(() {});
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Registro guardado correctamente.',
                                          style: TextStyle(
                                            color: FlutterFlowTheme.of(
                                                    context)
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
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'No se pudo guardar el registro. Intenta nuevamente.',
                                          style: TextStyle(
                                            color: FlutterFlowTheme.of(
                                                    context)
                                                .primaryText,
                                          ),
                                        ),
                                        duration: Duration(milliseconds: 3000),
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .error,
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
                              Container(height: 32.0),
                            ],
                          ),
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
