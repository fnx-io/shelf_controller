import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

import 'route_info.dart';

/// Converts an exception thrown while handling a request into a response.
///
/// It receives exceptions from route middleware, binding, interceptors and
/// the controller method.
typedef ExceptionMapper =
    FutureOr<Response> Function(
      Object error,
      StackTrace stackTrace,
      Request request,
    );

/// The media type of RFC 9457 Problem Details.
const problemJsonContentType = 'application/problem+json';

final _log = Logger('shelf_controller');

/// An exception that maps to an HTTP error response.
///
/// Throw it directly or extend it with application specific exceptions;
/// [problemDetailsMapper] turns it into an RFC 9457 response.
///
/// ```dart
/// class ProjectNotFound extends HttpProblem {
///   ProjectNotFound(String id)
///     : super(404, detail: 'Project $id does not exist');
/// }
/// ```
class HttpProblem implements Exception {
  /// The HTTP status code.
  final int status;

  /// A short summary of the problem type; defaults to the reason phrase of
  /// [status].
  final String? title;

  /// An explanation specific to this occurrence of the problem.
  final String? detail;

  /// A URI identifying the problem type.
  final Uri? type;

  /// Creates a problem with the given [status].
  HttpProblem(this.status, {this.title, this.detail, this.type});

  /// Returns the Problem Details JSON object of this problem.
  Map<String, Object> toProblemDetails() => {
    'type': type?.toString() ?? 'about:blank',
    'title': title ?? reasonPhrase(status),
    'status': status,
    'detail': ?detail,
  };

  @override
  String toString() =>
      'HttpProblem($status${detail == null ? '' : ': $detail'})';
}

/// Thrown by the generated router when a request value cannot be bound to a
/// method parameter.
///
/// It maps to `400 Bad Request`.
class BindingException extends HttpProblem {
  /// Where the value was expected.
  final ParamSource source;

  /// The name of the parameter in the request.
  final String parameter;

  /// Why the binding failed.
  final String reason;

  /// Creates a binding failure of [parameter] from [source].
  BindingException(this.source, this.parameter, this.reason)
    : super(400, detail: _describe(source, parameter, reason));

  static String _describe(
    ParamSource source,
    String parameter,
    String reason,
  ) => switch (source) {
    ParamSource.body => 'Invalid request body: $reason',
    _ => "Invalid ${source.name} parameter '$parameter': $reason",
  };

  @override
  String toString() => 'BindingException: $detail';
}

/// The default [ExceptionMapper] producing RFC 9457 Problem Details.
///
/// - [HttpProblem], including [BindingException], responds with its status.
/// - Any other exception responds with `500` without exposing details; the
///   exception is logged to the `shelf_controller` logger.
///
/// Custom mappers can delegate the exceptions they do not handle to it.
Response problemDetailsMapper(
  Object error,
  StackTrace stackTrace,
  Request request,
) {
  if (error is HttpProblem) return problemResponse(error);
  final route = RouteInfo.of(request);
  _log.severe(
    'Unhandled exception in ${route?.operationId ?? request.url}',
    error,
    stackTrace,
  );
  return problemResponse(HttpProblem(500));
}

/// Creates an `application/problem+json` response from [problem].
Response problemResponse(HttpProblem problem) => Response(
  problem.status,
  body: jsonEncode(problem.toProblemDetails()),
  headers: const {'content-type': '$problemJsonContentType; charset=utf-8'},
);

/// Returns the standard reason phrase of an HTTP [status] code.
String reasonPhrase(int status) => _reasonPhrases[status] ?? 'HTTP $status';

const _reasonPhrases = {
  200: 'OK',
  201: 'Created',
  202: 'Accepted',
  204: 'No Content',
  301: 'Moved Permanently',
  302: 'Found',
  304: 'Not Modified',
  400: 'Bad Request',
  401: 'Unauthorized',
  403: 'Forbidden',
  404: 'Not Found',
  405: 'Method Not Allowed',
  406: 'Not Acceptable',
  409: 'Conflict',
  410: 'Gone',
  412: 'Precondition Failed',
  413: 'Content Too Large',
  415: 'Unsupported Media Type',
  422: 'Unprocessable Content',
  429: 'Too Many Requests',
  500: 'Internal Server Error',
  501: 'Not Implemented',
  502: 'Bad Gateway',
  503: 'Service Unavailable',
  504: 'Gateway Timeout',
};
