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
    path: '/type-bool',
    controller: TypeController,
    handler: 'echo',
    annotations: [Controller('/type-bool'), Post('/')],
    params: [
      ParamInfo(
        name: 'flag',
        source: ParamSource.query,
        type: 'bool',
        key: 'flag',
        annotations: [Query()],
      ),
      ParamInfo(
        name: 'header',
        source: ParamSource.header,
        type: 'bool?',
        key: 'X-Flag',
        annotations: [Header('X-Flag')],
      ),
      ParamInfo(
        name: 'body',
        source: ParamSource.body,
        type: 'bool',
        annotations: [Body()],
      ),
    ],
  );

  static const _dtoRoute = RouteInfo(
    operationId: 'dto',
    method: 'GET',
    path: '/type-bool/dto',
    controller: TypeController,
    handler: 'dto',
    annotations: [Controller('/type-bool'), Get('/dto')],
    params: [],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()
            ..add('POST', '/type-bool', _operation(_echoRoute, _echo))
            ..add('GET', '/type-bool/dto', _operation(_dtoRoute, _dto)))
          .call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _echo(Request $request) async {
    final $controller = _controllerFor($request);
    final flag = requireParam(
      $request,
      ParamSource.query,
      'flag',
      ParamParser.boolean,
    );
    final header = optionalParam(
      $request,
      ParamSource.header,
      'X-Flag',
      ParamParser.boolean,
    );
    final body = await requireBody($request, 'body', ($json) => $json as bool);
    final $result = await invokeOperation(
      _echoRoute,
      [flag, header, body],
      interceptors,
      () => $controller.echo(flag, header, body),
    );
    final $value = $result as bool;
    return jsonResponse(200, $value);
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
