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
  static const routes = <RouteInfo>[_echoRoute, _dtoRoute];

  static const _echoRoute = RouteInfo(
    operationId: 'echo',
    method: 'POST',
    path: '/type-list-set',
    controller: TypeController,
    handler: 'echo',
    annotations: [Controller('/type-list-set'), Post('/')],
    params: [
      ParamInfo(
        name: 'id',
        source: ParamSource.query,
        type: 'List<int>',
        key: 'id',
        annotations: [Query()],
      ),
      ParamInfo(
        name: 'body',
        source: ParamSource.body,
        type: 'List<Dto>',
        annotations: [Body()],
      ),
    ],
  );

  static const _dtoRoute = RouteInfo(
    operationId: 'dto',
    method: 'GET',
    path: '/type-list-set/dto',
    controller: TypeController,
    handler: 'dto',
    annotations: [Controller('/type-list-set'), Get('/dto')],
    params: [],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()
            ..add('POST', '/type-list-set', _operation(_echoRoute, _echo))
            ..add('GET', '/type-list-set/dto', _operation(_dtoRoute, _dto)))
          .call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _echo(Request $request) async {
    final $controller = _controllerFor($request);
    final id = requireQueryList($request, 'id', ParamParser.integer);
    final body = await requireBody(
      $request,
      'body',
      ($json) => [
        for (final $v1 in $json as List<Object?>)
          Dto.fromJson($v1 as Map<String, dynamic>),
      ],
    );
    final $result = await invokeOperation(
      _echoRoute,
      [id, body],
      interceptors,
      () => $controller.echo(id, body),
    );
    final $value = $result as Set<Dto>;
    return jsonResponse(200, $value.map(($v1) => $v1.toJson()).toList());
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
