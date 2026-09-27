// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

/// Binds HTTP requests to the operations of [ResponsesController].
class ResponsesControllerRouter {
  /// Creates a router calling a single [controller] instance.
  ResponsesControllerRouter(
    ResponsesController controller, {
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
  ResponsesControllerRouter.perRequest(
    ResponsesController Function(Request request) controllerFor, {
    this.middleware = const [],
    this.interceptors = const [],
    this.exceptionMapper = problemDetailsMapper,
  }) : _controllerFor = controllerFor;

  final ResponsesController Function(Request request) _controllerFor;

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
    _removeRoute,
    _acceptRoute,
    _typedErrorRoute,
    _fileRoute,
    _redirectRoute,
    _countRoute,
  ];

  static const _removeRoute = RouteInfo(
    operationId: 'remove',
    method: 'DELETE',
    path: '/responses',
    controller: ResponsesController,
    handler: 'remove',
    annotations: [
      Controller('/responses'),
      ApiResponse(401),
      ApiResponse(503, description: 'Maintenance'),
      Delete('/'),
    ],
    params: [],
  );

  static const _acceptRoute = RouteInfo(
    operationId: 'accept',
    method: 'POST',
    path: '/responses/accept',
    controller: ResponsesController,
    handler: 'accept',
    annotations: [
      Controller('/responses'),
      ApiResponse(401),
      ApiResponse(503, description: 'Maintenance'),
      Post('/accept'),
      Status(202),
    ],
    params: [],
  );

  static const _typedErrorRoute = RouteInfo(
    operationId: 'typedError',
    method: 'GET',
    path: '/responses/typed-error',
    controller: ResponsesController,
    handler: 'typedError',
    annotations: [
      Controller('/responses'),
      ApiResponse(401),
      ApiResponse(503, description: 'Maintenance'),
      Get('/typed-error'),
      ApiResponse(503, type: ErrorDto, description: 'Down for maintenance'),
      ApiResponse(422, type: List<ErrorDto>),
    ],
    params: [],
  );

  static const _fileRoute = RouteInfo(
    operationId: 'file',
    method: 'GET',
    path: '/responses/file',
    controller: ResponsesController,
    handler: 'file',
    annotations: [
      Controller('/responses'),
      ApiResponse(401),
      ApiResponse(503, description: 'Maintenance'),
      Get('/file'),
      ApiResponse(
        200,
        type: String,
        contentType: 'text/plain',
        description: 'The file',
      ),
    ],
    params: [],
  );

  static const _redirectRoute = RouteInfo(
    operationId: 'redirect',
    method: 'GET',
    path: '/responses/raw',
    controller: ResponsesController,
    handler: 'redirect',
    annotations: [
      Controller('/responses'),
      ApiResponse(401),
      ApiResponse(503, description: 'Maintenance'),
      Get('/raw'),
      Status(302),
    ],
    params: [],
  );

  static const _countRoute = RouteInfo(
    operationId: 'count',
    method: 'GET',
    path: '/responses/future-or',
    controller: ResponsesController,
    handler: 'count',
    annotations: [
      Controller('/responses'),
      ApiResponse(401),
      ApiResponse(503, description: 'Maintenance'),
      Get('/future-or'),
    ],
    params: [],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()
            ..add('DELETE', '/responses', _operation(_removeRoute, _remove))
            ..add(
              'POST',
              '/responses/accept',
              _operation(_acceptRoute, _accept),
            )
            ..add(
              'GET',
              '/responses/typed-error',
              _operation(_typedErrorRoute, _typedError),
            )
            ..add('GET', '/responses/file', _operation(_fileRoute, _file))
            ..add(
              'GET',
              '/responses/raw',
              _operation(_redirectRoute, _redirect),
            )
            ..add(
              'GET',
              '/responses/future-or',
              _operation(_countRoute, _count),
            ))
          .call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _remove(Request $request) async {
    final $controller = _controllerFor($request);

    await invokeOperation(
      _removeRoute,
      [],
      interceptors,
      () => $controller.remove(),
    );
    return emptyResponse(204);
  }

  Future<Response> _accept(Request $request) async {
    final $controller = _controllerFor($request);

    await invokeOperation(
      _acceptRoute,
      [],
      interceptors,
      () => $controller.accept(),
    );
    return emptyResponse(202);
  }

  Future<Response> _typedError(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _typedErrorRoute,
      [],
      interceptors,
      () => $controller.typedError(),
    );
    final $value = $result as String;
    return jsonResponse(200, $value);
  }

  Future<Response> _file(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _fileRoute,
      [],
      interceptors,
      () => $controller.file(),
    );
    return $result as Response;
  }

  Future<Response> _redirect(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _redirectRoute,
      [],
      interceptors,
      () => $controller.redirect(),
    );
    return $result as Response;
  }

  Future<Response> _count(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _countRoute,
      [],
      interceptors,
      () => $controller.count(),
    );
    final $value = $result as int;
    return jsonResponse(200, $value);
  }
}
