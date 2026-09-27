// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_controller.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

/// Binds HTTP requests to the operations of [MeController].
class MeControllerRouter {
  /// Creates a router calling a single [controller] instance.
  MeControllerRouter(
    MeController controller, {
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
  MeControllerRouter.perRequest(
    MeController Function(Request request) controllerFor, {
    this.middleware = const [],
    this.interceptors = const [],
    this.exceptionMapper = problemDetailsMapper,
  }) : _controllerFor = controllerFor;

  final MeController Function(Request request) _controllerFor;

  /// Middleware run after routing and before binding; the first is the
  /// outermost.
  final List<Middleware> middleware;

  /// Interceptors run around the controller method; the first is the
  /// outermost.
  final List<OperationInterceptor> interceptors;

  /// Converts exceptions to responses.
  final ExceptionMapper exceptionMapper;

  /// Metadata of all operations of the controller.
  static const routes = <RouteInfo>[_whoAmIRoute, _pingRoute, _debugRoute];

  static const _whoAmIRoute = RouteInfo(
    operationId: 'whoAmI',
    method: 'GET',
    path: '/api/v1/me',
    controller: MeController,
    handler: 'whoAmI',
    annotations: [
      Controller('/api/v1/me', tag: 'Me'),
      Get('/'),
    ],
    params: [],
  );

  static const _pingRoute = RouteInfo(
    operationId: 'ping',
    method: 'GET',
    path: '/api/v1/me/ping',
    controller: MeController,
    handler: 'ping',
    annotations: [
      Controller('/api/v1/me', tag: 'Me'),
      Get('/ping'),
      ApiSecurity.none(),
    ],
    params: [],
  );

  static const _debugRoute = RouteInfo(
    operationId: 'debug',
    method: 'GET',
    path: '/api/v1/me/debug',
    controller: MeController,
    handler: 'debug',
    annotations: [
      Controller('/api/v1/me', tag: 'Me'),
      Get('/debug'),
      ApiHidden(),
    ],
    params: [
      ParamInfo(
        name: 'request',
        source: ParamSource.request,
        type: 'Request',
        annotations: [],
      ),
    ],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()
            ..add('GET', '/api/v1/me', _operation(_whoAmIRoute, _whoAmI))
            ..add('GET', '/api/v1/me/ping', _operation(_pingRoute, _ping))
            ..add('GET', '/api/v1/me/debug', _operation(_debugRoute, _debug)))
          .call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _whoAmI(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _whoAmIRoute,
      [],
      interceptors,
      () => $controller.whoAmI(),
    );
    final $value = $result as UserDto;
    return jsonResponse(200, $value.toJson());
  }

  Future<Response> _ping(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _pingRoute,
      [],
      interceptors,
      () => $controller.ping(),
    );
    final $value = $result as Map<String, String>;
    return jsonResponse(200, $value);
  }

  Future<Response> _debug(Request $request) async {
    final $controller = _controllerFor($request);
    final request = $request;
    final $result = await invokeOperation(
      _debugRoute,
      [request],
      interceptors,
      () => $controller.debug(request),
    );
    final $value = $result as Map<String, Object?>;
    return jsonResponse(200, $value);
  }
}
