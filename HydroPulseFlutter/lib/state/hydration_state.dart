
import 'package:flutter/foundation.dart';

import '../models/hydration_log.dart';
import '../models/reminder.dart';

class HydrationState extends ChangeNotifier {
  static const Map<String, int> _defaultHistory = {
    '2026-11-03': 1800,
    '2026-11-04': 2100,
    '2026-11-05': 1950,
    '2026-11-06': 2200,
    '2026-11-07': 1700,
    '2026-11-08': 2000,
  };

  static const List<HydrationReminder> _defaultReminders = [
    HydrationReminder(
      id: 1,
      time: '06:00',
      label: 'Morning Wake Up',
      amount: 250,
      enabled: true,
    ),
    HydrationReminder(
      id: 2,
      time: '07:00',
      label: 'Breakfast Hydration',
      amount: 200,
      enabled: true,
    ),
    HydrationReminder(
      id: 3,
      time: '08:00',
      label: 'Work Start Sip',
      amount: 200,
      enabled: true,
    ),
    HydrationReminder(
      id: 4,
      time: '09:00',
      label: 'Mid-Morning Refresh',
      amount: 200,
      enabled: false,
    ),
    HydrationReminder(
      id: 5,
      time: '10:00',
      label: 'Hydration Check',
      amount: 250,
      enabled: true,
    ),
    HydrationReminder(
      id: 6,
      time: '12:00',
      label: 'Lunchtime Water',
      amount: 300,
      enabled: true,
    ),
    HydrationReminder(
      id: 7,
      time: '14:00',
      label: 'Afternoon Boost',
      amount: 200,
      enabled: true,
    ),
    HydrationReminder(
      id: 8,
      time: '16:00',
      label: 'Late Afternoon Glass',
      amount: 200,
      enabled: true,
    ),
    HydrationReminder(
      id: 9,
      time: '18:00',
      label: 'Dinner Prep Water',
      amount: 250,
      enabled: false,
    ),
    HydrationReminder(
      id: 10,
      time: '20:00',
      label: 'Evening Relaxation',
      amount: 200,
      enabled: true,
    ),
  ];

  int dailyGoal = 2000;
  bool isDarkMode = false;
  bool soundEnabled = true;
  int weekOffset = 0;

  final List<HydrationLog> _todayLogs = [];
  final Map<String, int> _history = Map.of(_defaultHistory);
  final List<HydrationReminder> _reminders = [..._defaultReminders];

  List<HydrationLog> get todayLogs => List.unmodifiable(_todayLogs);

  List<HydrationReminder> get reminders =>
      List.unmodifiable(_reminders);

  String get todayKey => _dateKey(DateTime.now());

  int get consumedToday =>
      _history[todayKey] ??
      _todayLogs.fold<int>(
        0,
        (total, log) => total + log.amount,
      );

  int get remainingToday =>
      (dailyGoal - consumedToday).clamp(0, dailyGoal).toInt();

  int get progressPercent =>
      ((consumedToday / dailyGoal) * 100)
          .round()
          .clamp(0, 100)
          .toInt();

  // CREATE: Add a new hydration record.
  bool addWater(int amount) {
    final previousTotal = consumedToday;

    if (amount == 0 || previousTotal + amount < 0) {
      return false;
    }

    final now = DateTime.now();

    _todayLogs.insert(
      0,
      HydrationLog(
        id: now.microsecondsSinceEpoch,
        time: now,
        amount: amount,
      ),
    );

    _history[todayKey] = previousTotal + amount;

    notifyListeners();
    return true;
  }

  // UPDATE: Change an existing hydration record.
  bool updateTodayLog(int id, int newAmount) {
    final index = _todayLogs.indexWhere((log) => log.id == id);

    if (index == -1 || newAmount == 0) {
      return false;
    }

    final oldLog = _todayLogs[index];
    final difference = newAmount - oldLog.amount;
    final updatedTotal = consumedToday + difference;

    if (updatedTotal < 0) {
      return false;
    }

    _todayLogs[index] = oldLog.copyWith(
      amount: newAmount,
    );

    _history[todayKey] = updatedTotal;

    notifyListeners();
    return true;
  }

  // DELETE: Remove a hydration record by its list index.
  bool deleteTodayLogAt(int index) {
    if (index < 0 || index >= _todayLogs.length) {
      return false;
    }

    final removedLog = _todayLogs.removeAt(index);
    final updatedTotal = consumedToday - removedLog.amount;

    _history[todayKey] = updatedTotal.clamp(0, 1 << 31).toInt();

    notifyListeners();
    return true;
  }

  bool setDailyGoal(int goal) {
    if (goal <= 0) return false;

    dailyGoal = goal;
    notifyListeners();
    return true;
  }

  void clearTodayLogs() {
    _todayLogs.clear();
    _history[todayKey] = 0;
    notifyListeners();
  }

  void toggleReminder(int id) {
    final index = _reminders.indexWhere(
      (reminder) => reminder.id == id,
    );

    if (index == -1) return;

    _reminders[index] = _reminders[index].copyWith(
      enabled: !_reminders[index].enabled,
    );

    notifyListeners();
  }

  void deleteReminder(int id) {
    _reminders.removeWhere(
      (reminder) => reminder.id == id,
    );

    notifyListeners();
  }

  void addReminder(String time, int amount) {
    _reminders.add(
      HydrationReminder(
        id: DateTime.now().microsecondsSinceEpoch,
        time: time,
        label: 'Scheduled Hydration',
        amount: amount,
        enabled: true,
      ),
    );

    _reminders.sort(
      (a, b) => a.time.compareTo(b.time),
    );

    notifyListeners();
  }

  void setDarkMode(bool value) {
    isDarkMode = value;
    notifyListeners();
  }

  void setSoundEnabled(bool value) {
    soundEnabled = value;
    notifyListeners();
  }

  void changeWeek(int delta) {
    weekOffset += delta;
    notifyListeners();
  }

  List<DateTime> get selectedWeek {
    final today = DateTime.now();

    final monday = DateTime(
      today.year,
      today.month,
      today.day,
    )
        .subtract(Duration(days: today.weekday - 1))
        .add(Duration(days: weekOffset * 7));

    return List.generate(
      7,
      (index) => monday.add(Duration(days: index)),
    );
  }

  List<int> get selectedWeekTotals {
    return selectedWeek.map((day) {
      if (_dateKey(day) == todayKey) {
        return consumedToday;
      }

      return _history[_dateKey(day)] ?? 0;
    }).toList();
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  void reset() {
    dailyGoal = 2000;
    isDarkMode = false;
    soundEnabled = true;
    weekOffset = 0;

    _todayLogs.clear();

    _history
      ..clear()
      ..addAll(_defaultHistory);

    _reminders
      ..clear()
      ..addAll(_defaultReminders);

    notifyListeners();
  }
}
