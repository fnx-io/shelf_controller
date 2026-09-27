// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

/// Binds HTTP requests to the operations of [TicketsController].
class TicketsControllerRouter {
  /// Creates a router calling a single [controller] instance.
  TicketsControllerRouter(
    TicketsController controller, {
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
  TicketsControllerRouter.perRequest(
    TicketsController Function(Request request) controllerFor, {
    this.middleware = const [],
    this.interceptors = const [],
    this.exceptionMapper = problemDetailsMapper,
  }) : _controllerFor = controllerFor;

  final TicketsController Function(Request request) _controllerFor;

  /// Middleware run after routing and before binding; the first is the
  /// outermost.
  final List<Middleware> middleware;

  /// Interceptors run around the controller method; the first is the
  /// outermost.
  final List<OperationInterceptor> interceptors;

  /// Converts exceptions to responses.
  final ExceptionMapper exceptionMapper;

  /// Metadata of all operations of the controller.
  static const routes = <RouteInfo>[_createRoute];

  static const _createRoute = RouteInfo(
    operationId: 'create',
    method: 'POST',
    path: '/tickets/<status>',
    controller: TicketsController,
    handler: 'create',
    annotations: [Controller('/tickets'), Post('/<status>')],
    params: [
      ParamInfo(
        name: 'status',
        source: ParamSource.path,
        type: 'Status',
        key: 'status',
        annotations: [Path()],
      ),
      ParamInfo(
        name: 'tickets',
        source: ParamSource.body,
        type: 'List<TicketDto>',
        annotations: [Body()],
      ),
    ],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()..add(
            'POST',
            '/tickets/<status>',
            _operation(_createRoute, _create),
          ))
          .call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _create(Request $request) async {
    final $controller = _controllerFor($request);
    final status = requireParam(
      $request,
      ParamSource.path,
      'status',
      ParamParser.enumeration(dto.Status.values),
    );
    final tickets = await requireBody(
      $request,
      'tickets',
      ($json) => [
        for (final $v1 in $json as List<Object?>)
          dto.TicketDto.fromJson($v1 as Map<String, dynamic>),
      ],
    );
    final $result = await invokeOperation(
      _createRoute,
      [status, tickets],
      interceptors,
      () => $controller.create(status, tickets),
    );
    final $value = $result as List<dto.TicketDto>;
    return jsonResponse(200, $value.map(($v1) => $v1.toJson()).toList());
  }
}
