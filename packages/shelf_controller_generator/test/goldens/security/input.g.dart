// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

/// Binds HTTP requests to the operations of [GlobalController].
class GlobalControllerRouter {
  /// Creates a router calling a single [controller] instance.
  GlobalControllerRouter(
    GlobalController controller, {
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
  GlobalControllerRouter.perRequest(
    GlobalController Function(Request request) controllerFor, {
    this.middleware = const [],
    this.interceptors = const [],
    this.exceptionMapper = problemDetailsMapper,
  }) : _controllerFor = controllerFor;

  final GlobalController Function(Request request) _controllerFor;

  /// Middleware run after routing and before binding; the first is the
  /// outermost.
  final List<Middleware> middleware;

  /// Interceptors run around the controller method; the first is the
  /// outermost.
  final List<OperationInterceptor> interceptors;

  /// Converts exceptions to responses.
  final ExceptionMapper exceptionMapper;

  /// Metadata of all operations of the controller.
  static const routes = <RouteInfo>[
    _inheritedRoute,
    _publicRoute,
    _optionalRoute,
  ];

  static const _inheritedRoute = RouteInfo(
    operationId: 'inherited',
    method: 'GET',
    path: '/global',
    controller: GlobalController,
    handler: 'inherited',
    annotations: [Controller('/global'), Get('/')],
    params: [],
  );

  static const _publicRoute = RouteInfo(
    operationId: 'public',
    method: 'GET',
    path: '/global/public',
    controller: GlobalController,
    handler: 'public',
    annotations: [Controller('/global'), Get('/public'), ApiSecurity.none()],
    params: [],
  );

  static const _optionalRoute = RouteInfo(
    operationId: 'optional',
    method: 'GET',
    path: '/global/optional',
    controller: GlobalController,
    handler: 'optional',
    annotations: [
      Controller('/global'),
      Get('/optional'),
      ApiSecurity.none(),
      ApiSecurity('bearer'),
    ],
    params: [],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()
            ..add('GET', '/global', _operation(_inheritedRoute, _inherited))
            ..add('GET', '/global/public', _operation(_publicRoute, _public))
            ..add(
              'GET',
              '/global/optional',
              _operation(_optionalRoute, _optional),
            ))
          .call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _inherited(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _inheritedRoute,
      [],
      interceptors,
      () => $controller.inherited(),
    );
    final $value = $result as String;
    return jsonResponse(200, $value);
  }

  Future<Response> _public(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _publicRoute,
      [],
      interceptors,
      () => $controller.public(),
    );
    final $value = $result as String;
    return jsonResponse(200, $value);
  }

  Future<Response> _optional(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _optionalRoute,
      [],
      interceptors,
      () => $controller.optional(),
    );
    final $value = $result as String;
    return jsonResponse(200, $value);
  }
}

/// Binds HTTP requests to the operations of [OAuthController].
class OAuthControllerRouter {
  /// Creates a router calling a single [controller] instance.
  OAuthControllerRouter(
    OAuthController controller, {
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
  OAuthControllerRouter.perRequest(
    OAuthController Function(Request request) controllerFor, {
    this.middleware = const [],
    this.interceptors = const [],
    this.exceptionMapper = problemDetailsMapper,
  }) : _controllerFor = controllerFor;

  final OAuthController Function(Request request) _controllerFor;

  /// Middleware run after routing and before binding; the first is the
  /// outermost.
  final List<Middleware> middleware;

  /// Interceptors run around the controller method; the first is the
  /// outermost.
  final List<OperationInterceptor> interceptors;

  /// Converts exceptions to responses.
  final ExceptionMapper exceptionMapper;

  /// Metadata of all operations of the controller.
  static const routes = <RouteInfo>[_readRoute, _writeRoute];

  static const _readRoute = RouteInfo(
    operationId: 'read',
    method: 'GET',
    path: '/oauth',
    controller: OAuthController,
    handler: 'read',
    annotations: [
      Controller('/oauth'),
      ApiSecurity('oauth', scopes: ['read']),
      Get('/'),
    ],
    params: [],
  );

  static const _writeRoute = RouteInfo(
    operationId: 'write',
    method: 'POST',
    path: '/oauth',
    controller: OAuthController,
    handler: 'write',
    annotations: [
      Controller('/oauth'),
      ApiSecurity('oauth', scopes: ['read']),
      Post('/'),
      ApiSecurity('oauth', scopes: ['read', 'write']),
      ApiSecurity('bearer'),
    ],
    params: [],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()
            ..add('GET', '/oauth', _operation(_readRoute, _read))
            ..add('POST', '/oauth', _operation(_writeRoute, _write)))
          .call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _read(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _readRoute,
      [],
      interceptors,
      () => $controller.read(),
    );
    final $value = $result as String;
    return jsonResponse(200, $value);
  }

  Future<Response> _write(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _writeRoute,
      [],
      interceptors,
      () => $controller.write(),
    );
    final $value = $result as String;
    return jsonResponse(200, $value);
  }
}
