import 'package:http/http.dart';

/// Represents an authentication result result.
enum RequestResultState {
  /// Login success.
  success('success', 200),

  /// Calendar not found.
  notFound('not_found', 404),

  /// Unauthorized.
  unauthorized('unauthorized', 401),

  /// Generic error (no connection, catch error, ...).
  genericError('generic_error', null);

  /// The response id.
  final String id;

  /// The http response code.
  final int? httpCode;

  /// Creates a new login result.
  const RequestResultState(this.id, this.httpCode);

  /// Returns the login result associated to the specified response.
  static RequestResultState fromResponse(Response? response) {
    for (RequestResultState loginResult in RequestResultState.values) {
      if (loginResult.httpCode == response?.statusCode) {
        return loginResult;
      }
    }
    return RequestResultState.genericError;
  }
}