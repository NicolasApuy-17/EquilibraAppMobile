import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/bottom_nav5/bottom_nav5_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/utils/date_format_es.dart';
import '/utils/emotion_visuals.dart';
import '/utils/error_messages.dart';
import '/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'my_records_model.dart';
export 'my_records_model.dart';

const _kEmotions = [
  'Alegría',
  'Miedo',
  'Tristeza',
  'Enojo',
  'Vergüenza',
  'Tranquilo',
];

class MyRecordsWidget extends StatefulWidget {
  const MyRecordsWidget({super.key});

  static String routeName = 'MyRecords';
  static String routePath = '/myRecords';

  @override
  State<MyRecordsWidget> createState() => _MyRecordsWidgetState();
}

class _MyRecordsWidgetState extends State<MyRecordsWidget> {
  late MyRecordsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyRecordsModel());
    _model.searchController.addListener(() {
      safeSetState(() => _model.searchQuery = _model.searchController.text);
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
                      onPressed: () async {
                        context.safePop();
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Mis registros',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                              font: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                              ),
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    FlutterFlowIconButton(
                      borderRadius: 8.0,
                      buttonSize: 40.0,
                      fillColor: Colors.transparent,
                      icon: Icon(
                        Icons.checklist_rounded,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 24.0,
                      ),
                      onPressed: () async {
                        context.pushNamed(TasksWidget.routeName);
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentButton(
                        label: 'Emociones',
                        icon: Icons.mood_rounded,
                        selected: !_model.showBehaviors,
                        onTap: () =>
                            safeSetState(() => _model.showBehaviors = false),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: _SegmentButton(
                        label: 'Conductas',
                        icon: Icons.checklist_rounded,
                        selected: _model.showBehaviors,
                        onTap: () =>
                            safeSetState(() => _model.showBehaviors = true),
                      ),
                    ),
                  ],
                ),
              ),
              if (!_model.showBehaviors)
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 44.0,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  12.0, 0.0, 8.0, 0.0),
                              child: Icon(
                                Icons.search_rounded,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                size: 20.0,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _model.searchController,
                                decoration: InputDecoration(
                                  hintText:
                                      'Buscar por emoción o descripción...',
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.outfit(),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.outfit(),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                            if (_model.searchQuery.isNotEmpty)
                              InkWell(
                                onTap: () => _model.searchController.clear(),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 12.0, 0.0),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    size: 18.0,
                                  ),
                                ),
                              )
                            else
                              SizedBox(width: 12.0),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _FilterChip(
                                    label: 'Todas',
                                    selected: _model.emotionFilter == null,
                                    onTap: () => safeSetState(
                                        () => _model.emotionFilter = null),
                                  ),
                                  for (final emotion in _kEmotions)
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          8.0, 0.0, 0.0, 0.0),
                                      child: _FilterChip(
                                        label: emotion,
                                        selected:
                                            _model.emotionFilter == emotion,
                                        onTap: () => safeSetState(
                                          () => _model.emotionFilter =
                                              _model.emotionFilter == emotion
                                                  ? null
                                                  : emotion,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                8.0, 0.0, 0.0, 0.0),
                            child: FlutterFlowIconButton(
                              borderRadius: 8.0,
                              buttonSize: 40.0,
                              fillColor: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              icon: Icon(
                                _model.sortAscending
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 20.0,
                              ),
                              onPressed: () async {
                                safeSetState(() => _model.sortAscending =
                                    !_model.sortAscending);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _model.showBehaviors
                    ? StreamBuilder<List<BehavioralRecordsRecord>>(
                        stream: queryBehavioralRecordsRecord(
                          queryBuilder: (q) => q.where('userRef',
                              isEqualTo: currentUserReference),
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return _StateMessage(
                              icon: Icons.error_outline_rounded,
                              title: 'No se pudieron cargar tus registros.',
                              subtitle: 'Intenta nuevamente más tarde.',
                            );
                          }
                          if (!snapshot.hasData) {
                            return Center(
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final records = snapshot.data!.toList()
                            ..sort((a, b) {
                              final ta = a.createdAt ??
                                  DateTime.fromMillisecondsSinceEpoch(0);
                              final tb = b.createdAt ??
                                  DateTime.fromMillisecondsSinceEpoch(0);
                              return _model.sortAscending
                                  ? ta.compareTo(tb)
                                  : tb.compareTo(ta);
                            });

                          if (records.isEmpty) {
                            return _StateMessage(
                              icon: Icons.checklist_outlined,
                              title: 'Aún no tienes registros de conducta',
                              subtitle:
                                  'Cuando registres una conducta, aparecerá aquí.',
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                24.0, 12.0, 24.0, 24.0),
                            itemCount: records.length,
                            itemBuilder: (context, index) => Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 12.0),
                              child:
                                  _BehavioralRecordCard(record: records[index]),
                            ),
                          );
                        },
                      )
                    : StreamBuilder<List<RecordsRecord>>(
                        stream: queryRecordsRecord(
                          queryBuilder: (recordsRecord) => recordsRecord.where(
                              'userRef',
                              isEqualTo: currentUserReference),
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return _StateMessage(
                              icon: Icons.error_outline_rounded,
                              title: 'No se pudieron cargar tus registros.',
                              subtitle: 'Intenta nuevamente más tarde.',
                            );
                          }
                          if (!snapshot.hasData) {
                            return Center(
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final allRecords = snapshot.data!;
                          var records = allRecords.toList();

                          if (_model.emotionFilter != null) {
                            records = records
                                .where((r) => r.emotion == _model.emotionFilter)
                                .toList();
                          }
                          if (_model.searchQuery.trim().isNotEmpty) {
                            final query =
                                _model.searchQuery.trim().toLowerCase();
                            records = records
                                .where((r) =>
                                    r.emotion.toLowerCase().contains(query) ||
                                    r.description
                                        .toLowerCase()
                                        .contains(query) ||
                                    r.behaviors.any(
                                        (b) => b.toLowerCase().contains(query)))
                                .toList();
                          }
                          records.sort((a, b) {
                            final ta = a.timestamp ??
                                DateTime.fromMillisecondsSinceEpoch(0);
                            final tb = b.timestamp ??
                                DateTime.fromMillisecondsSinceEpoch(0);
                            return _model.sortAscending
                                ? ta.compareTo(tb)
                                : tb.compareTo(ta);
                          });

                          if (records.isEmpty) {
                            return _StateMessage(
                              icon: Icons.search_off_rounded,
                              title: allRecords.isEmpty
                                  ? 'Aún no tienes registros'
                                  : 'Sin resultados',
                              subtitle: allRecords.isEmpty
                                  ? 'Cuando registres cómo te sientes, aparecerán aquí.'
                                  : 'Prueba con otra búsqueda o filtro.',
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                24.0, 0.0, 24.0, 24.0),
                            itemCount: records.length,
                            itemBuilder: (context, index) => Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 12.0),
                              child: _RecordCard(record: records[index]),
                            ),
                          );
                        },
                      ),
              ),
              wrapWithModel(
                model: _model.bottomNavModel,
                updateCallback: () => safeSetState(() {}),
                child: BottomNav5Widget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(14.0, 8.0, 14.0, 8.0),
        decoration: BoxDecoration(
          color: selected
              ? FlutterFlowTheme.of(context).primary10
              : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: selected
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate,
          ),
        ),
        child: Text(
          label,
          style: FlutterFlowTheme.of(context).labelMedium.override(
                font: GoogleFonts.outfit(),
                color: selected
                    ? FlutterFlowTheme.of(context).primary
                    : FlutterFlowTheme.of(context).primaryText,
                letterSpacing: 0.0,
              ),
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 40.0,
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 4.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.outfit(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final RecordsRecord record;

  @override
  Widget build(BuildContext context) {
    final timestamp = record.timestamp;

    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // `Expanded`, not a plain `Row`: a custom emotion label can
                // be up to 30 characters (see emotional_record_widget.dart)
                // -- long enough, combined with the intensity chip on the
                // other side of this `spaceBetween` row, to overflow on a
                // narrow phone if neither side can shrink.
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 10.0,
                        height: 10.0,
                        decoration: BoxDecoration(
                          color: emotionColor(context, record.emotion),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              8.0, 0.0, 8.0, 0.0),
                          child: Text(
                            record.emotion.isEmpty
                                ? 'Sin emoción'
                                : record.emotion,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  font: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600),
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsetsDirectional.fromSTEB(10.0, 4.0, 10.0, 4.0),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary10,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    '${record.intensity.round()}/10',
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                          font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                          color: FlutterFlowTheme.of(context).primary,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                // A mistaken emotion, intensity or description is easy to
                // make in the moment -- this lets the patient fix it after
                // the fact instead of leaving a wrong entry in their (and
                // their psychologist's) history forever.
                InkWell(
                  borderRadius: BorderRadius.circular(20.0),
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        _EditEmotionalRecordSheet(record: record),
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 18.0,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                  ),
                ),
              ],
            ),
            if (record.description.isNotEmpty)
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                child: Text(
                  record.description,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.outfit(),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            if (record.behaviors.isNotEmpty)
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                child: Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: [
                    for (final behavior in record.behaviors)
                      Container(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context)
                              .alternate
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              behaviorIcon(behavior),
                              size: 14.0,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  4.0, 0.0, 0.0, 0.0),
                              child: Text(
                                behavior,
                                style: FlutterFlowTheme.of(context)
                                    .labelSmall
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
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
              // `Wrap`, not `Row`: a long Spanish date ("24 de septiembre de
              // 2026") plus the time can crowd out the smallest phone
              // widths -- wrapping the time onto its own line there costs
              // nothing on a normal phone or tablet, where it always fits
              // on one line anyway.
              child: Wrap(
                spacing: 4.0,
                runSpacing: 4.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_rounded,
                        size: 14.0,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 0.0, 0.0),
                        child: Text(
                          timestamp != null
                              ? formatDateEs(timestamp)
                              : 'Sin fecha',
                          style: FlutterFlowTheme.of(context)
                              .labelSmall
                              .override(
                                font: GoogleFonts.outfit(),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ],
                  ),
                  if (timestamp != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14.0,
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              4.0, 0.0, 0.0, 0.0),
                          child: Text(
                            formatTime24(timestamp),
                            style: FlutterFlowTheme.of(context)
                                .labelSmall
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        height: 44.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? theme.primary10 : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: selected ? theme.primary : theme.alternate),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18.0,
                color: selected ? theme.primary : theme.secondaryText),
            SizedBox(width: 6.0),
            Text(
              label,
              style: theme.labelMedium.override(
                font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                color: selected ? theme.primary : theme.secondaryText,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 4.0),
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

/// A patient's own behavioral record -- these never had any view at all on
/// the patient side before (only their psychologist could see them, in
/// PsychologistPatientDetailWidget's Registros tab); this mirrors
/// `_RecordCard`'s look for consistency.
class _BehavioralRecordCard extends StatelessWidget {
  const _BehavioralRecordCard({required this.record});

  final BehavioralRecordsRecord record;

  String _formatQuantity(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toString();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final date = record.createdAt ?? record.date;

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // `Expanded`, not a plain `Row`: same overflow risk on a
                // narrow phone as `_RecordCard`'s header (see its comment).
                Expanded(
                  child: Row(
                    children: [
                      Icon(behaviorIcon(record.behaviorType),
                          size: 18.0, color: theme.primary),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              8.0, 0.0, 8.0, 0.0),
                          child: Text(
                            record.behaviorType.isEmpty
                                ? 'Sin conducta'
                                : record.behaviorType,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.titleMedium.override(
                              font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600),
                              color: theme.primaryText,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (record.value.isNotEmpty)
                  Container(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(10.0, 4.0, 10.0, 4.0),
                    decoration: BoxDecoration(
                      color: theme.primary10,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      record.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.labelMedium.override(
                        font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        color: theme.primary,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                // Same edit affordance as `_RecordCard`: behavioral records
                // can have the same kind of "I mis-tapped/mis-typed this"
                // mistake, and had no way to fix it before.
                InkWell(
                  borderRadius: BorderRadius.circular(20.0),
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        _EditBehavioralRecordSheet(record: record),
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 18.0,
                      color: theme.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
            if (record.quantity != null)
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                child: Text(
                  'Cantidad: ${_formatQuantity(record.quantity!)}',
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.outfit(),
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            if (record.notes.isNotEmpty)
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                child: Text(
                  record.notes,
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.outfit(),
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_rounded,
                      size: 14.0, color: theme.secondaryText),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 0.0, 0.0),
                    child: Text(
                      date != null ? formatDateEs(date) : 'Sin fecha',
                      style: theme.labelSmall.override(
                        font: GoogleFonts.outfit(),
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lets the patient fix a mistaken emotional record after the fact: wrong
/// emotion label, intensity, or description. Deliberately does not touch
/// `behaviors` (a list of attached behavior tags): no current creation flow
/// ever sets it, so there's nothing meaningful to edit there.
class _EditEmotionalRecordSheet extends StatefulWidget {
  const _EditEmotionalRecordSheet({required this.record});

  final RecordsRecord record;

  @override
  State<_EditEmotionalRecordSheet> createState() =>
      _EditEmotionalRecordSheetState();
}

class _EditEmotionalRecordSheetState extends State<_EditEmotionalRecordSheet> {
  late TextEditingController _emotionController;
  late TextEditingController _descriptionController;
  late double _intensity;
  bool _isSaving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _emotionController = TextEditingController(text: widget.record.emotion);
    _descriptionController =
        TextEditingController(text: widget.record.description);
    _intensity = widget.record.intensity <= 0 ? 5.0 : widget.record.intensity;
  }

  @override
  void dispose() {
    _emotionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final error = validateLabel(_emotionController.text);
    if (error != null) {
      setState(() => _errorText = error);
      return;
    }
    setState(() {
      _isSaving = true;
      _errorText = null;
    });
    try {
      await widget.record.reference.update(createRecordsRecordData(
        emotion: normalizeWhitespace(_emotionController.text),
        description: _descriptionController.text.trim(),
        intensity: _intensity,
      ));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(
            () => _errorText = genericSaveErrorMessage('guardar el registro'));
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
                  'Editar registro emocional',
                  style: theme.titleMedium.override(
                    font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    color: theme.primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _FieldLabel('Emoción'),
                TextField(
                  controller: _emotionController,
                  maxLength: 30,
                  decoration: InputDecoration(
                    hintText: 'Ej. Tranquilo, Triste, Ansioso...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                ),
                _FieldLabel('Intensidad: ${_intensity.round()}/10'),
                Slider(
                  value: _intensity,
                  min: 0.0,
                  max: 10.0,
                  divisions: 10,
                  label: _intensity.round().toString(),
                  onChanged: (value) => setState(() => _intensity = value),
                ),
                _FieldLabel('Descripción (opcional)'),
                TextField(
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: '¿Qué pasó? (opcional)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                ),
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 12.0, 0.0, 0.0),
                    child: Text(
                      _errorText!,
                      style: theme.bodySmall.override(
                        font: GoogleFonts.outfit(),
                        color: theme.error,
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
                            'Guardar cambios',
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

/// Same idea as `_EditEmotionalRecordSheet`, for a behavioral record.
class _EditBehavioralRecordSheet extends StatefulWidget {
  const _EditBehavioralRecordSheet({required this.record});

  final BehavioralRecordsRecord record;

  @override
  State<_EditBehavioralRecordSheet> createState() =>
      _EditBehavioralRecordSheetState();
}

class _EditBehavioralRecordSheetState
    extends State<_EditBehavioralRecordSheet> {
  late TextEditingController _typeController;
  late TextEditingController _valueController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;
  bool _isSaving = false;
  String? _errorText;

  static String _formatQuantity(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toString();

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.record.behaviorType);
    _valueController = TextEditingController(text: widget.record.value);
    _quantityController = TextEditingController(
        text: widget.record.quantity != null
            ? _formatQuantity(widget.record.quantity!)
            : '');
    _notesController = TextEditingController(text: widget.record.notes);
  }

  @override
  void dispose() {
    _typeController.dispose();
    _valueController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final typeError = validateLabel(_typeController.text);
    if (typeError != null) {
      setState(() => _errorText = typeError);
      return;
    }
    final quantityText = _quantityController.text.trim();
    final quantityError =
        validateQuantity(quantityText, min: 0, required: false);
    if (quantityError != null) {
      setState(() => _errorText = quantityError);
      return;
    }
    setState(() {
      _isSaving = true;
      _errorText = null;
    });
    try {
      await widget.record.reference.update(createBehavioralRecordsRecordData(
        behaviorType: normalizeWhitespace(_typeController.text),
        value: _valueController.text.trim(),
        quantity: quantityText.isEmpty
            ? null
            : double.tryParse(quantityText.replaceAll(',', '.')),
        notes: _notesController.text.trim(),
      ));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(
            () => _errorText = genericSaveErrorMessage('guardar el registro'));
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
                  'Editar registro de conducta',
                  style: theme.titleMedium.override(
                    font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    color: theme.primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _FieldLabel('Conducta'),
                TextField(
                  controller: _typeController,
                  maxLength: 30,
                  decoration: InputDecoration(
                    hintText: 'Ej. Sueño, Alimentación...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                ),
                _FieldLabel('Estado / valor'),
                TextField(
                  controller: _valueController,
                  maxLength: 60,
                  decoration: InputDecoration(
                    hintText: 'Ej. Bien, Se aisló, Cumplido...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                ),
                _FieldLabel('Cantidad (opcional)'),
                TextField(
                  controller: _quantityController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Ej. horas, veces...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                ),
                _FieldLabel('Notas (opcional)'),
                TextField(
                  controller: _notesController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Notas adicionales...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                ),
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 12.0, 0.0, 0.0),
                    child: Text(
                      _errorText!,
                      style: theme.bodySmall.override(
                        font: GoogleFonts.outfit(),
                        color: theme.error,
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
                            'Guardar cambios',
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
