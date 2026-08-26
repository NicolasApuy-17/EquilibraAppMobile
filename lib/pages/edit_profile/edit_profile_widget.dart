import 'dart:io';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/error_messages.dart';
import '/utils/validators.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

/// Lets the user update their basic profile info: display name, phone
/// number, and profile photo. The photo is picked from the device's own
/// gallery, uploaded to Firebase Storage under this user's folder, and the
/// resulting download URL is what gets saved to their profile.
class EditProfileWidget extends StatefulWidget {
  const EditProfileWidget({super.key});

  static String routeName = 'EditProfile';
  static String routePath = '/editProfile';

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String? _errorText;

  // Local path of the picked image (shown immediately while it uploads).
  File? _pickedPhotoFile;
  // Firebase Storage download URL once the picked photo finishes uploading.
  // Null means "no new photo was picked" — the existing one is kept as-is.
  String? _uploadedPhotoUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: currentUserDisplayName);
    _phoneController = TextEditingController(text: currentPhoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    final userRef = currentUserReference;
    if (userRef == null) return;

    XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = 'No se pudo abrir la galería. Intenta nuevamente.';
      });
      return;
    }
    if (picked == null || !mounted) return;

    final file = File(picked.path);
    setState(() {
      _pickedPhotoFile = file;
      _isUploadingPhoto = true;
      _errorText = null;
    });

    try {
      final storageRef = FirebaseStorage.instance
          .ref('users/${userRef.id}/profile_photo.jpg');
      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();
      if (!mounted) return;
      setState(() {
        _uploadedPhotoUrl = downloadUrl;
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() {
        _pickedPhotoFile = null;
        _errorText = e.code == 'unauthorized'
            ? 'No tienes permiso para subir esta imagen.'
            : genericSaveErrorMessage('subir la imagen');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pickedPhotoFile = null;
        _errorText = genericSaveErrorMessage('subir la imagen');
      });
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isUploadingPhoto) {
      setState(() => _errorText = 'Espera a que termine de subirse la foto.');
      return;
    }
    setState(() {
      _isSaving = true;
      _errorText = null;
    });
    try {
      await updateUserProfile(
        displayName: normalizeWhitespace(_nameController.text),
        phoneNumber: _phoneController.text.trim(),
        photoUrl: _uploadedPhotoUrl,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil actualizado correctamente.')),
        );
        context.safePop();
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        setState(() {
          _errorText = e.code == 'permission-denied'
              ? 'No tienes permiso para actualizar este perfil.'
              : genericSaveErrorMessage('guardar tu perfil');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = genericSaveErrorMessage('guardar tu perfil');
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
                    Expanded(
                      child: Text(
                        'Editar Perfil',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            FlutterFlowTheme.of(context).titleLarge.override(
                                  font: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold),
                                  color: FlutterFlowTheme.of(context)
                                      .primaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    SizedBox(width: 40.0),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 24.0),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: _AvatarPicker(
                          photoUrl: _uploadedPhotoUrl ?? currentUserPhoto,
                          localFile: _pickedPhotoFile,
                          isUploading: _isUploadingPhoto,
                          fallbackText: _nameController.text.isNotEmpty
                              ? _nameController.text
                              : currentUserEmail,
                          onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 10.0, 0.0, 0.0),
                          child: Text(
                            'Toca la foto para elegir una nueva desde tu galería.',
                            textAlign: TextAlign.center,
                            style:
                                FlutterFlowTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.outfit(),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                          ),
                        ),
                      ),
                      SizedBox(height: 28.0),
                      _FieldLabel('Nombre completo'),
                      _AppTextField(
                        controller: _nameController,
                        hintText: 'Tu nombre',
                        icon: Icons.person_outline_rounded,
                        validator: validateFullName,
                      ),
                      SizedBox(height: 16.0),
                      _FieldLabel('Teléfono'),
                      _AppTextField(
                        controller: _phoneController,
                        hintText: 'Ej. +51 987 654 321',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            validatePhone(value, required: false),
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
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
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

/// Tappable avatar that opens the device gallery and shows an upload
/// progress spinner while the picked photo is being saved.
class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.photoUrl,
    required this.localFile,
    required this.isUploading,
    required this.fallbackText,
    required this.onTap,
  });

  final String photoUrl;
  final File? localFile;
  final bool isUploading;
  final String fallbackText;
  final VoidCallback? onTap;

  bool get _hasValidUrl =>
      photoUrl.isNotEmpty &&
      (photoUrl.startsWith('http://') || photoUrl.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
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
                child: localFile != null
                    ? Image.file(
                        localFile!,
                        width: 80.0,
                        height: 80.0,
                        fit: BoxFit.cover,
                      )
                    : (_hasValidUrl
                        ? CachedNetworkImage(
                            imageUrl: photoUrl,
                            width: 80.0,
                            height: 80.0,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                _InitialsCircle(text: fallbackText),
                            placeholder: (context, url) =>
                                _InitialsCircle(text: fallbackText),
                          )
                        : _InitialsCircle(text: fallbackText)),
              ),
            ),
          ),
          if (isUploading)
            Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            )
          else
            Positioned(
              bottom: 0.0,
              right: 0.0,
              child: Container(
                width: 28.0,
                height: 28.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    width: 2.0,
                  ),
                ),
                child: Icon(
                  Icons.photo_camera_rounded,
                  color: FlutterFlowTheme.of(context).onPrimary,
                  size: 14.0,
                ),
              ),
            ),
        ],
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
