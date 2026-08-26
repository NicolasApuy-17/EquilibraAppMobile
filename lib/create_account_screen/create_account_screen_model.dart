import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/validators.dart' as validators;
import 'dart:ui';
import '/index.dart';
import 'create_account_screen_widget.dart' show CreateAccountScreenWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CreateAccountScreenModel
    extends FlutterFlowModel<CreateAccountScreenWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for NombreCompleto widget.
  FocusNode? nombreCompletoFocusNode;
  TextEditingController? nombreCompletoTextController;
  String? Function(BuildContext, String?)?
      nombreCompletoTextControllerValidator;
  String? _nombreCompletoTextControllerValidator(
      BuildContext context, String? val) {
    return validators.validateFullName(val);
  }

  // State field(s) for CorreoElectronico widget.
  FocusNode? correoElectronicoFocusNode;
  TextEditingController? correoElectronicoTextController;
  String? Function(BuildContext, String?)?
      correoElectronicoTextControllerValidator;
  String? _correoElectronicoTextControllerValidator(
      BuildContext context, String? val) {
    return validators.validateEmail(val);
  }

  // State field(s) for Contrasena widget.
  FocusNode? contrasenaFocusNode;
  TextEditingController? contrasenaTextController;
  late bool contrasenaVisibility;
  String? Function(BuildContext, String?)? contrasenaTextControllerValidator;
  String? _contrasenaTextControllerValidator(
      BuildContext context, String? val) {
    return validators.validatePassword(val);
  }

  // State field(s) for ConfirmarContrasena widget.
  FocusNode? confirmarContrasenaFocusNode;
  TextEditingController? confirmarContrasenaTextController;
  late bool confirmarContrasenaVisibility;
  String? Function(BuildContext, String?)?
      confirmarContrasenaTextControllerValidator;
  String? _confirmarContrasenaTextControllerValidator(
      BuildContext context, String? val) {
    return validators.validatePasswordConfirmation(
      val,
      contrasenaTextController?.text ?? '',
    );
  }

  @override
  void initState(BuildContext context) {
    nombreCompletoTextControllerValidator =
        _nombreCompletoTextControllerValidator;
    correoElectronicoTextControllerValidator =
        _correoElectronicoTextControllerValidator;
    contrasenaVisibility = false;
    contrasenaTextControllerValidator = _contrasenaTextControllerValidator;
    confirmarContrasenaVisibility = false;
    confirmarContrasenaTextControllerValidator =
        _confirmarContrasenaTextControllerValidator;
  }

  @override
  void dispose() {
    nombreCompletoFocusNode?.dispose();
    nombreCompletoTextController?.dispose();

    correoElectronicoFocusNode?.dispose();
    correoElectronicoTextController?.dispose();

    contrasenaFocusNode?.dispose();
    contrasenaTextController?.dispose();

    confirmarContrasenaFocusNode?.dispose();
    confirmarContrasenaTextController?.dispose();
  }
}
