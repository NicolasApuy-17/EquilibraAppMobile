import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/behavior_item/behavior_item_widget.dart';
import '/components/bottom_nav4/bottom_nav4_widget.dart';
import '/components/emotion_chip/emotion_chip_widget.dart';
import '/components/progress_stat_card/progress_stat_card_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import '/utils/emotion_visuals.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'weekly_progress_model.dart';
export 'weekly_progress_model.dart';

class WeeklyProgressWidget extends StatefulWidget {
  const WeeklyProgressWidget({super.key});

  static String routeName = 'WeeklyProgress';
  static String routePath = '/weeklyProgress';

  @override
  State<WeeklyProgressWidget> createState() => _WeeklyProgressWidgetState();
}

class _WeeklyProgressWidgetState extends State<WeeklyProgressWidget> {
  late WeeklyProgressModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WeeklyProgressModel());
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
              Container(
                width: 0.0,
                height: 0.0,
              ),
              Expanded(
                child: Container(
                  child: SingleChildScrollView(
                    primary: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(24.0),
                          child: StreamBuilder<List<RecordsRecord>>(
                            stream: queryRecordsRecord(
                              queryBuilder: (recordsRecord) =>
                                  recordsRecord.where('userRef',
                                      isEqualTo: currentUserReference),
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return _ProgressErrorState(
                                  bottomNavModel: _model.bottomNavModel,
                                  onUpdate: () => safeSetState(() {}),
                                );
                              }
                              // Customize what your widget looks like when it's loading.
                              if (!snapshot.hasData) {
                                return Center(
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              List<RecordsRecord>
                                  columnPaddingRecordsRecordList = functions
                                      .recordsThisWeek(snapshot.data!.toList());

                              if (columnPaddingRecordsRecordList.isEmpty) {
                                return _ProgressEmptyState(
                                  bottomNavModel: _model.bottomNavModel,
                                  onUpdate: () => safeSetState(() {}),
                                );
                              }

                              final now = DateTime.now();
                              final startOfWeek = DateTime(
                                      now.year, now.month, now.day)
                                  .subtract(Duration(days: now.weekday - 1));
                              final endOfWeek =
                                  startOfWeek.add(Duration(days: 6));
                              const monthNames = [
                                'ene',
                                'feb',
                                'mar',
                                'abr',
                                'may',
                                'jun',
                                'jul',
                                'ago',
                                'sep',
                                'oct',
                                'nov',
                                'dic',
                              ];
                              final weekRangeLabel =
                                  '${startOfWeek.day} ${monthNames[startOfWeek.month - 1]} - ${endOfWeek.day} ${monthNames[endOfWeek.month - 1]}';
                              const weekdayShort = [
                                'Lun',
                                'Mar',
                                'Mié',
                                'Jue',
                                'Vie',
                                'Sáb',
                                'Dom'
                              ];
                              final emotionCounts = functions.emotionFrequency(
                                  columnPaddingRecordsRecordList);
                              final behaviorCounts =
                                  functions.behaviorFrequency(
                                      columnPaddingRecordsRecordList);
                              final dailyIntensity =
                                  functions.averageIntensityPerWeekday(
                                      columnPaddingRecordsRecordList);
                              final dailyCounts = functions.recordsPerWeekday(
                                  columnPaddingRecordsRecordList);
                              final topBehavior = behaviorCounts.isNotEmpty
                                  ? behaviorCounts.first.key
                                  : 'Sin datos';
                              final maxDailyCount =
                                  dailyCounts.reduce((a, b) => a > b ? a : b);

                              return Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Tu progreso semanal',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .headlineMedium
                                                  .override(
                                                    font: GoogleFonts.comfortaa(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .headlineMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .headlineMedium
                                                            .fontStyle,
                                                    lineHeight: 1.3,
                                                  ),
                                            ),
                                            Text(
                                              weekRangeLabel,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.outfit(
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                    lineHeight: 1.6,
                                                  ),
                                            ),
                                          ].divide(SizedBox(height: 4.0)),
                                        ),
                                        FlutterFlowIconButton(
                                          borderRadius: 16.0,
                                          buttonSize: 40.0,
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          icon: Icon(
                                            Icons.calendar_month_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            size: 24.0,
                                          ),
                                          onPressed: () async {
                                            context.goNamed(
                                                WeeklyProgressWidget.routeName);
                                          },
                                        ),
                                      ],
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(32.0),
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(24.0),
                                        child: Container(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Evolución semanal',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .titleMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .outfit(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMedium
                                                                  .fontStyle,
                                                          lineHeight: 1.45,
                                                        ),
                                                  ),
                                                  Text(
                                                    'Promedio: ${functions.averageIntensityLabel(columnPaddingRecordsRecordList.toList())}',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .labelLarge
                                                        .override(
                                                          font: GoogleFonts
                                                              .outfit(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelLarge
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelLarge
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .onSurface,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontStyle,
                                                          lineHeight: 1.4,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                height: 200.0,
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 8.0, 16.0, 0.0),
                                                  child: LineChart(
                                                    LineChartData(
                                                      minY: 1,
                                                      maxY: 10,
                                                      minX: 0,
                                                      maxX: 6,
                                                      gridData: FlGridData(
                                                        show: true,
                                                        drawVerticalLine: false,
                                                        horizontalInterval: 3,
                                                        getDrawingHorizontalLine:
                                                            (value) => FlLine(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .alternate,
                                                          strokeWidth: 1,
                                                        ),
                                                      ),
                                                      borderData: FlBorderData(
                                                          show: false),
                                                      titlesData: FlTitlesData(
                                                        topTitles: AxisTitles(
                                                          sideTitles:
                                                              SideTitles(
                                                                  showTitles:
                                                                      false),
                                                        ),
                                                        rightTitles: AxisTitles(
                                                          sideTitles:
                                                              SideTitles(
                                                                  showTitles:
                                                                      false),
                                                        ),
                                                        leftTitles: AxisTitles(
                                                          sideTitles:
                                                              SideTitles(
                                                                  showTitles:
                                                                      false),
                                                        ),
                                                        bottomTitles:
                                                            AxisTitles(
                                                          sideTitles:
                                                              SideTitles(
                                                            showTitles: true,
                                                            reservedSize: 24,
                                                            getTitlesWidget:
                                                                (value, meta) {
                                                              final index =
                                                                  value.round();
                                                              if (index < 0 ||
                                                                  index > 6) {
                                                                return Container();
                                                              }
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            8.0),
                                                                child: Text(
                                                                  weekdayShort[
                                                                      index],
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmall
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .outfit(),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                        letterSpacing:
                                                                            0.0,
                                                                      ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      lineBarsData: [
                                                        LineChartBarData(
                                                          spots: [
                                                            for (var i = 0;
                                                                i < 7;
                                                                i++)
                                                              if (dailyIntensity[
                                                                      i] !=
                                                                  null)
                                                                FlSpot(
                                                                  i.toDouble(),
                                                                  dailyIntensity[
                                                                      i]!,
                                                                ),
                                                          ],
                                                          isCurved: true,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          barWidth: 3,
                                                          dotData: FlDotData(
                                                              show: true),
                                                          belowBarData:
                                                              BarAreaData(
                                                            show: true,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary
                                                                .withValues(
                                                                    alpha:
                                                                        0.15),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 16.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(32.0),
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(24.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              'Registros por día',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .titleMedium
                                                  .override(
                                                    font: GoogleFonts.outfit(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            Container(
                                              height: 160.0,
                                              child: BarChart(
                                                BarChartData(
                                                  minY: 0,
                                                  maxY: maxDailyCount < 4
                                                      ? 4
                                                      : (maxDailyCount + 1)
                                                          .toDouble(),
                                                  gridData:
                                                      FlGridData(show: false),
                                                  borderData:
                                                      FlBorderData(show: false),
                                                  titlesData: FlTitlesData(
                                                    topTitles: AxisTitles(
                                                      sideTitles: SideTitles(
                                                          showTitles: false),
                                                    ),
                                                    rightTitles: AxisTitles(
                                                      sideTitles: SideTitles(
                                                          showTitles: false),
                                                    ),
                                                    leftTitles: AxisTitles(
                                                      sideTitles: SideTitles(
                                                          showTitles: false),
                                                    ),
                                                    bottomTitles: AxisTitles(
                                                      sideTitles: SideTitles(
                                                        showTitles: true,
                                                        reservedSize: 24,
                                                        getTitlesWidget:
                                                            (value, meta) {
                                                          final index =
                                                              value.round();
                                                          if (index < 0 ||
                                                              index > 6) {
                                                            return Container();
                                                          }
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 8.0),
                                                            child: Text(
                                                              weekdayShort[
                                                                  index],
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmall
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .outfit(),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  barGroups: [
                                                    for (var i = 0; i < 7; i++)
                                                      BarChartGroupData(
                                                        x: i,
                                                        barRods: [
                                                          BarChartRodData(
                                                            toY: dailyCounts[i]
                                                                .toDouble(),
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .info,
                                                            width: 18,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6.0),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ].divide(SizedBox(height: 16.0)),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: wrapWithModel(
                                                model: _model
                                                    .progressStatCardModel1,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: ProgressStatCardWidget(
                                                  title: 'Emoción principal',
                                                  value: functions
                                                      .mostFrequentEmotion(
                                                          columnPaddingRecordsRecordList
                                                              .toList()),
                                                  subtitle:
                                                      'Frecuencia semanal',
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: wrapWithModel(
                                                model: _model
                                                    .progressStatCardModel2,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: ProgressStatCardWidget(
                                                  title: 'Registros',
                                                  value:
                                                      columnPaddingRecordsRecordList
                                                          .length
                                                          .toString(),
                                                  subtitle: 'Total semana',
                                                ),
                                              ),
                                            ),
                                          ].divide(SizedBox(width: 16.0)),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: wrapWithModel(
                                                model: _model
                                                    .progressStatCardModel3,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: ProgressStatCardWidget(
                                                  title:
                                                      'Promedio de intensidad',
                                                  value: functions
                                                      .averageIntensityLabel(
                                                          columnPaddingRecordsRecordList
                                                              .toList()),
                                                  subtitle: 'Escala 1-10',
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: wrapWithModel(
                                                model: _model
                                                    .progressStatCardModel4,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: ProgressStatCardWidget(
                                                  title: 'Conducta principal',
                                                  value: topBehavior,
                                                  subtitle: 'Más frecuente',
                                                ),
                                              ),
                                            ),
                                          ].divide(SizedBox(width: 16.0)),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: wrapWithModel(
                                                model: _model
                                                    .progressStatCardModel5,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: ProgressStatCardWidget(
                                                  title: 'Emociones positivas',
                                                  value:
                                                      '${functions.positiveEmotionPercentage(columnPaddingRecordsRecordList).round()}%',
                                                  subtitle: 'Del total semanal',
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: wrapWithModel(
                                                model: _model
                                                    .progressStatCardModel6,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: ProgressStatCardWidget(
                                                  title: 'Emociones negativas',
                                                  value:
                                                      '${functions.negativeEmotionPercentage(columnPaddingRecordsRecordList).round()}%',
                                                  subtitle: 'Del total semanal',
                                                ),
                                              ),
                                            ),
                                          ].divide(SizedBox(width: 16.0)),
                                        ),
                                      ].divide(SizedBox(height: 16.0)),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          'Emociones frecuentes',
                                          style: FlutterFlowTheme.of(context)
                                              .titleMedium
                                              .override(
                                                font: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontStyle,
                                                lineHeight: 1.45,
                                              ),
                                        ),
                                        Wrap(
                                          spacing: 8.0,
                                          runSpacing: 8.0,
                                          alignment: WrapAlignment.start,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.start,
                                          direction: Axis.horizontal,
                                          runAlignment: WrapAlignment.start,
                                          verticalDirection:
                                              VerticalDirection.down,
                                          clipBehavior: Clip.none,
                                          children: [
                                            for (final entry in emotionCounts)
                                              EmotionChipWidget(
                                                key: ValueKey(
                                                    'emotion-${entry.key}'),
                                                color: emotionColor(
                                                    context, entry.key),
                                                label:
                                                    '${entry.key} (${entry.value})',
                                              ),
                                          ],
                                        ),
                                      ].divide(SizedBox(height: 16.0)),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(32.0),
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(24.0),
                                        child: Container(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Conductas monitoreadas',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .titleMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .outfit(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMedium
                                                                  .fontStyle,
                                                          lineHeight: 1.45,
                                                        ),
                                                  ),
                                                  Text(
                                                    'Ver todas',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .labelLarge
                                                        .override(
                                                          font: GoogleFonts
                                                              .outfit(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelLarge
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelLarge
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .onSurface,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontStyle,
                                                          lineHeight: 1.4,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                height: 16.0,
                                                thickness: 1.0,
                                                indent: 0.0,
                                                endIndent: 0.0,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                              ),
                                              if (behaviorCounts.isEmpty)
                                                Text(
                                                  'No se registraron conductas esta semana.',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts
                                                            .outfit(),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        letterSpacing: 0.0,
                                                      ),
                                                )
                                              else
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    for (final entry
                                                        in behaviorCounts
                                                            .take(5))
                                                      BehaviorItemWidget(
                                                        key: ValueKey(
                                                            'behavior-${entry.key}'),
                                                        icon: Icon(
                                                          behaviorIcon(
                                                              entry.key),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          size: 20.0,
                                                        ),
                                                        label: entry.key,
                                                        status:
                                                            '${entry.value} ${entry.value == 1 ? 'vez' : 'veces'} esta semana',
                                                        isPositive: false,
                                                      ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                            ].divide(SizedBox(height: 16.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primary10,
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                        shape: BoxShape.rectangle,
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context)
                                              .primary30,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(24.0),
                                        child: Container(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.lightbulb_rounded,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .onSurface,
                                                size: 24.0,
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Reflexión de la semana',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .labelLarge
                                                          .override(
                                                            font: GoogleFonts
                                                                .outfit(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelLarge
                                                                      .fontStyle,
                                                            ),
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .onSurface,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelLarge
                                                                    .fontStyle,
                                                            lineHeight: 1.4,
                                                          ),
                                                    ),
                                                    Text(
                                                      _weeklyReflection(
                                                          dailyIntensity),
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .outfit(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.5,
                                                              ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 4.0)),
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 16.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 32.0,
                                    ),
                                  ].divide(SizedBox(height: 24.0)),
                                ),
                              );
                            },
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
                child: BottomNav4Widget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressErrorState extends StatelessWidget {
  const _ProgressErrorState({
    required this.bottomNavModel,
    required this.onUpdate,
  });

  final BottomNav4Model bottomNavModel;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 64.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: FlutterFlowTheme.of(context).error,
                size: 40.0,
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                child: Text(
                  'No se pudo cargar tu progreso. Intenta nuevamente.',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.outfit(),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressEmptyState extends StatelessWidget {
  const _ProgressEmptyState({
    required this.bottomNavModel,
    required this.onUpdate,
  });

  final BottomNav4Model bottomNavModel;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tu progreso semanal',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.comfortaa(fontWeight: FontWeight.bold),
                color: FlutterFlowTheme.of(context).primaryText,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
              ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 48.0, 0.0, 48.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insights_rounded,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 40.0,
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 4.0),
                child: Text(
                  'Aún no tienes registros esta semana',
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
                'Registra cómo te sientes para ver tu progreso aquí.',
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
      ],
    );
  }
}

const _weekdayFull = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];

String _weeklyReflection(List<double?> dailyIntensity) {
  var maxIndex = -1;
  var maxValue = -1.0;
  for (var i = 0; i < dailyIntensity.length; i++) {
    final value = dailyIntensity[i];
    if (value != null && value > maxValue) {
      maxValue = value;
      maxIndex = i;
    }
  }
  if (maxIndex == -1) {
    return 'Sigue registrando tus emociones para descubrir patrones en tu semana.';
  }
  return 'Tu intensidad emocional promedio más alta fue el ${_weekdayFull[maxIndex]} (${maxValue.toStringAsFixed(1)}/10). ¿Hay algo específico que podrías preparar con anticipación?';
}
