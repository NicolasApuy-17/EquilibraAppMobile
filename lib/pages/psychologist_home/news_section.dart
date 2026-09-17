import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/utils/error_messages.dart';
import '/utils/validators.dart';

/// Lets a psychologist publish short announcements ("novedades") that show
/// up as swipeable cards on their linked patients' home screen (see
/// `NewsCarouselWidget`). Mirrors the admin catalog's
/// list-plus-bottom-sheet-form pattern (`activities_tab.dart`) rather than
/// a dedicated route, since this is just one more self-contained section
/// of the psychologist's single-screen dashboard.
class PsychologistNewsSection extends StatelessWidget {
  const PsychologistNewsSection({super.key});

  Future<void> _openForm(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _NewsFormSheet(),
    );
  }

  Future<void> _delete(BuildContext context, NewsRecord news) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar noticia'),
            content: Text(
                '¿Eliminar "${news.title}"? Esta acción no se puede deshacer.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    try {
      await news.reference.delete();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(genericSaveErrorMessage('eliminar la noticia'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final myRef = currentUserReference;
    if (myRef == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.campaign_rounded, size: 18.0, color: theme.primary),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'Novedades',
                  style: theme.titleSmall.override(
                    font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    color: theme.primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _openForm(context),
                icon: const Icon(Icons.add_rounded, size: 18.0),
                label: const Text('Publicar'),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          StreamBuilder<List<NewsRecord>>(
            // Single equality filter -- no composite index needed. Sorted
            // client-side below, same tradeoff used throughout this
            // dashboard (see the comment on `_fetchPerPatient` above).
            stream: queryNewsRecord(
              queryBuilder: (newsRecord) =>
                  newsRecord.where('psychologistRef', isEqualTo: myRef),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final news = snapshot.data!
                ..sort((a, b) => (b.createdTime ?? DateTime(0))
                    .compareTo(a.createdTime ?? DateTime(0)));
              if (news.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Aún no has publicado ninguna novedad.',
                    style: theme.bodySmall.override(
                      font: GoogleFonts.outfit(),
                      color: theme.secondaryText,
                      letterSpacing: 0.0,
                    ),
                  ),
                );
              }
              return Column(
                children: news
                    .map((item) => _NewsRow(
                          news: item,
                          onDelete: () => _delete(context, item),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NewsRow extends StatelessWidget {
  const _NewsRow({required this.news, required this.onDelete});

  final NewsRecord news;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: news.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: news.imageUrl,
                    width: 44.0,
                    height: 44.0,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 44.0,
                    height: 44.0,
                    color: theme.primary.withValues(alpha: 0.08),
                    alignment: Alignment.center,
                    child: Icon(Icons.campaign_rounded,
                        color: theme.primary, size: 20.0),
                  ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                    color: theme.primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  news.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodySmall.override(
                    font: GoogleFonts.outfit(),
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded,
                color: theme.secondaryText, size: 20.0),
          ),
        ],
      ),
    );
  }
}

class _NewsFormSheet extends StatefulWidget {
  const _NewsFormSheet();

  @override
  State<_NewsFormSheet> createState() => _NewsFormSheetState();
}

class _NewsFormSheetState extends State<_NewsFormSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _linkController = TextEditingController();
  Uint8List? _imageBytes;
  String _imageMimeType = 'image/jpeg';
  bool _isSaving = false;
  String? _errorText;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _imageMimeType = picked.mimeType ?? 'image/jpeg';
    });
  }

  Future<void> _submit() async {
    final titleError = validateFreeText(
      _titleController.text,
      maxLength: 80,
      required: true,
      requiredMessage: 'El título es obligatorio.',
    );
    if (titleError != null) {
      setState(() => _errorText = titleError);
      return;
    }
    final contentError = validateFreeText(
      _contentController.text,
      maxLength: 1000,
      required: true,
      requiredMessage: 'Escribe el contenido de la noticia.',
    );
    if (contentError != null) {
      setState(() => _errorText = contentError);
      return;
    }
    final link = _linkController.text.trim();
    if (link.isNotEmpty && Uri.tryParse(link)?.hasScheme != true) {
      setState(() =>
          _errorText = 'Ingresa un enlace válido (debe incluir https://).');
      return;
    }

    final myRef = currentUserReference;
    if (myRef == null) return;

    setState(() {
      _isSaving = true;
      _errorText = null;
    });
    try {
      var imageUrl = '';
      if (_imageBytes != null) {
        final extension = _imageMimeType.split('/').last;
        final path =
            'news_images/${myRef.id}/${DateTime.now().millisecondsSinceEpoch}.$extension';
        final ref = FirebaseStorage.instance.ref(path);
        await ref.putData(
            _imageBytes!, SettableMetadata(contentType: _imageMimeType));
        imageUrl = await ref.getDownloadURL();
      }
      final data = createNewsRecordData(
        title: normalizeWhitespace(_titleController.text),
        content: _contentController.text.trim(),
        imageUrl: imageUrl,
        linkUrl: link,
        psychologistRef: myRef,
        psychologistName: currentUserDisplayName,
        createdTime: DateTime.now(),
      );
      await NewsRecord.collection.doc().set(data);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(
            () => _errorText = genericSaveErrorMessage('publicar la noticia'));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28.0),
            topRight: Radius.circular(28.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Nueva noticia',
                  style: theme.titleMedium.override(
                    font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    color: theme.primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                InkWell(
                  onTap: _pickImage,
                  child: _imageBytes == null
                      ? Container(
                          height: 120.0,
                          decoration: BoxDecoration(
                            color: theme.alternate.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  color: theme.secondaryText),
                              const SizedBox(height: 4.0),
                              Text(
                                'Agregar imagen (opcional)',
                                style: theme.bodySmall.override(
                                  font: GoogleFonts.outfit(),
                                  color: theme.secondaryText,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Image.memory(
                                _imageBytes!,
                                height: 120.0,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            PositionedDirectional(
                              top: 6.0,
                              end: 6.0,
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _imageBytes = null),
                                child: Container(
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close_rounded,
                                      color: Colors.white, size: 16.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Contenido'),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _linkController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Enlace (opcional)',
                    hintText: 'https://...',
                  ),
                ),
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 8.0, 0.0, 0.0),
                    child: Text(
                      _errorText!,
                      style: theme.bodySmall.override(
                        font: GoogleFonts.outfit(),
                        color: theme.error,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                const SizedBox(height: 16.0),
                InkWell(
                  onTap: _isSaving ? null : _submit,
                  child: Container(
                    height: 48.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.primary,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor:
                                  AlwaysStoppedAnimation(theme.onPrimary),
                            ),
                          )
                        : Text(
                            'Publicar noticia',
                            style: theme.labelMedium.override(
                              font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold),
                              color: theme.onPrimary,
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
    );
  }
}
