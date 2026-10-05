import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '/config/legal_links.dart';

/// Available both before sign-in and in the profile privacy dialog.
class PrivacyLinks extends StatelessWidget {
  const PrivacyLinks({super.key});

  Future<void> _open(BuildContext context, String url) async {
    try {
      final opened =
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (opened) return;
    } catch (_) {
      // Report launch failures, including launchUrl returning false.
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No se pudo abrir la página. Inténtalo nuevamente.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton.icon(
            onPressed: () => _open(context, publicPrivacyPolicyUrl),
            icon: const Icon(Icons.privacy_tip_outlined),
            label: const Text('Política de Privacidad'),
          ),
          TextButton.icon(
            onPressed: () => _open(context, accountDeletionUrl),
            icon: const Icon(Icons.person_remove_outlined),
            label: const Text('Solicitar eliminación de cuenta'),
          ),
          const Text(
            'La solicitud se procesa después de verificar tu identidad. '
            'Desactivar la cuenta no elimina tu cuenta ni tus datos.',
          ),
        ],
      );
}
