/// How often a recurring rule repeats.
///
/// [none] means the source transaction does not recur. The remaining values
/// drive the [RecurringSchedule] stepping logic (every `interval` days, weeks,
/// months, or years).
enum RecurringFrequency {
  none,
  daily,
  weekly,
  monthly,
  yearly;

  /// Whether this frequency actually produces repeated occurrences.
  bool get repeats => this != RecurringFrequency.none;

  /// Whether a [RecurringRepeatPosition] is meaningful for this frequency.
  ///
  /// Daily rules land on an exact day, so repeat position is ignored; weekly,
  /// monthly, and yearly rules can place occurrences at same day, start, or end
  /// of their period.
  bool get supportsRepeatPosition =>
      this == RecurringFrequency.weekly ||
      this == RecurringFrequency.monthly ||
      this == RecurringFrequency.yearly;
}
