/// Where within each repeated period an occurrence is placed.
///
/// Only meaningful for weekly, monthly, and yearly frequencies
/// (see [RecurringFrequency.supportsRepeatPosition]):
///
/// - [sameDay]: keep the same calendar position as the start date (same weekday
///   for weekly, same day-of-month for monthly, same month/day for yearly).
/// - [startOfPeriod]: first day of the period (Sunday for weekly, the 1st for
///   monthly, January 1 for yearly).
/// - [endOfPeriod]: last day of the period (Saturday for weekly, the last day
///   of the month for monthly, December 31 for yearly).
enum RecurringRepeatPosition { sameDay, startOfPeriod, endOfPeriod }
