
class HydrationLog {
  const HydrationLog({
    required this.id,
    required this.time,
    required this.amount,
  });

  final int id;
  final DateTime time;
  final int amount;

  HydrationLog copyWith({
    DateTime? time,
    int? amount,
  }) {
    return HydrationLog(
      id: id,
      time: time ?? this.time,
      amount: amount ?? this.amount,
    );
  }
}
