import 'package:flutter/material.dart';
import '/services/account_deletion_service.dart';

Future<bool> showAccountDeletionDialog({
  required BuildContext context,
  required String targetEmail,
  required Future<void> Function(String password, String email) onConfirm,
  bool adminMode = false,
}) async =>
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AccountDeletionDialog(
        targetEmail: targetEmail,
        adminMode: adminMode,
        onConfirm: onConfirm,
      ),
    ) ??
    false;

class AccountDeletionDialog extends StatefulWidget {
  const AccountDeletionDialog(
      {super.key,
      required this.targetEmail,
      required this.onConfirm,
      this.adminMode = false});
  final String targetEmail;
  final bool adminMode;
  final Future<void> Function(String password, String email) onConfirm;
  @override
  State<AccountDeletionDialog> createState() => _AccountDeletionDialogState();
}

class _AccountDeletionDialogState extends State<AccountDeletionDialog> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_busy) return;
    if (_email.text.trim().toLowerCase() != widget.targetEmail.toLowerCase() ||
        _password.text.isEmpty) {
      setState(() => _error =
          'Escribe el correo indicado y tu contraseña para confirmar.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onConfirm(_password.text, _email.text.trim());
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted)
        setState(() {
          _busy = false;
          _password.clear();
          _error = error is AccountDeletionException
              ? error.message
              : 'No se confirmó la eliminación. Revisa tu conexión e inténtalo nuevamente.';
        });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_busy,
        child: AlertDialog(
          title: const Text('Eliminar cuenta definitivamente'),
          content: SingleChildScrollView(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                  'Se eliminará la cuenta ${widget.targetEmail} y comenzará el borrado '
                  'de sus registros, conversaciones y archivos personales. Esta acción no se puede deshacer. '
                  'Desactivar una cuenta es una opción diferente.'),
              const SizedBox(height: 16),
              TextField(
                  controller: _email,
                  enabled: !_busy,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                      labelText: 'Escribe el correo de la cuenta a eliminar')),
              const SizedBox(height: 12),
              TextField(
                  controller: _password,
                  enabled: !_busy,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                      labelText: widget.adminMode
                          ? 'Tu contraseña de administrador'
                          : 'Tu contraseña actual')),
              if (_error != null)
                Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red))),
              if (_busy)
                const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LinearProgressIndicator()),
            ],
          )),
          actions: [
            TextButton(
                onPressed: _busy ? null : () => Navigator.pop(context, false),
                child: const Text('Cancelar')),
            ElevatedButton.icon(
                onPressed: _busy ? null : _confirm,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white),
                icon: const Icon(Icons.delete_forever),
                label:
                    Text(_busy ? 'Eliminando…' : 'Eliminar definitivamente')),
          ],
        ),
      );
}
