/// Represents a range between two dates.
class DateTimeRange {
  /// The start date.
  final DateTime start;

  /// The end date.
  final DateTime end;

  /// Creates a new date range instance.
  const DateTimeRange({
    required this.start,
    required this.end,
  });

  /// Constructor to initialize a date range with one day separating the [start] from the [end].
  DateTimeRange.oneDay(DateTime start)
    : this(
        start: start,
        end: start.add(const Duration(days: 1)),
      );

  /// Function to calculate the intersection of two date ranges.
  /// Returns a new DateRange if they overlap, otherwise returns null.
  static DateTimeRange? intersection(DateTimeRange range1, DateTimeRange range2) {
    // Determine the latest start date
    DateTime start = range1.start.isAfter(range2.start) ? range1.start : range2.start;

    // Determine the earliest end date
    DateTime end = range1.end.isBefore(range2.end) ? range1.end : range2.end;

    // If the calculated start date is after the end date, there is no intersection
    if (start.isAfter(end)) {
      return null; // No intersection
    }

    return DateTimeRange(
      start: start,
      end: end,
    );
  }

  /// Function to calculate the union of two date ranges.
  /// If the ranges overlap or touch, returns a merged DateRange.
  /// Otherwise, returns null as they are disjoint.
  static DateTimeRange? union(DateTimeRange range1, DateTimeRange range2) {
    // If there is no intersection and the ranges are not contiguous, return null
    if (range1.end.isBefore(range2.start.subtract(const Duration(days: 1))) || range2.end.isBefore(range1.start.subtract(const Duration(days: 1)))) {
      return null;
    }

    // Determine the earliest start date
    DateTime start = range1.start.isBefore(range2.start) ? range1.start : range2.start;

    // Determine the latest end date
    DateTime end = range1.end.isAfter(range2.end) ? range1.end : range2.end;

    return DateTimeRange(
      start: start,
      end: end,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! DateTimeRange) {
      return super == other;
    }
    return start == other.start && end == other.end;
  }

  @override
  int get hashCode => Object.hash(start, end);
}
