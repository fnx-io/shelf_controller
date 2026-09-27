import 'package:shelf/shelf.dart';

/// Where the value of a method parameter comes from.
enum ParamSource {
  /// A segment of the request path.
  path,

  /// A query parameter.
  query,

  /// A request header.
  header,

  /// The JSON request body.
  body,

  /// The shelf [Request] itself.
  request,
}

/// Metadata of a single parameter of a controller method.
class ParamInfo {
  /// The name of the Dart parameter.
  final String name;

  /// The name of the parameter in the request, for example the query
  /// parameter or header name; `null` for [ParamSource.body] and
  /// [ParamSource.request].
  final String? key;

  /// Where the value comes from.
  final ParamSource source;

  /// The declared Dart type, for example `int?` or `List<String>`.
  final String type;

  /// All annotations of the parameter.
  final List<Object> annotations;

  /// Creates parameter metadata.
  const ParamInfo({
    required this.name,
    required this.source,
    required this.type,
    this.key,
    this.annotations = const [],
  });

  /// Returns the annotations of type [T].
  Iterable<T> annotationsOf<T>() => annotations.whereType<T>();
}

/// Metadata of a single controller operation.
///
/// The generated router puts it into the request context before the route
/// middleware runs, so middleware and interceptors can read the annotations
/// of the operation, including ones defined by the application:
///
/// ```dart
/// final roles = RouteInfo.of(request)!
///     .annotationsOf<Secured>()
///     .expand((s) => s.roles);
/// ```
class RouteInfo {
  /// The key of the route info in [Request.context].
  static const contextKey = 'shelf_controller/route';

  /// The OpenAPI `operationId`.
  final String operationId;

  /// The HTTP method, for example `GET`.
  final String method;

  /// The full path in `shelf_router` syntax, for example
  /// `/api/projects/<id>`.
  final String path;

  /// The controller class.
  final Type controller;

  /// The name of the controller method.
  final String handler;

  /// Annotations of the controller class followed by annotations of the
  /// method.
  final List<Object> annotations;

  /// Parameters of the method in declaration order.
  final List<ParamInfo> params;

  /// Creates route metadata.
  const RouteInfo({
    required this.operationId,
    required this.method,
    required this.path,
    required this.controller,
    required this.handler,
    this.annotations = const [],
    this.params = const [],
  });

  /// Returns the route info of the operation handling [request], or `null`
  /// outside of a generated router.
  static RouteInfo? of(Request request) =>
      request.context[contextKey] as RouteInfo?;

  /// Returns the annotations of type [T].
  Iterable<T> annotationsOf<T>() => annotations.whereType<T>();

  @override
  String toString() => 'RouteInfo($method $path -> $controller.$handler)';
}
