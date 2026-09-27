// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

/// Binds HTTP requests to the operations of [UsersController].
class UsersControllerRouter {
  /// Creates a router calling a single [controller] instance.
  UsersControllerRouter(
    UsersController controller, {
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
  UsersControllerRouter.perRequest(
    UsersController Function(Request request) controllerFor, {
    this.middleware = const [],
    this.interceptors = const [],
    this.exceptionMapper = problemDetailsMapper,
  }) : _controllerFor = controllerFor;

  final UsersController Function(Request request) _controllerFor;

  /// Middleware run after routing and before binding; the first is the
  /// outermost.
  final List<Middleware> middleware;

  /// Interceptors run around the controller method; the first is the
  /// outermost.
  final List<OperationInterceptor> interceptors;

  /// Converts exceptions to responses.
  final ExceptionMapper exceptionMapper;

  /// Metadata of all operations of the controller.
  static const routes = <RouteInfo>[_listRoute, _detailRoute];

  static const _listRoute = RouteInfo(
    operationId: 'list',
    method: 'GET',
    path: '/api/v2/users',
    controller: UsersController,
    handler: 'list',
    annotations: [
      Controller('/api/v2/users', tag: 'Users'),
      Get('/'),
    ],
    params: [],
  );

  static const _detailRoute = RouteInfo(
    operationId: 'getUser',
    method: 'GET',
    path: '/api/v2/users/<id>',
    controller: UsersController,
    handler: 'detail',
    annotations: [
      Controller('/api/v2/users', tag: 'Users'),
      Get('/<id>', operationId: 'getUser'),
    ],
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
      (Router()
            ..add('GET', '/api/v2/users', _operation(_listRoute, _list))
            ..add(
              'GET',
              '/api/v2/users/<id>',
              _operation(_detailRoute, _detail),
            ))
          .call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _list(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _listRoute,
      [],
      interceptors,
      () => $controller.list(),
    );
    final $value = $result as List<String>;
    return jsonResponse(200, $value);
  }

  Future<Response> _detail(Request $request) async {
    final $controller = _controllerFor($request);
    final id = requireParam(
      $request,
      ParamSource.path,
      'id',
      ParamParser.string,
    );
    final $result = await invokeOperation(
      _detailRoute,
      [id],
      interceptors,
      () => $controller.detail(id),
    );
    final $value = $result as String;
    return jsonResponse(200, $value);
  }
}

/// Binds HTTP requests to the operations of [LegacyUsersController].
class LegacyUsersControllerRouter {
  /// Creates a router calling a single [controller] instance.
  LegacyUsersControllerRouter(
    LegacyUsersController controller, {
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
  LegacyUsersControllerRouter.perRequest(
    LegacyUsersController Function(Request request) controllerFor, {
    this.middleware = const [],
    this.interceptors = const [],
    this.exceptionMapper = problemDetailsMapper,
  }) : _controllerFor = controllerFor;

  final LegacyUsersController Function(Request request) _controllerFor;

  /// Middleware run after routing and before binding; the first is the
  /// outermost.
  final List<Middleware> middleware;

  /// Interceptors run around the controller method; the first is the
  /// outermost.
  final List<OperationInterceptor> interceptors;

  /// Converts exceptions to responses.
  final ExceptionMapper exceptionMapper;

  /// Metadata of all operations of the controller.
  static const routes = <RouteInfo>[_listRoute];

  static const _listRoute = RouteInfo(
    operationId: 'listUsersV1',
    method: 'GET',
    path: '/api/v1/users',
    controller: LegacyUsersController,
    handler: 'list',
    annotations: [
      Controller('/api/v1/users', tag: 'Users'),
      Get('/', operationId: 'listUsersV1'),
    ],
    params: [],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()..add('GET', '/api/v1/users', _operation(_listRoute, _list)))
          .call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _list(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _listRoute,
      [],
      interceptors,
      () => $controller.list(),
    );
    final $value = $result as List<String>;
    return jsonResponse(200, $value);
  }
}

/// Binds HTTP requests to the operations of [RootController].
class RootControllerRouter {
  /// Creates a router calling a single [controller] instance.
  RootControllerRouter(
    RootController controller, {
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
  RootControllerRouter.perRequest(
    RootController Function(Request request) controllerFor, {
    this.middleware = const [],
    this.interceptors = const [],
    this.exceptionMapper = problemDetailsMapper,
  }) : _controllerFor = controllerFor;

  final RootController Function(Request request) _controllerFor;

  /// Middleware run after routing and before binding; the first is the
  /// outermost.
  final List<Middleware> middleware;

  /// Interceptors run around the controller method; the first is the
  /// outermost.
  final List<OperationInterceptor> interceptors;

  /// Converts exceptions to responses.
  final ExceptionMapper exceptionMapper;

  /// Metadata of all operations of the controller.
  static const routes = <RouteInfo>[_healthRoute, _replaceRoute];

  static const _healthRoute = RouteInfo(
    operationId: 'health',
    method: 'GET',
    path: '/health',
    controller: RootController,
    handler: 'health',
    annotations: [Controller('/'), Get('/health')],
    params: [],
  );

  static const _replaceRoute = RouteInfo(
    operationId: 'replace',
    method: 'PUT',
    path: '/api/v2/users/<id>',
    controller: RootController,
    handler: 'replace',
    annotations: [Controller('/'), Put('/api/v2/users/<id>')],
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
      (Router()
            ..add('GET', '/health', _operation(_healthRoute, _health))
            ..add(
              'PUT',
              '/api/v2/users/<id>',
              _operation(_replaceRoute, _replace),
            ))
          .call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _health(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _healthRoute,
      [],
      interceptors,
      () => $controller.health(),
    );
    final $value = $result as String;
    return jsonResponse(200, $value);
  }

  Future<Response> _replace(Request $request) async {
    final $controller = _controllerFor($request);
    final id = requireParam(
      $request,
      ParamSource.path,
      'id',
      ParamParser.string,
    );
    await invokeOperation(
      _replaceRoute,
      [id],
      interceptors,
      () => $controller.replace(id),
    );
    return emptyResponse(204);
  }
}
