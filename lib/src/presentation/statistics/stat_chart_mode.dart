/// The two supported Statistic chart visualizations.
///
/// Only donut and bar are in scope. The chart-type action cycles strictly
/// between these two modes (VAL-STAT-003).
enum StatChartMode {
  donut,
  bar;

  /// The other mode, used by the header toggle to cycle between exactly the two
  /// supported visualizations.
  StatChartMode get toggled =>
      this == StatChartMode.donut ? StatChartMode.bar : StatChartMode.donut;
}
