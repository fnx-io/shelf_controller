/// The request pipeline of a single operation in a generated router.
library;

import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'problem.dart';
import 'route_info.dart';

/// The media type of JSON responses.
const jsonContentType = 'application/json; charset=utf-8';

/// Wraps the call of a controller method after its arguments were bound.
///
/// Interceptors are the place for validation, auditing or timing. They see
/// the parsed arguments but cannot replace them. An interceptor may throw,
/// call [proceed] and transform its result, or skip it altogether.
///
/// ```dart
/// class Timing implements OperationInterceptor {
///   @override
///   Future<Object?> intercept(route, args, proceed) async {
///     final watch = Stopwatch()..start();
///     try {
///       return await proceed();
///     } finally {
///       print('${route.operationId}: ${watch.elapsed}');
///     }
///   }
/// }
/// ```
abstract interface class OperationInterceptor {
  /// Intercepts the call of the operation described by [route] with [args],
  /// which follow the order of the method parameters.
  Future<Object?> intercept(
    RouteInfo route,
    List<Object?> args,
    Future<Object?> Function() proceed,
  );
}

/// Runs [call] through [interceptors]; the first interceptor is the
/// outermost one.
Future<Object?> invokeOperation(
  RouteInfo route,
  List<Object?> args,
  List<OperationInterceptor> interceptors,
  FutureOr<Object?> Function() call,
) {
  final frozenArgs = List<Object?>.unmodifiable(args);
  Future<Object?> proceedFrom(int index) async {
    if (index == interceptors.length) return await call();
    return interceptors[index].intercept(
      route,
      frozenArgs,
      () => proceedFrom(index + 1),
    );
  }

  return proceedFrom(0);
}

/// Creates the handler of one operation.
///
/// The handler stores [route] in the request context, runs [middleware]
/// (the first one is the outermost) and then [handler]. Any exception is
/// converted by [exceptionMapper].
Handler operationHandler(
  RouteInfo route,
  Handler handler, {
  List<Middleware> middleware = const [],
  ExceptionMapper exceptionMapper = problemDetailsMapper,
}) {
  final pipeline = middleware.reversed.fold(
    handler,
    (inner, outer) => outer(inner),
  );
  return (request) async {
    final routed = request.change(context: {RouteInfo.contextKey: route});
    try {
      return await pipeline(routed);
    } on HijackException {
      rethrow;
    } catch (error, stackTrace) {
      return exceptionMapper(error, stackTrace, routed);
    }
  };
}

/// Creates a JSON response with [status] from a JSON-encodable [body].
Response jsonResponse(int status, Object? body) => Response(
  status,
  body: jsonEncode(body),
  headers: const {'content-type': jsonContentType},
);

/// Creates a response with [status] and no body.
Response emptyResponse(int status) => Response(status);
