import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/utils/error_messages.dart';
import '/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Known in-app screens an activity can deep-link to (see
/// `RegulationToolsWidget`'s recommended-activities banner, which uses this
/// same route name to navigate). Empty/no selection means "just a written
/// indication, no specific screen".
const _kKnownRoutes = {
  '': 'Sin pantalla específica',
  'EmotionalRecord': 'Registro emocional',
  'BehavioralRecord': 'Registro de conducta',
  'Grounding54321': 'Técnica 5-4-3-2-1',
  'BreathingGuided': 'Respiración guiada',
  'BreathingVisual': 'Respiración cuadrada',
  'FindTheColor': 'Encuentra el color',
  'SoundFocus': 'Atención auditiva',
  'MindfulVibration': 'Vibración consciente',
  'MindfulObservation': 'Observación consciente',
};

/// The catalog entries `_seedBaseActivities` creates -- Equilibra's own
/// built-in tools, so a psychologist has something to assign to a patient
/// from day one without the admin having to type them in by hand.
const _kBaseActivities = [
  (
    name: 'Registro emocional',
    description: 'Registrar una emoción, su intensidad y el contexto.',
    category: 'Registro',
    routeName: 'EmotionalRecord',
  ),
  (
    name: 'Registro de conductas',
    description: 'Registrar sueño, alimentación, ejercicio u otras conductas.',
    category: 'Registro',
    routeName: 'BehavioralRecord',
  ),
  (
    name: 'Técnica 5-4-3-2-1',
    description: 'Reconecta con tus 5 sentidos, paso a paso.',
    category: 'Regulación emocional',
    routeName: 'Grounding54321',
  ),
  (
    name: 'Respiración guiada',
    description: 'Inhala, mantén y exhala siguiendo el círculo.',
    category: 'Regulación emocional',
    routeName: 'BreathingGuided',
  ),
  (
    name: 'Respiración cuadrada',
    description: 'Sigue el punto alrededor del cuadrado (4-4-4-4).',
    category: 'Regulación emocional',
    routeName: 'BreathingVisual',
  ),
  (
    name: 'Encuentra el color',
    description: 'Localiza objetos de un color a tu alrededor.',
    category: 'Regulación emocional',
    routeName: 'FindTheColor',
  ),
  (
    name: 'Atención auditiva',
    description: 'Sonidos relajantes: lluvia, bosque, mar o viento.',
    category: 'Regulación emocional',
    routeName: 'SoundFocus',
  ),
  (
    name: 'Vibración consciente',
    description: 'Vibraciones suaves para favorecer la calma.',
    category: 'Regulación emocional',
    routeName: 'MindfulVibration',
  ),
  (
    name: 'Observación consciente',
    description: 'Encuentra detalles específicos en una escena.',
    category: 'Regulación emocional',
    routeName: 'MindfulObservation',
  ),
];

class AdminActivitiesTab extends StatefulWidget {
  const AdminActivitiesTab({super.key});

  @override
  State<AdminActivitiesTab> createState() => _AdminActivitiesTabState();
}

class _AdminActivitiesTabState extends State<AdminActivitiesTab> {
  bool _isSeeding = false;

  Future<void> _openForm({ActivitiesRecord? existing}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ActivityFormSheet(existing: existing),
    );
  }

  Future<void> _seedBaseActivities() async {
    setState(() => _isSeeding = true);
    try {
      final existingSnap = await ActivitiesRecord.collection.get();
      final existingNames = existingSnap.docs
          .map((d) => (d.data() as Map<String, dynamic>)['name'] as String?)
          .whereType<String>()
          .toSet();
      final batch = FirebaseFirestore.instance.batch();
      var added = 0;
      for (final activity in _kBaseActivities) {
        if (existingNames.contains(activity.name)) continue;
        batch.set(
          ActivitiesRecord.collection.doc(),
          createActivitiesRecordData(
            name: activity.name,
            description: activity.description,
            category: activity.category,
            routeName: activity.routeName,
            active: true,
            createdTime: DateTime.now(),
          ),
        );
        added++;
      }
      if (added > 0) await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(added == 0
                ? 'Las herramientas base ya estaban cargadas.'
                : 'Se agregaron $added herramientas al catálogo.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(genericSaveErrorMessage('cargar las herramientas base'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<List<ActivitiesRecord>>(
          stream: queryActivitiesRecord(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No se pudo cargar el catálogo de actividades.'),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final activities = snapshot.data!
              ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
            return ListView(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 24.0, 96.0),
              children: [
                OutlinedButton.icon(
                  onPressed: _isSeeding ? null : _seedBaseActivities,
                  icon: _isSeeding
                      ? const SizedBox(
                          width: 16.0,
                          height: 16.0,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        )
                      : const Icon(Icons.download_rounded),
                  label: const Text('Cargar herramientas base de Equilibra'),
                ),
                const SizedBox(height: 16.0),
                if (activities.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Text('Aún no hay actividades en el catálogo.'),
                  )
                else
                  ...activities.map((activity) => _ActivityCard(
                        activity: activity,
                        onTap: () => _openForm(existing: activity),
                      )),
              ],
            );
          },
        ),
        PositionedDirectional(
          bottom: 16.0,
          end: 0.0,
          child: FloatingActionButton(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            foregroundColor: FlutterFlowTheme.of(context).onPrimary,
            onPressed: () => _openForm(),
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity, required this.onTap});

  final ActivitiesRecord activity;
  final VoidCallback onTap;

  Future<void> _toggleActive(BuildContext context) async {
    try {
      await activity.reference.update({'active': !activity.active});
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(genericSaveErrorMessage('actualizar la actividad'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name,
                      style: theme.bodyMedium.override(
                        font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                        color: theme.primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (activity.category.isNotEmpty || activity.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 0.0, 0.0),
                        child: Text(
                          [activity.category, activity.description]
                              .where((s) => s.isNotEmpty)
                              .join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodySmall.override(
                            font: GoogleFonts.outfit(),
                            color: theme.secondaryText,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Switch(
                value: activity.active,
                onChanged: (_) => _toggleActive(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityFormSheet extends StatefulWidget {
  const _ActivityFormSheet({this.existing});

  final ActivitiesRecord? existing;

  @override
  State<_ActivityFormSheet> createState() => _ActivityFormSheetState();
}

class _ActivityFormSheetState extends State<_ActivityFormSheet> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late String _routeName;
  late bool _active;
  bool _isSaving = false;
  String? _errorText;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _categoryController = TextEditingController(text: e?.category ?? '');
    _routeName = _kKnownRoutes.containsKey(e?.routeName) ? (e?.routeName ?? '') : '';
    _active = e?.active ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nameError = validateFreeText(
      _nameController.text,
      maxLength: 80,
      required: true,
      requiredMessage: 'El nombre es obligatorio.',
    );
    if (nameError != null) {
      setState(() => _errorText = nameError);
      return;
    }
    setState(() {
      _isSaving = true;
      _errorText = null;
    });
    try {
      final data = createActivitiesRecordData(
        name: normalizeWhitespace(_nameController.text),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        routeName: _routeName,
        active: _active,
      );
      if (_isEditing) {
        await widget.existing!.reference.update(data);
      } else {
        await ActivitiesRecord.collection.doc().set({
          ...data,
          'createdTime': DateTime.now(),
        });
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _errorText = genericSaveErrorMessage('guardar la actividad'));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
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
                  _isEditing ? 'Editar actividad' : 'Nueva actividad',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                      labelText: 'Categoría',
                      hintText: 'Ej. Regulación emocional, TIP, Registro...'),
                ),
                const SizedBox(height: 12.0),
                DropdownButtonFormField<String>(
                  value: _routeName,
                  decoration: const InputDecoration(labelText: 'Pantalla de la app'),
                  items: _kKnownRoutes.entries
                      .map((e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (value) => setState(() => _routeName = value ?? ''),
                ),
                const SizedBox(height: 12.0),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Activa (disponible para asignar)'),
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                ),
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                    child: Text(
                      _errorText!,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.outfit(),
                            color: FlutterFlowTheme.of(context).error,
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
                      color: FlutterFlowTheme.of(context).primary,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation(
                                  FlutterFlowTheme.of(context).onPrimary),
                            ),
                          )
                        : Text(
                            _isEditing ? 'Guardar cambios' : 'Crear actividad',
                            style:
                                FlutterFlowTheme.of(context).labelMedium.override(
                                      font: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold),
                                      color:
                                          FlutterFlowTheme.of(context).onPrimary,
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
