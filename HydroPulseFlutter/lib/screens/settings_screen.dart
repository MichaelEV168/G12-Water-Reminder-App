import 'package:flutter/material.dart';

import '../state/hydration_state.dart';
import '../widgets/confirm_reset_dialog.dart';
import '../widgets/screen_title.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({required this.state, super.key});

  final HydrationState state;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _goalController;
  late int _lastGoal;

  @override
  void initState() {
    super.initState();
    _lastGoal = widget.state.dailyGoal;
    _goalController = TextEditingController(text: '$_lastGoal');
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_lastGoal != widget.state.dailyGoal) {
      _lastGoal = widget.state.dailyGoal;
      _goalController.text = '$_lastGoal';
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const ScreenTitle(
          title: 'Settings',
          subtitle: 'Customize preferences and hydration goals',
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Target Goal (ml)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _goalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'e.g. 2000',
                          suffixText: 'ml',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    FilledButton(onPressed: _saveGoal, child: const Text('Save Goal')),
                  ],
                ),
                const SizedBox(height: 11),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [1500, 2000, 2500, 3000]
                      .map((goal) => OutlinedButton(
                            onPressed: () => _setGoal(goal),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Text('${_format(goal)} ml', style: const TextStyle(fontSize: 11)),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SwitchListTile(
                secondary: const _PreferenceIcon(icon: Icons.dark_mode_outlined, color: Color(0xFF9333EA)),
                title: const Text('Dark Appearance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                subtitle: const Text('Switch app theme color', style: TextStyle(fontSize: 11)),
                value: widget.state.isDarkMode,
                onChanged: widget.state.setDarkMode,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SwitchListTile(
                secondary: const _PreferenceIcon(icon: Icons.volume_up_outlined, color: Color(0xFF059669)),
                title: const Text('Sound Feedback', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                subtitle: const Text('Play audio on water log', style: TextStyle(fontSize: 11)),
                value: widget.state.soundEnabled,
                onChanged: widget.state.setSoundEnabled,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _SettingTile(
                icon: Icons.person_outline,
                color: const Color(0xFF2563EB),
                title: 'Account Profile',
                subtitle: 'Azmi (Azmi1180)',
                onTap: () => _showMessage('Profile details updated'),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _SettingTile(
                icon: Icons.language,
                color: const Color(0xFFD97706),
                title: 'Language',
                subtitle: 'English (US)',
                onTap: () => _showMessage('Language set to English (US)'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _resetData,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Reset All Data'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Color(0xFFFECACA)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  void _saveGoal() {
    final goal = int.tryParse(_goalController.text.trim());
    if (goal == null || goal <= 0) {
      _showMessage('Please enter a valid daily hydration goal!', isError: true);
      return;
    }
    widget.state.setDailyGoal(goal);
    _showMessage('Daily goal updated to ${_format(goal)} ml');
  }

  void _setGoal(int goal) {
    _goalController.text = '$goal';
    widget.state.setDailyGoal(goal);
    _showMessage('Daily goal updated to ${_format(goal)} ml');
  }

  Future<void> _resetData() async {
    if (!await confirmResetData(context)) return;
    widget.state.reset();
    _showMessage('App data has been reset to defaults');
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
      ));
  }

  String _format(int value) => value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}

class _PreferenceIcon extends StatelessWidget {
  const _PreferenceIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20),
      );
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        leading: _PreferenceIcon(icon: icon, color: color),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right, size: 19),
      );
}
