import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _FaqItem {
  const _FaqItem(this.question, this.answer);
  final String question;
  final String answer;
}

class _FaqCategory {
  const _FaqCategory(this.title, this.icon, this.items);
  final String title;
  final IconData icon;
  final List<_FaqItem> items;
}

const _kFaqCategories = [
  _FaqCategory('Registro emocional', Icons.favorite_border_rounded, [
    _FaqItem(
      '¿Cómo registro cómo me siento?',
      'Desde la pantalla principal toca "Registrar emoción", elige la '
          'emoción que más se acerca a lo que sientes y la intensidad. '
          'Puedes agregar una nota opcional para recordar el contexto.',
    ),
    _FaqItem(
      '¿Para qué sirve llevar un registro?',
      'Registrar cómo te sientes te ayuda a notar patrones a lo largo del '
          'tiempo (por ejemplo, qué días o situaciones te generan más '
          'malestar) y a compartir esa información con quien te acompañe '
          'en tu proceso, si así lo decides.',
    ),
    _FaqItem(
      '¿Puedo editar o eliminar un registro?',
      'Sí. Ve a "Mis Registros", busca el registro que quieres modificar '
          'y ábrelo para editarlo o eliminarlo.',
    ),
  ]),
  _FaqCategory('Ejercicios de regulación', Icons.self_improvement_rounded, [
    _FaqItem(
      '¿Qué son las herramientas de regulación?',
      'Son ejercicios breves (respiración guiada, técnica 5-4-3-2-1, '
          'enfoque en sonidos, vibración consciente, observación '
          'consciente) pensados para ayudarte a calmarte cuando sientes '
          'ansiedad, estrés o malestar intenso.',
    ),
    _FaqItem(
      '¿Cuándo debería usarlas?',
      'Puedes usarlas en cualquier momento, pero suelen ser más útiles '
          'apenas notas que una emoción se está intensificando, antes de '
          'que se vuelva abrumadora.',
    ),
  ]),
  _FaqCategory('Tareas e indicaciones', Icons.assignment_outlined, [
    _FaqItem(
      '¿Qué son las tareas?',
      'Son indicaciones o pequeños compromisos de autocuidado que puedes '
          'crear para ti mismo/a (o que en el futuro podría asignarte un '
          'profesional). Incluyen un título, una descripción opcional y, '
          'si quieres, una fecha.',
    ),
    _FaqItem(
      '¿Cómo marco una tarea como completada?',
      'En la lista de tareas, toca el círculo a la izquierda de cada '
          'tarea para marcarla como completada o pendiente nuevamente.',
    ),
  ]),
  _FaqCategory('Racha y progreso', Icons.local_fire_department_outlined, [
    _FaqItem(
      '¿Cómo se calcula mi racha de días seguidos?',
      'Cuenta los días consecutivos, incluyendo hoy, en los que registraste '
          'al menos una emoción. Si dejas pasar un día sin registrar, la '
          'racha se reinicia.',
    ),
    _FaqItem(
      '¿Qué significa el "promedio" en mi perfil?',
      'Es un resumen de la intensidad emocional de tus registros más '
          'recientes, para darte una idea general de cómo te has sentido.',
    ),
    _FaqItem(
      '¿Dónde veo mi progreso semanal?',
      'En "Progreso semanal" puedes ver un resumen visual de tus registros, '
          'emociones más frecuentes y tendencias de la semana.',
    ),
  ]),
  _FaqCategory('Cuenta y privacidad', Icons.security_rounded, [
    _FaqItem(
      '¿Cómo cambio mi nombre, teléfono o foto?',
      'Ve a "Mi Perfil" y toca el ícono de engranaje, en la parte superior '
          'derecha, para abrir "Editar Perfil".',
    ),
    _FaqItem(
      '¿Quién puede ver mis registros?',
      'Tus registros, tareas y preferencias están protegidos por reglas de '
          'acceso: solo tú puedes leer o modificar tu propia información. '
          'Puedes revisar más detalles en "Privacidad y Datos", dentro de '
          'tu perfil.',
    ),
    _FaqItem(
      '¿Cómo activo o desactivo los recordatorios diarios?',
      'En "Mi Perfil" toca "Recordatorios" y activa o desactiva el '
          'interruptor. Recibirás un aviso diario para registrar cómo te '
          'sientes.',
    ),
    _FaqItem(
      '¿Cómo cierro sesión?',
      'Al final de "Mi Perfil" encontrarás el botón "Cerrar Sesión".',
    ),
  ]),
];

class HelpCenterWidget extends StatefulWidget {
  const HelpCenterWidget({super.key});

  static String routeName = 'HelpCenter';
  static String routePath = '/helpCenter';

  @override
  State<HelpCenterWidget> createState() => _HelpCenterWidgetState();
}

class _HelpCenterWidgetState extends State<HelpCenterWidget> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _query.isEmpty
        ? _kFaqCategories
        : _kFaqCategories
            .map((category) {
              final items = category.items
                  .where((item) =>
                      item.question.toLowerCase().contains(_query) ||
                      item.answer.toLowerCase().contains(_query))
                  .toList();
              return _FaqCategory(category.title, category.icon, items);
            })
            .where((category) => category.items.isNotEmpty)
            .toList();

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
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
                      'Centro de Ayuda',
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
                  SizedBox(width: 40.0),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 16.0),
              child: Container(
                height: 44.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                      color: FlutterFlowTheme.of(context).alternate),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 8.0, 0.0),
                      child: Icon(
                        Icons.search_rounded,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        size: 20.0,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Busca una pregunta...',
                          hintStyle:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.outfit(),
                                    color:
                                        FlutterFlowTheme.of(context)
                                            .secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.outfit(),
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      InkWell(
                        onTap: () => _searchController.clear(),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 12.0, 0.0),
                          child: Icon(
                            Icons.close_rounded,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 18.0,
                          ),
                        ),
                      )
                    else
                      SizedBox(width: 12.0),
                  ],
                ),
              ),
            ),
            Expanded(
              child: filteredCategories.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 40.0,
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 12.0, 0.0, 4.0),
                              child: Text(
                                'Sin resultados',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold),
                                      color:
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            Text(
                              'Prueba con otras palabras, o contáctanos '
                              'desde "Contacto de Apoyo".',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.outfit(),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          24.0, 0.0, 24.0, 24.0),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        return Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 20.0),
                          child: _FaqCategorySection(category: category),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqCategorySection extends StatelessWidget {
  const _FaqCategorySection({required this.category});

  final _FaqCategory category;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 0.0, 8.0),
          child: Row(
            children: [
              Icon(
                category.icon,
                color: FlutterFlowTheme.of(context).primary,
                size: 18.0,
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                child: Text(
                  category.title,
                  style: FlutterFlowTheme.of(context).labelLarge.override(
                        font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            children: [
              for (var i = 0; i < category.items.length; i++)
                _FaqTile(
                  item: category.items[i],
                  showDivider: i != category.items.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.item, required this.showDivider});

  final _FaqItem item;
  final bool showDivider;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.question,
                        style: FlutterFlowTheme.of(context)
                            .bodyLarge
                            .override(
                              font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600),
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      AnimatedCrossFade(
                        firstChild: SizedBox(height: 0.0),
                        secondChild: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 8.0, 0.0, 0.0),
                          child: Text(
                            widget.item.answer,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.outfit(),
                                  color:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                  letterSpacing: 0.0,
                                  lineHeight: 1.5,
                                ),
                          ),
                        ),
                        crossFadeState: _expanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: Duration(milliseconds: 200),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
                  child: Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 22.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.showDivider)
          Divider(
            height: 1.0,
            thickness: 1.0,
            indent: 16.0,
            endIndent: 16.0,
            color: FlutterFlowTheme.of(context).alternate,
          ),
      ],
    );
  }
}
