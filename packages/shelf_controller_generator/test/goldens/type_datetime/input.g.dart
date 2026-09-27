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
    path: '/type-datetime',
    controller: TypeController,
    handler: 'echo',
    annotations: [Controller('/type-datetime'), Post('/')],
    params: [
      ParamInfo(
        name: 'since',
        source: ParamSource.query,
        type: 'DateTime',
        key: 'since',
        annotations: [Query()],
      ),
      ParamInfo(
        name: 'body',
        source: ParamSource.body,
        type: 'DateTime',
        annotations: [Body()],
      ),
    ],
  );

  static const _dtoRoute = RouteInfo(
    operationId: 'dto',
    method: 'GET',
    path: '/type-datetime/dto',
    controller: TypeController,
    handler: 'dto',
    annotations: [Controller('/type-datetime'), Get('/dto')],
    params: [],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()
            ..add('POST', '/type-datetime', _operation(_echoRoute, _echo))
            ..add('GET', '/type-datetime/dto', _operation(_dtoRoute, _dto)))
          .call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _echo(Request $request) async {
    final $controller = _controllerFor($request);
    final since = requireParam(
      $request,
      ParamSource.query,
      'since',
      ParamParser.dateTime,
    );
    final body = await requireBody(
      $request,
      'body',
      ($json) => DateTime.parse($json as String),
    );
    final $result = await invokeOperation(
      _echoRoute,
      [since, body],
      interceptors,
      () => $controller.echo(since, body),
    );
    final $value = $result as DateTime;
    return jsonResponse(200, $value.toIso8601String());
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
