import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/bottom_nav5/bottom_nav5_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/utils/date_format_es.dart';
import '/utils/emotion_visuals.dart';
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
                        style:
                            FlutterFlowTheme.of(context).titleLarge.override(
                                  font: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .primaryText,
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
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 44.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
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
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 20.0,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _model.searchController,
                              decoration: InputDecoration(
                                hintText: 'Buscar por emoción o descripción...',
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
                                      selected: _model.emotionFilter == emotion,
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
                              safeSetState(() =>
                                  _model.sortAscending = !_model.sortAscending);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<RecordsRecord>>(
                  stream: queryRecordsRecord(
                    queryBuilder: (recordsRecord) => recordsRecord
                        .where('userRef', isEqualTo: currentUserReference),
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
                      final query = _model.searchQuery.trim().toLowerCase();
                      records = records
                          .where((r) =>
                              r.emotion.toLowerCase().contains(query) ||
                              r.description.toLowerCase().contains(query) ||
                              r.behaviors
                                  .any((b) => b.toLowerCase().contains(query)))
                          .toList();
                    }
                    records.sort((a, b) {
                      final ta =
                          a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
                      final tb =
                          b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
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
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 24.0),
                      itemCount: records.length,
                      itemBuilder: (context, index) => Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
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
                Row(
                  children: [
                    Container(
                      width: 10.0,
                      height: 10.0,
                      decoration: BoxDecoration(
                        color: emotionColor(context, record.emotion),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                      child: Text(
                        record.emotion.isEmpty ? 'Sin emoción' : record.emotion,
                        style: FlutterFlowTheme.of(context)
                            .titleMedium
                            .override(
                              font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600),
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
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
              child: Row(
                children: [
                  Icon(
                    Icons.event_rounded,
                    size: 14.0,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 12.0, 0.0),
                    child: Text(
                      timestamp != null ? formatDateEs(timestamp) : 'Sin fecha',
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                            font: GoogleFonts.outfit(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                  if (timestamp != null) ...[
                    Icon(
                      Icons.access_time_rounded,
                      size: 14.0,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 0.0, 0.0),
                      child: Text(
                        formatTime24(timestamp),
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              font: GoogleFonts.outfit(),
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
