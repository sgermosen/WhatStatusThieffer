import 'package:flutter/material.dart';
import 'package:status_saver/app/app_localizations.dart';

/// Explains why the app needs access to WhatsApp's statuses folder (Android
/// 11+) and opens the system folder picker.
class FolderAccessPrompt extends StatelessWidget {
  final VoidCallback onGrant;

  const FolderAccessPrompt({super.key, required this.onGrant});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_open, size: 80, color: Colors.teal),
            const SizedBox(height: 16),
            Text(i18n.translate('grant_status_folder_title'),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(i18n.translate('grant_status_folder_message'),
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: onGrant,
              icon: const Icon(Icons.lock_open),
              label: Text(i18n.translate('grant_access')),
            ),
          ],
        ),
      ),
    );
  }
}
