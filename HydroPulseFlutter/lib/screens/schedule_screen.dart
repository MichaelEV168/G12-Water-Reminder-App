import 'package:flutter/material.dart';

import '../models/reminder.dart';
import '../state/hydration_state.dart';
import '../widgets/reminder_dialog.dart';
import '../widgets/screen_title.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({required this.state, super.key});

  final HydrationState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Row(
          children: [
            const Expanded(
              child: ScreenTitle(
                title: 'Schedule',
                subtitle: 'Manage your hourly hydration reminders',
              ),
            ),
            IconButton.filled(
              onPressed: () => _addReminder(context),
              icon: const Icon(Icons.add),
              tooltip: 'Add reminder',
            ),
          ],
        ),
        const SizedBox(height: 18),
        Card(
          color: const Color(0xFF0F172A),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _HoursInfo(icon: Icons.nightlight_round, title: 'Quiet Hours', time: '10:00 PM - 05:00 AM', iconColor: Colors.amber.shade200)),
                Container(height: 42, width: 1, color: Colors.white24),
                const SizedBox(width: 14),
                Expanded(child: _HoursInfo(icon: Icons.wb_sunny_rounded, title: 'Active Mode', time: '06:00 AM - 09:00 PM', iconColor: Colors.amber)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        if (state.reminders.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text('No reminders yet. Add one to get started.')),
          )
        else
          ...state.reminders.map((reminder) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ReminderTile(
                  reminder: reminder,
                  onToggle: () => state.toggleReminder(reminder.id),
                  onDelete: () {
                    state.deleteReminder(reminder.id);
                    _showMessage(context, 'Reminder removed');
                  },
                ),
              )),
      ],
    );
  }

  Future<void> _addReminder(BuildContext context) async {
    await showAddReminderDialog(
      context,
      onSave: (draft) {
        state.addReminder(draft.time, draft.amount);
        _showMessage(context, 'Reminder added for ${draft.time}');
      },
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }
}

class _HoursInfo extends StatelessWidget {
  const _HoursInfo({
    required this.icon,
    required this.title,
    required this.time,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String time;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                const SizedBox(height: 3),
                Text(time, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      );
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.reminder,
    required this.onToggle,
    required this.onDelete,
  });

  final HydrationReminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: reminder.enabled ? colorScheme.primaryContainer : colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                reminder.time,
                style: TextStyle(
                  color: reminder.enabled ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Opacity(
                opacity: reminder.enabled ? 1 : .55,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reminder.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text('${reminder.amount} ml Target', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
            Switch(value: reminder.enabled, onChanged: (_) => onToggle()),
            IconButton(
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close, size: 19),
              color: colorScheme.onSurfaceVariant,
              tooltip: 'Delete reminder',
            ),
          ],
        ),
      ),
    );
  }
}
