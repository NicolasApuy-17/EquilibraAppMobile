import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/psychologist_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// One patient's chat with their assigned psychologist. [conversationId] is
/// always the patient's own uid (see `conversations/{patientUid}` in
/// firestore.rules / the `assignPsychologist` Cloud Function) — both the
/// patient and their psychologist open the exact same conversation id.
///
/// Messages are read live via `.snapshots()` (protected by Firestore rules:
/// only the two participants can read) and sent through the
/// `sendConversationMessage` Cloud Function, which validates the sender is
/// actually a participant before writing anything.
class PsychologistChatWidget extends StatefulWidget {
  const PsychologistChatWidget({super.key, required this.conversationId});

  final String conversationId;

  static String routeName = 'PsychologistChat';
  static String routePath = '/psychologistChat';

  @override
  State<PsychologistChatWidget> createState() =>
      _PsychologistChatWidgetState();
}

class _PsychologistChatWidgetState extends State<PsychologistChatWidget> {
  final _service = PsychologistService();
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  String? _otherPartyName;
  bool _isSending = false;
  bool _loadFailed = false;

  DocumentReference get _conversationRef =>
      FirebaseFirestore.instance.collection('conversations').doc(
        widget.conversationId,
      );

  @override
  void initState() {
    super.initState();
    _loadOtherParty();
  }

  Future<void> _loadOtherParty() async {
    try {
      final snap = await _conversationRef.get();
      final data = snap.data() as Map<String, dynamic>?;
      if (data == null) {
        if (mounted) setState(() => _loadFailed = true);
        return;
      }
      final myPath = currentUserReference?.path;
      final patientRef = data['patientRef'] as DocumentReference?;
      final psychologistRef = data['psychologistRef'] as DocumentReference?;
      final otherRef = patientRef?.path == myPath ? psychologistRef : patientRef;
      if (otherRef == null) {
        if (mounted) setState(() => _loadFailed = true);
        return;
      }
      final otherSnap = await otherRef.get();
      final otherData = otherSnap.data() as Map<String, dynamic>?;
      final name = otherData?['display_name'] as String?;
      if (mounted) {
        setState(() => _otherPartyName =
            (name != null && name.isNotEmpty) ? name : 'tu contacto');
      }
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    if (_isSending) return;
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSending = true);
    _inputController.clear();
    try {
      await _service.sendConversationMessage(
        conversationId: widget.conversationId,
        text: text,
      );
      _scrollToBottom();
    } on PsychologistServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
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
              if (_loadFailed)
                Expanded(
                  child: Center(
                    child: Text(
                      'No se pudo abrir esta conversación.',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.outfit(),
                            color: FlutterFlowTheme.of(context).error,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                )
              else ...[
                Expanded(child: _buildMessageList(context)),
                _buildInputBar(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 24.0, 12.0),
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
            child: Text(
              _otherPartyName ?? 'Chat',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FlutterFlowTheme.of(context).titleLarge.override(
                    font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(width: 40.0),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _conversationRef
          .collection('messages')
          .orderBy('timestamp')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'No se pudieron cargar los mensajes.',
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
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Text(
              'Todavía no hay mensajes. Escribe el primero.',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.outfit(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
          );
        }
        _scrollToBottom();
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 8.0),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final senderRef = data['senderRef'] as DocumentReference?;
            final isMine = senderRef?.path == currentUserReference?.path;
            final text = data['text'] as String? ?? '';
            return _MessageBubble(text: text, isMine: isMine);
          },
        );
      },
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48.0),
              padding:
                  const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 8.0, 4.0),
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
                maxLength: 2000,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
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
            padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
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

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.text, required this.isMine});

  final String text;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final background = isMine
        ? FlutterFlowTheme.of(context).primary
        : FlutterFlowTheme.of(context).secondaryBackground;
    final foreground = isMine
        ? FlutterFlowTheme.of(context).onPrimary
        : FlutterFlowTheme.of(context).primaryText;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 4.0),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18.0),
                  topRight: const Radius.circular(18.0),
                  bottomLeft: Radius.circular(isMine ? 18.0 : 4.0),
                  bottomRight: Radius.circular(isMine ? 4.0 : 18.0),
                ),
              ),
              child: Text(
                text,
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
}
