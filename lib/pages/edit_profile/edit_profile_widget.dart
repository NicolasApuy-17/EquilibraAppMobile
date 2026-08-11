import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Lets the user update their basic profile info: display name, phone
/// number, and profile photo (via an image URL, since this project has no
/// image upload / storage dependency wired up yet).
class EditProfileWidget extends StatefulWidget {
  const EditProfileWidget({super.key});

  static String routeName = 'EditProfile';
  static String routePath = '/editProfile';

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _photoUrlController;

  bool _isSaving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: currentUserDisplayName);
    _phoneController = TextEditingController(text: currentPhoneNumber);
    _photoUrlController = TextEditingController(text: currentUserPhoto);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'El nombre no puede estar vacío.');
      return;
    }
    setState(() {
      _isSaving = true;
      _errorText = null;
    });
    try {
      await updateUserProfile(
        displayName: name,
        phoneNumber: _phoneController.text.trim(),
        photoUrl: _photoUrlController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil actualizado correctamente.')),
        );
        context.safePop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = 'No se pudo guardar tu perfil. Intenta nuevamente.';
        });
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.all(24.0),
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
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 24.0,
                      ),
                      onPressed: () => context.safePop(),
                    ),
                    Text(
                      'Editar Perfil',
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            font: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold),
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(width: 40.0),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: AnimatedBuilder(
                          animation: _photoUrlController,
                          builder: (context, _) => _AvatarPreview(
                            photoUrl: _photoUrlController.text.trim(),
                            fallbackText: _nameController.text.isNotEmpty
                                ? _nameController.text
                                : currentUserEmail,
                          ),
                        ),
                      ),
                      SizedBox(height: 28.0),
                      _FieldLabel('Nombre completo'),
                      _AppTextField(
                        controller: _nameController,
                        hintText: 'Tu nombre',
                        icon: Icons.person_outline_rounded,
                      ),
                      SizedBox(height: 16.0),
                      _FieldLabel('Teléfono'),
                      _AppTextField(
                        controller: _phoneController,
                        hintText: 'Ej. +51 987 654 321',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 16.0),
                      _FieldLabel('URL de foto de perfil (opcional)'),
                      _AppTextField(
                        controller: _photoUrlController,
                        hintText: 'https://...',
                        icon: Icons.image_outlined,
                        keyboardType: TextInputType.url,
                        onChanged: (_) => setState(() {}),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(4.0, 6.0, 4.0, 0.0),
                        child: Text(
                          'Pega el enlace de una imagen para usarla como tu '
                          'foto de perfil. Si lo dejas vacío, se mostrarán '
                          'tus iniciales.',
                          style:
                              FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.outfit(),
                                    color:
                                        FlutterFlowTheme.of(context)
                                            .secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                      if (_errorText != null)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              4.0, 16.0, 4.0, 0.0),
                          child: Text(
                            _errorText!,
                            style:
                                FlutterFlowTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.outfit(),
                                      color: FlutterFlowTheme.of(context).error,
                                      letterSpacing: 0.0,
                                    ),
                          ),
                        ),
                      SizedBox(height: 28.0),
                      InkWell(
                        onTap: _isSaving ? null : _submit,
                        child: Container(
                          height: 52.0,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primary,
                            borderRadius: BorderRadius.circular(26.0),
                          ),
                          child: _isSaving
                              ? SizedBox(
                                  width: 22.0,
                                  height: 22.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation(
                                        FlutterFlowTheme.of(context)
                                            .onPrimary),
                                  ),
                                )
                              : Text(
                                  'Guardar cambios',
                                  style: FlutterFlowTheme.of(context)
                                      .labelLarge
                                      .override(
                                        font: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold),
                                        color: FlutterFlowTheme.of(context)
                                            .onPrimary,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 0.0, 6.0),
      child: Text(
        text,
        style: FlutterFlowTheme.of(context).labelMedium.override(
              font: GoogleFonts.outfit(),
              color: FlutterFlowTheme.of(context).primaryText,
              letterSpacing: 0.0,
            ),
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.outfit(),
            color: FlutterFlowTheme.of(context).primaryText,
            letterSpacing: 0.0,
          ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.outfit(),
              color: FlutterFlowTheme.of(context).secondaryText,
              letterSpacing: 0.0,
            ),
        prefixIcon: Icon(
          icon,
          color: FlutterFlowTheme.of(context).secondaryText,
          size: 20.0,
        ),
        isDense: true,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
        filled: true,
        fillColor: FlutterFlowTheme.of(context).secondaryBackground,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: FlutterFlowTheme.of(context).alternate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary),
        ),
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({
    required this.photoUrl,
    required this.fallbackText,
  });

  final String photoUrl;
  final String fallbackText;

  bool get _hasValidUrl =>
      photoUrl.isNotEmpty &&
      (photoUrl.startsWith('http://') || photoUrl.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999.0),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: FlutterFlowTheme.of(context).primary20,
          width: 4.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9999.0),
          child: _hasValidUrl
              ? CachedNetworkImage(
                  imageUrl: photoUrl,
                  width: 80.0,
                  height: 80.0,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => _InitialsCircle(
                    text: fallbackText,
                  ),
                  placeholder: (context, url) => _InitialsCircle(
                    text: fallbackText,
                  ),
                )
              : _InitialsCircle(text: fallbackText),
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
      width: 80.0,
      height: 80.0,
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
              fontSize: 30.4,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
            ),
        overflow: TextOverflow.clip,
      ),
    );
  }
}
