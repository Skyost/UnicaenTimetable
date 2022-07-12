import 'package:unicaen_timetable/model/lessons/authentication/state.dart';

/// Represents an authentication result.
class RequestResult<T> {
  /// Whether the result is a success.
  final RequestResultState state;

  /// The returned object.
  final T object;

  /// Creates a new authentication result instance.
  const RequestResult({
    required this.state,
    required this.object,
  });
}
