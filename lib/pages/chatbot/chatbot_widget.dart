import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/chatbot_service.dart';

enum _EntryKind { user, assistant, error }

class _ChatEntry {
  const _ChatEntry({required this.kind, required this.text});

  final _EntryKind kind;
  final String text;
}

const _kInitialGreeting =
    'Hola 👋 Soy el asistente de Equilibra.\n\n'
    'Puedo ayudarte con preguntas sobre el uso de la aplicación, el registro '
    'emocional, los ejercicios de regulación y tu bienestar dentro de la app.\n\n'
    '¿En qué puedo ayudarte?';

/// Chatbot screen: the UI only ever talks to [ChatbotService], which in turn
/// only ever talks to the `chatWithGemini` Cloud Function. Neither this file
/// nor any other Dart file ever sees the Gemini API key — it lives solely in
/// the Cloud Function's environment (Firebase Secret Manager).
class ChatbotWidget extends StatefulWidget {
  const ChatbotWidget({super.key});

  static String routeName = 'Chatbot';
  static String routePath = '/chatbot';

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  final _chatbotService = ChatbotService();
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  final List<_ChatEntry> _entries = [
    const _ChatEntry(kind: _EntryKind.assistant, text: _kInitialGreeting),
  ];

  bool _isSending = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  List<ChatMessage> get _historyForService => _entries
      .where((e) => e.kind != _EntryKind.error)
      .map((e) => ChatMessage(
            role: e.kind == _EntryKind.assistant
                ? ChatMessageRole.assistant
                : ChatMessageRole.user,
            content: e.text,
          ))
      .toList();

  Future<void> _send() async {
    if (_isSending) return;
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    // Send the history as it stood *before* this new message, so the
    // backend can use it as conversational context for this turn.
    final history = _historyForService;

    setState(() {
      _entries.add(_ChatEntry(kind: _EntryKind.user, text: text));
      _isSending = true;
    });
    _inputController.clear();
    _scrollToBottom();

    try {
      final reply =
          await _chatbotService.sendMessage(message: text, history: history);
      if (!mounted) return;
      setState(() {
        _entries.add(_ChatEntry(kind: _EntryKind.assistant, text: reply));
      });
    } on ChatbotException catch (e) {
      if (!mounted) return;
      setState(() {
        _entries.add(_ChatEntry(kind: _EntryKind.error, text: e.message));
      });
    } finally {
      if (mounted) setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildMessageList(context)),
              _buildInputBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.0, 16.0, 24.0, 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => context.safePop(),
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              width: 40.0,
              height: 40.0,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_rounded,
                color: FlutterFlowTheme.of(context).primaryText,
                size: 24.0,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.forum_rounded,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 20.0,
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(6.0, 0.0, 0.0, 0.0),
                  child: Text(
                    'Preguntas frecuentes',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                          font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                          color: FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 40.0),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context) {
    final itemCount = _entries.length + (_isSending ? 1 : 0);
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 8.0),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= _entries.length) {
          return _buildTypingIndicator(context);
        }
        return _buildBubble(context, _entries[index]);
      },
    );
  }

  Widget _buildBubble(BuildContext context, _ChatEntry entry) {
    final isUser = entry.kind == _EntryKind.user;
    final isError = entry.kind == _EntryKind.error;

    final Color background;
    final Color foreground;
    final BorderRadius radius;
    if (isUser) {
      background = FlutterFlowTheme.of(context).primary;
      foreground = FlutterFlowTheme.of(context).onPrimary;
      radius = BorderRadius.only(
        topLeft: Radius.circular(18.0),
        topRight: Radius.circular(18.0),
        bottomLeft: Radius.circular(18.0),
        bottomRight: Radius.circular(4.0),
      );
    } else if (isError) {
      background = FlutterFlowTheme.of(context).error20;
      foreground = FlutterFlowTheme.of(context).error;
      radius = BorderRadius.only(
        topLeft: Radius.circular(4.0),
        topRight: Radius.circular(18.0),
        bottomLeft: Radius.circular(18.0),
        bottomRight: Radius.circular(18.0),
      );
    } else {
      background = FlutterFlowTheme.of(context).secondaryBackground;
      foreground = FlutterFlowTheme.of(context).primaryText;
      radius = BorderRadius.only(
        topLeft: Radius.circular(4.0),
        topRight: Radius.circular(18.0),
        bottomLeft: Radius.circular(18.0),
        bottomRight: Radius.circular(18.0),
      );
    }

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 4.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 8.0, 0.0),
              child: Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.spa_rounded,
                color: isError
                    ? FlutterFlowTheme.of(context).error
                    : FlutterFlowTheme.of(context).primary,
                size: 18.0,
              ),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: background,
                borderRadius: radius,
                border: isError
                    ? Border.all(color: FlutterFlowTheme.of(context).error)
                    : null,
              ),
              child: Text(
                entry.text,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.outfit(),
                      color: foreground,
                      letterSpacing: 0.0,
                      lineHeight: 1.4,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
            child: Icon(
              Icons.spa_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 18.0,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.0),
                topRight: Radius.circular(18.0),
                bottomLeft: Radius.circular(18.0),
                bottomRight: Radius.circular(18.0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12.0,
                  height: 12.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation(
                        FlutterFlowTheme.of(context).primary),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                  child: Text(
                    'Equilibra está escribiendo...',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
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
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: BoxConstraints(minHeight: 48.0),
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 8.0, 4.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).alternate,
                ),
              ),
              child: TextField(
                controller: _inputController,
                minLines: 1,
                maxLines: 4,
                maxLength: 1000,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Escribe tu pregunta...',
                  hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.outfit(),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                  border: InputBorder.none,
                  isDense: true,
                  counterText: '',
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.outfit(),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
            child: InkWell(
              onTap: _isSending || _inputController.text.trim().isEmpty
                  ? null
                  : _send,
              borderRadius: BorderRadius.circular(24.0),
              child: Container(
                width: 48.0,
                height: 48.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isSending || _inputController.text.trim().isEmpty
                      ? FlutterFlowTheme.of(context).alternate
                      : FlutterFlowTheme.of(context).primary,
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: FlutterFlowTheme.of(context).onPrimary,
                  size: 22.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
