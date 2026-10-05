import '/auth/firebase_auth/auth_util.dart';
import '/components/account_deletion_dialog.dart';
import '/components/button/button_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/account_deletion_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Shared personal-account action for patients, psychologists and administrators.
class DeleteMyAccountButton extends StatefulWidget {
  const DeleteMyAccountButton({super.key});

  @override
  State<DeleteMyAccountButton> createState() => _DeleteMyAccountButtonState();
}

class _DeleteMyAccountButtonState extends State<DeleteMyAccountButton> {
  bool _busy = false;

  Future<void> _deleteAccount() async {
    if (_busy) return;
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    final router = GoRouter.of(context);
    setState(() => _busy = true);
    try {
      final deleted = await showAccountDeletionDialog(
        context: context,
        targetEmail: email,
        onConfirm: (password, confirmationEmail) => AccountDeletionService()
            .deleteAccount(
                password: password, confirmationEmail: confirmationEmail),
      );
      if (!deleted) return;
      router.prepareAuthEvent();
      await authManager.signOut();
      router.clearRedirectLocation();
      router.goNamed(TestScreenWidget.routeName);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: _busy ? null : _deleteAccount,
        child: ButtonWidget(
          icon: Icon(
            Icons.delete_forever_rounded,
            color: FlutterFlowTheme.of(context).onError,
            size: 24.0,
          ),
          iconPresent: true,
          content: 'Eliminar mi cuenta',
          variant: 'destructive',
          size: 'medium',
          fullWidth: true,
          disabled: _busy,
        ),
      );
}
