// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

/// Binds HTTP requests to the operations of [VisibleController].
class VisibleControllerRouter {
  /// Creates a router calling a single [controller] instance.
  VisibleControllerRouter(
    VisibleController controller, {
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
  VisibleControllerRouter.perRequest(
    VisibleController Function(Request request) controllerFor, {
    this.middleware = const [],
    this.interceptors = const [],
    this.exceptionMapper = problemDetailsMapper,
  }) : _controllerFor = controllerFor;

  final VisibleController Function(Request request) _controllerFor;

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
    _shownRoute,
    _hiddenRoute,
    _oldRoute,
    _olderRoute,
  ];

  static const _shownRoute = RouteInfo(
    operationId: 'shown',
    method: 'GET',
    path: '/visible',
    controller: VisibleController,
    handler: 'shown',
    annotations: [Controller('/visible'), Get('/')],
    params: [],
  );

  static const _hiddenRoute = RouteInfo(
    operationId: 'hidden',
    method: 'GET',
    path: '/visible/hidden',
    controller: VisibleController,
    handler: 'hidden',
    annotations: [Controller('/visible'), Get('/hidden'), ApiHidden()],
    params: [],
  );

  static const _oldRoute = RouteInfo(
    operationId: 'old',
    method: 'GET',
    path: '/visible/old',
    controller: VisibleController,
    handler: 'old',
    annotations: [Controller('/visible'), Get('/old'), Deprecated('Use shown')],
    params: [],
  );

  static const _olderRoute = RouteInfo(
    operationId: 'older',
    method: 'GET',
    path: '/visible/older',
    controller: VisibleController,
    handler: 'older',
    annotations: [Controller('/visible'), Get('/older'), deprecated],
    params: [],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()
            ..add('GET', '/visible', _operation(_shownRoute, _shown))
            ..add('GET', '/visible/hidden', _operation(_hiddenRoute, _hidden))
            ..add('GET', '/visible/old', _operation(_oldRoute, _old))
            ..add('GET', '/visible/older', _operation(_olderRoute, _older)))
          .call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _shown(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _shownRoute,
      [],
      interceptors,
      () => $controller.shown(),
    );
    final $value = $result as String;
    return jsonResponse(200, $value);
  }

  Future<Response> _hidden(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _hiddenRoute,
      [],
      interceptors,
      () => $controller.hidden(),
    );
    final $value = $result as String;
    return jsonResponse(200, $value);
  }

  Future<Response> _old(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _oldRoute,
      [],
      interceptors,
      () => $controller.old(),
    );
    final $value = $result as String;
    return jsonResponse(200, $value);
  }

  Future<Response> _older(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _olderRoute,
      [],
      interceptors,
      () => $controller.older(),
    );
    final $value = $result as String;
    return jsonResponse(200, $value);
  }
}

/// Binds HTTP requests to the operations of [InternalController].
class InternalControllerRouter {
  /// Creates a router calling a single [controller] instance.
  InternalControllerRouter(
    InternalController controller, {
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
  InternalControllerRouter.perRequest(
    InternalController Function(Request request) controllerFor, {
    this.middleware = const [],
    this.interceptors = const [],
    this.exceptionMapper = problemDetailsMapper,
  }) : _controllerFor = controllerFor;

  final InternalController Function(Request request) _controllerFor;

  /// Middleware run after routing and before binding; the first is the
  /// outermost.
  final List<Middleware> middleware;

  /// Interceptors run around the controller method; the first is the
  /// outermost.
  final List<OperationInterceptor> interceptors;

  /// Converts exceptions to responses.
  final ExceptionMapper exceptionMapper;

  /// Metadata of all operations of the controller.
  static const routes = <RouteInfo>[_statusRoute];

  static const _statusRoute = RouteInfo(
    operationId: 'status',
    method: 'GET',
    path: '/internal',
    controller: InternalController,
    handler: 'status',
    annotations: [
      Controller('/internal', tag: 'Internal'),
      ApiHidden(),
      Get('/'),
    ],
    params: [],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()..add('GET', '/internal', _operation(_statusRoute, _status)))
          .call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _status(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _statusRoute,
      [],
      interceptors,
      () => $controller.status(),
    );
    final $value = $result as String;
    return jsonResponse(200, $value);
  }
}
