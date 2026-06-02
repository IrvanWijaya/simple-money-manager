/// When a recurring rule stops generating occurrences.
///
/// - [forever]: never stops; occurrences are produced indefinitely.
/// - [count]: stops after a fixed number of total occurrences. The initial
///   (start-date) occurrence counts as occurrence 1, so a count of `N` yields
///   exactly `N` occurrences including the start.
/// - [endDate]: stops once the occurrence date would pass the inclusive end
///   date; the end date itself is eligible.
enum RecurringEndCondition { forever, count, endDate }
