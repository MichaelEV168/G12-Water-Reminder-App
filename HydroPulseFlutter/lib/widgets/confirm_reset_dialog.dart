import 'package:flutter/material.dart';

Future<bool> confirmResetData(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
          title: const Text('Reset All App Data?'),
          content: const Text(
            'This will erase your saved logs and reset goals and reminders to defaults.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm Reset'),
            ),
          ],
        ),
      ) ??
      false;
}
