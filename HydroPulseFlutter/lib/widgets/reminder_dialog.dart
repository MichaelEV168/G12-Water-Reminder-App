import 'package:flutter/material.dart';

class ReminderDraft {
  const ReminderDraft({required this.time, required this.amount});

  final String time;
  final int amount;
}

Future<void> showAddReminderDialog(
  BuildContext context, {
  required ValueChanged<ReminderDraft> onSave,
}) async {
  final amountController = TextEditingController(text: '250');
  var selectedTime = const TimeOfDay(hour: 15, minute: 0);

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Add Reminder Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (picked != null) setDialogState(() => selectedTime = picked);
              },
              icon: const Icon(Icons.access_time),
              label: Text(selectedTime.format(context)),
            ),
            const SizedBox(height: 12),
            const Text('Target Amount (ml)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                suffixText: 'ml',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = int.tryParse(amountController.text.trim());
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a valid reminder amount.')),
                );
                return;
              }
              onSave(
                ReminderDraft(
                  time:
                      '${selectedTime.hour.toString().padLeft(2, '0')}:'
                      '${selectedTime.minute.toString().padLeft(2, '0')}',
                  amount: amount,
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ),
  );
  amountController.dispose();
}
