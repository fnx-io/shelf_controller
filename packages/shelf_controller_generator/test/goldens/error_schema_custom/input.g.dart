// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

/// Binds HTTP requests to the operations of [ErrorsController].
class ErrorsControllerRouter {
  /// Creates a router calling a single [controller] instance.
  ErrorsControllerRouter(
    ErrorsController controller, {
    List<Middleware> middleware = const [],
    List<OperationInterceptor> interceptors = const [],
    ExceptionMapper exceptionMapper = problemDetailsMapper,
  }) : this.perRequest(
         (_) => controller,
         middleware: middleware,
         interceptors: interceptors,
         exceptionMapper: exceptionMapper,
       );

  /// Creates a router obtaining a controller for every request from
  /// [controllerFor], called after [middleware] and before binding.
  ErrorsControllerRouter.perRequest(
    ErrorsController Function(Request request) controllerFor, {
    this.middleware = const [],
    this.interceptors = const [],
    this.exceptionMapper = problemDetailsMapper,
  }) : _controllerFor = controllerFor;

  final ErrorsController Function(Request request) _controllerFor;

  /// Middleware run after routing and before binding; the first is the
  /// outermost.
  final List<Middleware> middleware;

  /// Interceptors run around the controller method; the first is the
  /// outermost.
  final List<OperationInterceptor> interceptors;

  /// Converts exceptions to responses.
  final ExceptionMapper exceptionMapper;

  /// Metadata of all operations of the controller.
  static const routes = <RouteInfo>[_findRoute];

  static const _findRoute = RouteInfo(
    operationId: 'find',
    method: 'GET',
    path: '/errors/<id>',
    controller: ErrorsController,
    handler: 'find',
    annotations: [Controller('/errors'), Get('/<id>'), ApiResponse(404)],
    params: [
      ParamInfo(
        name: 'id',
        source: ParamSource.path,
        type: 'String',
        key: 'id',
        annotations: [Path()],
      ),
    ],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()..add('GET', '/errors/<id>', _operation(_findRoute, _find)))
          .call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _find(Request $request) async {
    final $controller = _controllerFor($request);
    final id = requireParam(
      $request,
      ParamSource.path,
      'id',
      ParamParser.string,
    );
    final $result = await invokeOperation(
      _findRoute,
      [id],
      interceptors,
      () => $controller.find(id),
    );
    final $value = $result as String;
    return jsonResponse(200, $value);
  }
}
