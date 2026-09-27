// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

/// Binds HTTP requests to the operations of [RulesController].
class RulesControllerRouter {
  /// Creates a router calling a single [controller] instance.
  RulesControllerRouter(
    RulesController controller, {
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
  RulesControllerRouter.perRequest(
    RulesController Function(Request request) controllerFor, {
    this.middleware = const [],
    this.interceptors = const [],
    this.exceptionMapper = problemDetailsMapper,
  }) : _controllerFor = controllerFor;

  final RulesController Function(Request request) _controllerFor;

  /// Middleware run after routing and before binding; the first is the
  /// outermost.
  final List<Middleware> middleware;

  /// Interceptors run around the controller method; the first is the
  /// outermost.
  final List<OperationInterceptor> interceptors;

  /// Converts exceptions to responses.
  final ExceptionMapper exceptionMapper;

  /// Metadata of all operations of the controller.
  static const routes = <RouteInfo>[_createRoute];

  static const _createRoute = RouteInfo(
    operationId: 'create',
    method: 'POST',
    path: '/rules',
    controller: RulesController,
    handler: 'create',
    annotations: [Controller('/rules'), Post('/')],
    params: [
      ParamInfo(
        name: 'body',
        source: ParamSource.body,
        type: 'RulesDto',
        annotations: [Body()],
      ),
    ],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()..add('POST', '/rules', _operation(_createRoute, _create))).call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _create(Request $request) async {
    final $controller = _controllerFor($request);
    final body = await requireBody(
      $request,
      'body',
      ($json) => RulesDto.fromJson($json as Map<String, dynamic>),
    );
    final $result = await invokeOperation(
      _createRoute,
      [body],
      interceptors,
      () => $controller.create(body),
    );
    final $value = $result as ResponseOnlyDto;
    return jsonResponse(200, $value.toJson());
  }
}
