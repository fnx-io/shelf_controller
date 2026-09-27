// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

/// Binds HTTP requests to the operations of [TypeController].
class TypeControllerRouter {
  /// Creates a router calling a single [controller] instance.
  TypeControllerRouter(
    TypeController controller, {
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
  TypeControllerRouter.perRequest(
    TypeController Function(Request request) controllerFor, {
    this.middleware = const [],
    this.interceptors = const [],
    this.exceptionMapper = problemDetailsMapper,
  }) : _controllerFor = controllerFor;

  final TypeController Function(Request request) _controllerFor;

  /// Middleware run after routing and before binding; the first is the
  /// outermost.
  final List<Middleware> middleware;

  /// Interceptors run around the controller method; the first is the
  /// outermost.
  final List<OperationInterceptor> interceptors;

  /// Converts exceptions to responses.
  final ExceptionMapper exceptionMapper;

  /// Metadata of all operations of the controller.
  static const routes = <RouteInfo>[_echoRoute, _childrenRoute, _dtoRoute];

  static const _echoRoute = RouteInfo(
    operationId: 'echo',
    method: 'POST',
    path: '/type-nullable',
    controller: TypeController,
    handler: 'echo',
    annotations: [Controller('/type-nullable'), Post('/')],
    params: [
      ParamInfo(
        name: 'body',
        source: ParamSource.body,
        type: 'Dto?',
        annotations: [Body()],
      ),
      ParamInfo(
        name: 'page',
        source: ParamSource.query,
        type: 'int?',
        key: 'page',
        annotations: [Query()],
      ),
    ],
  );

  static const _childrenRoute = RouteInfo(
    operationId: 'children',
    method: 'GET',
    path: '/type-nullable/children',
    controller: TypeController,
    handler: 'children',
    annotations: [Controller('/type-nullable'), Get('/children')],
    params: [],
  );

  static const _dtoRoute = RouteInfo(
    operationId: 'dto',
    method: 'GET',
    path: '/type-nullable/dto',
    controller: TypeController,
    handler: 'dto',
    annotations: [Controller('/type-nullable'), Get('/dto')],
    params: [],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()
            ..add('POST', '/type-nullable', _operation(_echoRoute, _echo))
            ..add(
              'GET',
              '/type-nullable/children',
              _operation(_childrenRoute, _children),
            )
            ..add('GET', '/type-nullable/dto', _operation(_dtoRoute, _dto)))
          .call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _echo(Request $request) async {
    final $controller = _controllerFor($request);
    final body = await optionalBody(
      $request,
      'body',
      ($json) =>
          ($json == null ? null : Dto.fromJson($json as Map<String, dynamic>)),
    );
    final page = optionalParam(
      $request,
      ParamSource.query,
      'page',
      ParamParser.integer,
    );
    final $result = await invokeOperation(
      _echoRoute,
      [body, page],
      interceptors,
      () => $controller.echo(body, page),
    );
    final $value = $result as Dto?;
    return jsonResponse(200, $value?.toJson());
  }

  Future<Response> _children(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _childrenRoute,
      [],
      interceptors,
      () => $controller.children(),
    );
    final $value = $result as List<Child?>;
    return jsonResponse(200, $value.map(($v1) => $v1?.toJson()).toList());
  }

  Future<Response> _dto(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _dtoRoute,
      [],
      interceptors,
      () => $controller.dto(),
    );
    final $value = $result as Dto;
    return jsonResponse(200, $value.toJson());
  }
}
