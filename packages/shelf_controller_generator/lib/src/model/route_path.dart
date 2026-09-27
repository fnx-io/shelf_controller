/// A path parameter declared in a route, such as `<id>` or `<id|[0-9]+>`.
class RouteParam {
  final String name;

  /// The regular expression restricting the segment, if any.
  final String? pattern;

  const RouteParam(this.name, this.pattern);
}

/// The full path of an operation.
class RoutePath {
  // The same syntax shelf_router accepts.
  static final _paramPattern = RegExp(r'<([^>|]+)(?:\|([^>]*))?>');

  /// The path in `shelf_router` syntax, for example `/api/projects/<id>`.
  final String shelfPath;

  const RoutePath(this.shelfPath);

  /// Joins the controller prefix with the operation path.
  ///
  /// Duplicate and trailing slashes are removed, so `@Controller('/api/x')`
  /// with `@Get('/')` maps to `/api/x`.
  factory RoutePath.join(String controllerPath, String operationPath) {
    final segments = '$controllerPath/$operationPath'
        .split('/')
        .where((segment) => segment.isNotEmpty);
    return RoutePath('/${segments.join('/')}');
  }

  /// Path parameters in the order they appear.
  List<RouteParam> get params => [
    for (final match in _paramPattern.allMatches(shelfPath))
      RouteParam(match[1]!, match[2]),
  ];

  /// The path in OpenAPI syntax, for example `/api/projects/{id}`.
  String get openApiPath =>
      shelfPath.replaceAllMapped(_paramPattern, (match) => '{${match[1]}}');
}
