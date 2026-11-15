class HydrationReminder {
  const HydrationReminder({
    required this.id,
    required this.time,
    required this.label,
    required this.amount,
    required this.enabled,
  });

  final int id;
  final String time;
  final String label;
  final int amount;
  final bool enabled;

  HydrationReminder copyWith({bool? enabled}) {
    return HydrationReminder(
      id: id,
      time: time,
      label: label,
      amount: amount,
      enabled: enabled ?? this.enabled,
    );
  }
}
