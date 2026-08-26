import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/validators.dart' as validators;
import 'dart:ui';
import '/index.dart';
import 'login_screen_widget.dart' show LoginScreenWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginScreenModel extends FlutterFlowModel<LoginScreenWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
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

  @override
  void initState(BuildContext context) {
    correoElectronicoTextControllerValidator =
        _correoElectronicoTextControllerValidator;
    contrasenaVisibility = false;
    contrasenaTextControllerValidator = _contrasenaTextControllerValidator;
  }

  @override
  void dispose() {
    correoElectronicoFocusNode?.dispose();
    correoElectronicoTextController?.dispose();

    contrasenaFocusNode?.dispose();
    contrasenaTextController?.dispose();
  }
}
