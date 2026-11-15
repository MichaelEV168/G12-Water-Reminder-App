import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/hydration_log.dart';
import '../state/hydration_state.dart';
import '../widgets/screen_title.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({required this.state, super.key});

  final HydrationState state;

  @override
  Widget build(BuildContext context) {
    final days = state.selectedWeek;
    final totals = state.selectedWeekTotals;
    final average = totals.isEmpty ? 0 : totals.reduce((a, b) => a + b) ~/ totals.length;
    final dateRange = '${_month(days.first.month)} ${days.first.day} - ${_month(days.last.month)} ${days.last.day}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const ScreenTitle(
          title: 'Hydration History',
          subtitle: 'Track your weekly performance and log',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(18)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => state.changeWeek(-1),
                icon: const Icon(Icons.chevron_left),
                color: Colors.white,
                tooltip: 'Previous week',
              ),
              Column(
                children: [
                  Text(state.weekOffset == 0 ? 'This Week' : dateRange, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                  Text(dateRange.toUpperCase(), style: const TextStyle(color: Colors.white60, fontSize: 10)),
                ],
              ),
              IconButton(
                onPressed: state.weekOffset < 0 ? () => state.changeWeek(1) : null,
                icon: const Icon(Icons.chevron_right),
                color: Colors.white,
                disabledColor: Colors.white30,
                tooltip: 'Next week',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 13),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Weekly Average', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          Text('${_format(average)} ml/day', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.more_horiz, size: 15, color: Colors.blueGrey),
                    const SizedBox(width: 4),
                    Text('Goal (${_format(state.dailyGoal)}ml)', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 170,
                  child: _WeeklyBars(values: totals, goal: state.dailyGoal),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: days.map((day) => SizedBox(
                    width: 30,
                    child: Text(_weekdayShort(day.weekday), textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.blueGrey)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 21),
        Row(
          children: [
            const Expanded(child: Text("Today's Logs", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800))),
            TextButton(
              onPressed: state.todayLogs.isEmpty
                  ? null
                  : () {
                      state.clearTodayLogs();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Cleared today's intake logs")),
                      );
                    },
              child: const Text('Clear Logs', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (state.todayLogs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No intake recorded today yet.', style: TextStyle(color: Colors.blueGrey, fontSize: 12))),
          )
        else
          ...state.todayLogs.map((log) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _LogTile(
                  log: log,
                  onEdit: () => _editLog(context, log),
                  onDelete: () => _deleteLog(context, log),
                ),
              )),
      ],
    );
  }

  Future<void> _editLog(BuildContext context, HydrationLog log) async {
    final amountController = TextEditingController(text: '${log.amount}');
    var selectedTime = TimeOfDay.fromDateTime(log.time);
    final amount = await showDialog<int>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Intake Log'),
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
                  if (picked != null) {
                    setDialogState(() => selectedTime = picked);
                  }
                },
                icon: const Icon(Icons.access_time),
                label: Text(selectedTime.format(context)),
              ),
              const SizedBox(height: 12),
              const Text('Amount (ml)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return RegExp(r'^-?\d*$').hasMatch(newValue.text)
                        ? newValue
                        : oldValue;
                  }),
                ],
                decoration: const InputDecoration(
                  suffixText: 'ml',
                  border: OutlineInputBorder(),
                  helperText: 'Use a negative amount for a correction.',
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
                final editedAmount = int.tryParse(amountController.text.trim());
                if (editedAmount == null || editedAmount == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a non-zero amount.')),
                  );
                  return;
                }
                Navigator.pop(dialogContext, editedAmount);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    amountController.dispose();

    if (amount == null) return;
    final updatedTime = DateTime(
      log.time.year,
      log.time.month,
      log.time.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    if (!state.updateLog(log.id, time: updatedTime, amount: amount)) {
      _showMessage(context, 'The updated amount cannot reduce intake below 0 ml.', isError: true);
      return;
    }
    _showMessage(context, 'Intake log updated');
  }

  Future<void> _deleteLog(BuildContext context, HydrationLog log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete intake log?'),
        content: const Text("This will update today's hydration total."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    if (state.deleteLog(log.id)) {
      _showMessage(context, 'Intake log deleted');
    }
  }

  void _showMessage(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
      ));
  }
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({required this.values, required this.goal});

  final List<int> values;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final highestTotal = values.fold<int>(0, (highest, value) => value > highest ? value : highest);
    final maxValue = math.max(goal * 1.2, highestTotal).toDouble();
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: constraints.maxHeight * (1 - goal / maxValue),
            child: const Divider(height: 1, color: Color(0xFF94A3B8)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: values.map((value) {
              final barHeight = (constraints.maxHeight * value / maxValue)
                  .clamp(0.0, constraints.maxHeight)
                  .toDouble();
              final metGoal = value >= goal;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 24,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: metGoal ? Theme.of(context).colorScheme.primary : Colors.blueGrey.shade200,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({
    required this.log,
    required this.onEdit,
    required this.onDelete,
  });

  final HydrationLog log;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final positive = log.amount > 0;
    final time = '${log.time.hour.toString().padLeft(2, '0')}:${log.time.minute.toString().padLeft(2, '0')}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: positive ? Theme.of(context).colorScheme.primaryContainer : const Color(0xFFFFE4E6),
              child: Icon(positive ? Icons.add : Icons.remove, size: 17, color: positive ? Theme.of(context).colorScheme.primary : Colors.red),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(positive ? 'Drank Water' : 'Correction', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  Text(time, style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
                ],
              ),
            ),
            Text('${positive ? '+' : ''}${log.amount} ml', style: TextStyle(fontWeight: FontWeight.w800, color: positive ? Theme.of(context).colorScheme.primary : Colors.red)),
            const SizedBox(width: 4),
            IconButton(
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.edit_outlined, size: 18),
              tooltip: 'Edit intake log',
            ),
            IconButton(
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.delete_outline, size: 18),
              color: Colors.red,
              tooltip: 'Delete intake log',
            ),
          ],
        ),
      ),
    );
  }
}

String _weekdayShort(int day) =>
    const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day - 1];

String _month(int month) =>
    const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1];

String _format(int value) => value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
