import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/psychologist_service.dart';
import '/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:google_fonts/google_fonts.dart';
import 'activities_tab.dart';
import 'stats_tab.dart';
import 'incidents_tab.dart';

/// Admin-only screen: "Psicólogos" (create new ones, see their link code
/// and how many consultantes each has), "Consultantes" (every patient in
/// the app, search by name, and reassign their psychologist), and
/// "Actividades" (the catalog of tools/activities psychologists can
/// assign). Access is enforced server-side (Firestore rules + the Cloud
/// Functions both require `role == 'admin'`); the `role` check here is
/// only a friendlier UI guard on top of that.
class AdminPsychologistsWidget extends StatefulWidget {
  const AdminPsychologistsWidget({super.key});

  static String routeName = 'AdminPsychologists';
  static String routePath = '/adminPsychologists';

  @override
  State<AdminPsychologistsWidget> createState() =>
      _AdminPsychologistsWidgetState();
}

class _AdminPsychologistsWidgetState extends State<AdminPsychologistsWidget>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openCreateForm() async {
    final linkCode = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreatePsychologistSheet(),
    );
    if (linkCode != null && linkCode.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Psicólogo creado. Código de vinculación: $linkCode'),
          duration: const Duration(milliseconds: 6000),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = currentUserDocument?.role == 'admin';

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      floatingActionButton: isAdmin && _tabController.index == 0
          ? FloatingActionButton(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: FlutterFlowTheme.of(context).onPrimary,
              onPressed: _openCreateForm,
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
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
                      'Panel de administración',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            font:
                                GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 40.0),
                ],
              ),
            ),
            if (!isAdmin)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'No tienes permiso para ver esta sección.',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.outfit(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ),
              )
            else ...[
              TabBar(
                controller: _tabController,
                labelColor: FlutterFlowTheme.of(context).primary,
                unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
                indicatorColor: FlutterFlowTheme.of(context).primary,
                labelStyle: FlutterFlowTheme.of(context)
                    .bodyMedium
                    .override(font: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                tabs: const [
                  Tab(text: 'Psicólogos'),
                  Tab(text: 'Consultantes'),
                  Tab(text: 'Actividades'),
                  Tab(text: 'Estadísticas'),
                  Tab(text: 'Incidencias'),
                ],
              ),
              Expanded(
                child: StreamBuilder<List<UsersRecord>>(
                  stream: queryUsersRecord(
                    queryBuilder: (usersRecord) =>
                        usersRecord.where('role', isEqualTo: 'psicologo'),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'No se pudieron cargar los psicólogos.',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.outfit(),
                                color: FlutterFlowTheme.of(context).error,
                                letterSpacing: 0.0,
                              ),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final psychologists = snapshot.data!;
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _PsychologistsTab(psychologists: psychologists),
                        _PatientsTab(psychologists: psychologists),
                        const AdminActivitiesTab(),
                        const AdminStatsTab(),
                        const AdminIncidentsTab(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PsychologistsTab extends StatelessWidget {
  const _PsychologistsTab({required this.psychologists});

  final List<UsersRecord> psychologists;

  @override
  Widget build(BuildContext context) {
    if (psychologists.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'Aún no hay psicólogos registrados.\nToca "+" para agregar uno.',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.outfit(),
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 24.0, 96.0),
      itemCount: psychologists.length,
      itemBuilder: (context, index) =>
          _PsychologistCard(psychologist: psychologists[index]),
    );
  }
}

class _PsychologistCard extends StatelessWidget {
  const _PsychologistCard({required this.psychologist});

  final UsersRecord psychologist;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      psychologist.displayName.isEmpty
                          ? psychologist.email
                          : psychologist.displayName,
                      style: FlutterFlowTheme.of(context).titleSmall.override(
                            font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  _ActiveToggleButton(user: psychologist),
                ],
              ),
              if (psychologist.specialty.isNotEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                  child: Text(
                    psychologist.specialty,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.outfit(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                child: Text(
                  psychologist.email,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.outfit(),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Icon(Icons.vpn_key_rounded,
                      size: 16.0,
                      color: FlutterFlowTheme.of(context).primary),
                  const SizedBox(width: 6.0),
                  Expanded(
                    child: Text(
                      psychologist.hasLinkCode()
                          ? psychologist.linkCode
                          : 'Sin código',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                            color: FlutterFlowTheme.of(context).primary,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  if (psychologist.hasLinkCode())
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: psychologist.linkCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Código copiado.')),
                        );
                      },
                      child: Icon(Icons.copy_rounded,
                          size: 18.0,
                          color: FlutterFlowTheme.of(context).secondaryText),
                    ),
                ],
              ),
              const SizedBox(height: 6.0),
              FutureBuilder<AggregateQuerySnapshot>(
                future: UsersRecord.collection
                    .where('role', isEqualTo: 'paciente')
                    .where('psychologistRef', isEqualTo: psychologist.reference)
                    .count()
                    .get(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.count;
                  return Text(
                    count == null
                        ? 'Consultantes: ...'
                        : 'Consultantes: $count',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.outfit(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small chip button that toggles a psychologist's or patient's account
/// between active/inactive via the `setAccountActive` Cloud Function (which
/// also disables/enables their Firebase Auth user, not just a display
/// flag). Shown on every account card in the admin panel.
class _ActiveToggleButton extends StatefulWidget {
  const _ActiveToggleButton({required this.user});

  final UsersRecord user;

  @override
  State<_ActiveToggleButton> createState() => _ActiveToggleButtonState();
}

class _ActiveToggleButtonState extends State<_ActiveToggleButton> {
  bool _isSaving = false;

  Future<void> _toggle() async {
    final makeActive = !widget.user.active;
    final name =
        widget.user.displayName.isEmpty ? widget.user.email : widget.user.displayName;
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(makeActive ? 'Activar cuenta' : 'Desactivar cuenta'),
            content: Text(makeActive
                ? '¿Reactivar la cuenta de $name? Podrá iniciar sesión nuevamente.'
                : '¿Desactivar la cuenta de $name? No podrá iniciar sesión hasta que la reactives.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(makeActive ? 'Activar' : 'Desactivar'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    setState(() => _isSaving = true);
    try {
      await PsychologistService().setAccountActive(
        uid: widget.user.reference.id,
        active: makeActive,
      );
    } on PsychologistServiceException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isActive = widget.user.active;
    if (_isSaving) {
      return const SizedBox(
        width: 20.0,
        height: 20.0,
        child: CircularProgressIndicator(strokeWidth: 2.0),
      );
    }
    return InkWell(
      onTap: _toggle,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
        decoration: BoxDecoration(
          color: (isActive ? theme.success : theme.error).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          isActive ? 'Activo' : 'Inactivo',
          style: theme.labelSmall.override(
            font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            color: isActive ? theme.success : theme.error,
            letterSpacing: 0.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _PatientsTab extends StatefulWidget {
  const _PatientsTab({required this.psychologists});

  final List<UsersRecord> psychologists;

  @override
  State<_PatientsTab> createState() => _PatientsTabState();
}

class _PatientsTabState extends State<_PatientsTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _diagnose(UsersRecord patient) async {
    Map<String, dynamic>? result;
    String? error;
    try {
      result = await PsychologistService().diagnosePatientLink(patient.reference.id);
    } on PsychologistServiceException catch (e) {
      error = e.message;
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Diagnóstico del vínculo'),
        content: SingleChildScrollView(
          child: Text(
            error ??
                result!.entries.map((e) => '${e.key}: ${e.value}').join('\n\n'),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12.0),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _reassign(UsersRecord patient) async {
    final chosen = await showModalBottomSheet<UsersRecord>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PsychologistPicker(
        psychologists: widget.psychologists,
        currentPsychologistId: patient.psychologistRef?.id,
      ),
    );
    if (chosen == null || !mounted) return;
    try {
      await PsychologistService().adminAssignPsychologist(
        patientId: patient.reference.id,
        psychologistId: chosen.reference.id,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${patient.displayName.isEmpty ? patient.email : patient.displayName} '
                'ahora está con ${chosen.displayName}.'),
          ),
        );
      }
    } on PsychologistServiceException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final psychologistNames = {
      for (final p in widget.psychologists)
        p.reference.id: p.displayName.isEmpty ? p.email : p.displayName,
    };

    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 24.0, 8.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) =>
                setState(() => _query = value.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Buscar consultante por nombre o correo...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: FlutterFlowTheme.of(context).secondaryBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<UsersRecord>>(
            stream: queryUsersRecord(
              queryBuilder: (usersRecord) =>
                  usersRecord.where('role', isEqualTo: 'paciente'),
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'No se pudieron cargar los consultantes.',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.outfit(),
                          color: FlutterFlowTheme.of(context).error,
                          letterSpacing: 0.0,
                        ),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final patients = snapshot.data!.where((patient) {
                if (_query.isEmpty) return true;
                return patient.displayName.toLowerCase().contains(_query) ||
                    patient.email.toLowerCase().contains(_query);
              }).toList();
              if (patients.isEmpty) {
                return Center(
                  child: Text(
                    'No se encontraron consultantes.',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.outfit(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                );
              }
              return ListView.builder(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 96.0),
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  final psychologistName = patient.psychologistRef == null
                      ? 'Sin asignar'
                      : psychologistNames[patient.psychologistRef!.id] ??
                          'Psicólogo no encontrado';
                  return Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    patient.displayName.isEmpty
                                        ? patient.email
                                        : patient.displayName,
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 4.0, 0.0, 0.0),
                                    child: Text(
                                      'Psicólogo: $psychologistName',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            font: GoogleFonts.outfit(),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _ActiveToggleButton(user: patient),
                                TextButton(
                                  onPressed: () => _reassign(patient),
                                  child: const Text('Reasignar'),
                                ),
                                TextButton(
                                  onPressed: () => _diagnose(patient),
                                  child: const Text('Diagnóstico'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PsychologistPicker extends StatelessWidget {
  const _PsychologistPicker({
    required this.psychologists,
    required this.currentPsychologistId,
  });

  final List<UsersRecord> psychologists;
  final String? currentPsychologistId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28.0),
            topRight: Radius.circular(28.0),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 12.0),
              child: Text(
                'Elige un psicólogo',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                itemCount: psychologists.length,
                itemBuilder: (context, index) {
                  final psychologist = psychologists[index];
                  final isCurrent =
                      psychologist.reference.id == currentPsychologistId;
                  return ListTile(
                    title: Text(psychologist.displayName.isEmpty
                        ? psychologist.email
                        : psychologist.displayName),
                    subtitle: psychologist.specialty.isEmpty
                        ? null
                        : Text(psychologist.specialty),
                    trailing: isCurrent
                        ? Icon(Icons.check_rounded,
                            color: FlutterFlowTheme.of(context).primary)
                        : null,
                    onTap: () => Navigator.pop(context, psychologist),
                  );
                },
              ),
            ),
            const SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }
}

class _CreatePsychologistSheet extends StatefulWidget {
  const _CreatePsychologistSheet();

  @override
  State<_CreatePsychologistSheet> createState() =>
      _CreatePsychologistSheetState();
}

class _CreatePsychologistSheetState extends State<_CreatePsychologistSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _passwordController = TextEditingController();
  final _service = PsychologistService();

  bool _isSaving = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _specialtyController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _errorText = null;
    });
    try {
      final linkCode = await _service.createPsychologist(
        displayName: normalizeWhitespace(_nameController.text),
        email: _emailController.text.trim(),
        specialty: _specialtyController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.pop(context, linkCode);
      }
    } on PsychologistServiceException catch (e) {
      if (mounted) setState(() => _errorText = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _errorText =
            'No se pudo crear el psicólogo. Intenta nuevamente.');
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
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Nuevo psicólogo',
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
                  decoration: const InputDecoration(
                      labelText: 'Nombre completo'),
                  validator: validateFullName,
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Correo electrónico'),
                  validator: validateEmail,
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _specialtyController,
                  decoration: const InputDecoration(
                      labelText: 'Especialidad',
                      hintText: 'Ej. Ansiedad y estrés'),
                  validator: (value) => validateFreeText(
                    value,
                    maxLength: 200,
                    required: true,
                    requiredMessage: 'Ingresa una especialidad breve.',
                  ),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: const InputDecoration(
                      labelText: 'Contraseña temporal'),
                  validator: validatePassword,
                ),
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 12.0, 0.0, 0.0),
                    child: Text(
                      _errorText!,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.outfit(),
                            color: FlutterFlowTheme.of(context).error,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                const SizedBox(height: 20.0),
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
                            'Crear psicólogo',
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
