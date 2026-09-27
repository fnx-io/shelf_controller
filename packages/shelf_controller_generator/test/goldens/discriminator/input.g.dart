// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

/// Binds HTTP requests to the operations of [ShapesController].
class ShapesControllerRouter {
  /// Creates a router calling a single [controller] instance.
  ShapesControllerRouter(
    ShapesController controller, {
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
  ShapesControllerRouter.perRequest(
    ShapesController Function(Request request) controllerFor, {
    this.middleware = const [],
    this.interceptors = const [],
    this.exceptionMapper = problemDetailsMapper,
  }) : _controllerFor = controllerFor;

  final ShapesController Function(Request request) _controllerFor;

  /// Middleware run after routing and before binding; the first is the
  /// outermost.
  final List<Middleware> middleware;

  /// Interceptors run around the controller method; the first is the
  /// outermost.
  final List<OperationInterceptor> interceptors;

  /// Converts exceptions to responses.
  final ExceptionMapper exceptionMapper;

  /// Metadata of all operations of the controller.
  static const routes = <RouteInfo>[_addRoute];

  static const _addRoute = RouteInfo(
    operationId: 'add',
    method: 'POST',
    path: '/shapes',
    controller: ShapesController,
    handler: 'add',
    annotations: [Controller('/shapes'), Post('/')],
    params: [
      ParamInfo(
        name: 'shape',
        source: ParamSource.body,
        type: 'Shape',
        annotations: [Body()],
      ),
    ],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()..add('POST', '/shapes', _operation(_addRoute, _add))).call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _add(Request $request) async {
    final $controller = _controllerFor($request);
    final shape = await requireBody(
      $request,
      'shape',
      ($json) => Shape.fromJson($json as Map<String, dynamic>),
    );
    final $result = await invokeOperation(
      _addRoute,
      [shape],
      interceptors,
      () => $controller.add(shape),
    );
    final $value = $result as List<Shape>;
    return jsonResponse(200, $value.map(($v1) => $v1.toJson()).toList());
  }
}
