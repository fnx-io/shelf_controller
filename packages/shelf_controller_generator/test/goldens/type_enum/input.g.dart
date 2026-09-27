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
    path: '/type-enum/<kind>',
    controller: TypeController,
    handler: 'echo',
    annotations: [Controller('/type-enum'), Post('/<kind>')],
    params: [
      ParamInfo(
        name: 'kind',
        source: ParamSource.path,
        type: 'Explicit',
        key: 'kind',
        annotations: [Path()],
      ),
      ParamInfo(
        name: 'renamed',
        source: ParamSource.query,
        type: 'List<Renamed>?',
        key: 'renamed',
        annotations: [Query()],
      ),
      ParamInfo(
        name: 'body',
        source: ParamSource.body,
        type: 'Numeric',
        annotations: [Body()],
      ),
    ],
  );

  static const _dtoRoute = RouteInfo(
    operationId: 'dto',
    method: 'GET',
    path: '/type-enum/dto',
    controller: TypeController,
    handler: 'dto',
    annotations: [Controller('/type-enum'), Get('/dto')],
    params: [],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()
            ..add('POST', '/type-enum/<kind>', _operation(_echoRoute, _echo))
            ..add('GET', '/type-enum/dto', _operation(_dtoRoute, _dto)))
          .call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _echo(Request $request) async {
    final $controller = _controllerFor($request);
    final kind = requireParam(
      $request,
      ParamSource.path,
      'kind',
      ParamParser.enumeration(Explicit.values),
    );
    final renamed = optionalQueryList(
      $request,
      'renamed',
      ParamParser.enumeration(Renamed.values),
    );
    final body = await requireBody(
      $request,
      'body',
      ($json) => Numeric.values.byName($json as String),
    );
    final $result = await invokeOperation(
      _echoRoute,
      [kind, renamed, body],
      interceptors,
      () => $controller.echo(kind, renamed, body),
    );
    final $value = $result as Explicit;
    return jsonResponse(200, $value.name);
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
