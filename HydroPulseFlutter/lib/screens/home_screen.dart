import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/hydration_state.dart';
import '../widgets/bottle_visualizer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.state,
    required this.onOpenSchedule,
    super.key,
  });

  final HydrationState state;
  final VoidCallback onOpenSchedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final enabledReminders = state.reminders.where((item) => item.enabled);
    final nextReminder = enabledReminders.isEmpty ? null : enabledReminders.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
      children: [
        Center(
          child: Column(
            children: [
              Text("Today's Progress", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text(
                'Stay hydrated to boost your focus and vitality',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: BottleVisualizer(
            progress: state.progressPercent / 100,
            percentage: state.progressPercent,
            consumed: state.consumedToday,
            goal: state.dailyGoal,
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              children: [
                _Metric(label: 'Daily Goal', value: '${_format(state.dailyGoal)} ml'),
                _Divider(),
                _Metric(label: 'Consumed', value: '${_format(state.consumedToday)} ml', color: primary),
                _Divider(),
                _Metric(label: 'Remaining', value: '${_format(state.remainingToday)} ml', color: const Color(0xFFD97706)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text('QUICK ADD WATER', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, letterSpacing: 1)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _QuickAddButton(icon: Icons.local_drink_outlined, amount: 250, label: 'Glass', onPressed: () => _addWater(context, 250))),
            const SizedBox(width: 9),
            Expanded(child: _QuickAddButton(icon: Icons.local_drink, amount: 500, label: 'Bottle', onPressed: () => _addWater(context, 500))),
            const SizedBox(width: 9),
            Expanded(child: _QuickAddButton(icon: Icons.undo_rounded, amount: -200, label: 'Undo', isUndo: true, onPressed: () => _addWater(context, -200))),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF0369A1)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: primary.withOpacity(.18), blurRadius: 16, offset: const Offset(0, 7))],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.access_time, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Next Reminder', style: TextStyle(color: Color(0xFFE0F2FE), fontSize: 12)),
                    const SizedBox(height: 3),
                    Text(
                      nextReminder == null ? 'No reminders enabled' : '${nextReminder.time} [${nextReminder.amount} ml]',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onOpenSchedule,
                style: TextButton.styleFrom(backgroundColor: Colors.white, foregroundColor: primary),
                child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addWater(BuildContext context, int amount) {
    if (!state.addWater(amount)) {
      _showMessage(context, 'Cannot decrease water intake below 0 ml', isError: true);
      return;
    }
    if (state.soundEnabled) SystemSound.play(SystemSoundType.click);
    _showMessage(
      context,
      amount > 0 ? 'Added +$amount ml of water!' : 'Subtracted ${amount.abs()} ml',
      isSuccess: amount > 0,
    );
  }

  void _showMessage(BuildContext context, String message, {bool isError = false, bool isSuccess = false}) {
    final color = isError ? Colors.red : (isSuccess ? Colors.green : null);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ));
  }

  String _format(int value) => value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 5),
          FittedBox(child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color))),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: Theme.of(context).dividerColor);
}

class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({
    required this.icon,
    required this.amount,
    required this.label,
    required this.onPressed,
    this.isUndo = false,
  });

  final IconData icon;
  final int amount;
  final String label;
  final VoidCallback onPressed;
  final bool isUndo;

  @override
  Widget build(BuildContext context) {
    final color = isUndo ? const Color(0xFFE11D48) : Theme.of(context).colorScheme.primary;
    return Material(
      color: isUndo ? const Color(0xFFFFF1F2) : Theme.of(context).colorScheme.primaryContainer.withOpacity(.45),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
          child: Column(
            children: [
              Icon(icon, color: color, size: 23),
              const SizedBox(height: 5),
              Text('${amount > 0 ? '+' : ''}$amount ml', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
              Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
