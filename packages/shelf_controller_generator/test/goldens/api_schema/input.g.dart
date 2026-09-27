// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

/// Binds HTTP requests to the operations of [OrdersController].
class OrdersControllerRouter {
  /// Creates a router calling a single [controller] instance.
  OrdersControllerRouter(
    OrdersController controller, {
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
  OrdersControllerRouter.perRequest(
    OrdersController Function(Request request) controllerFor, {
    this.middleware = const [],
    this.interceptors = const [],
    this.exceptionMapper = problemDetailsMapper,
  }) : _controllerFor = controllerFor;

  final OrdersController Function(Request request) _controllerFor;

  /// Middleware run after routing and before binding; the first is the
  /// outermost.
  final List<Middleware> middleware;

  /// Interceptors run around the controller method; the first is the
  /// outermost.
  final List<OperationInterceptor> interceptors;

  /// Converts exceptions to responses.
  final ExceptionMapper exceptionMapper;

  /// Metadata of all operations of the controller.
  static const routes = <RouteInfo>[_createRoute, _priceRoute];

  static const _createRoute = RouteInfo(
    operationId: 'create',
    method: 'POST',
    path: '/orders',
    controller: OrdersController,
    handler: 'create',
    annotations: [Controller('/orders'), Post('/')],
    params: [
      ParamInfo(
        name: 'order',
        source: ParamSource.body,
        type: 'OrderDto',
        annotations: [Body()],
      ),
    ],
  );

  static const _priceRoute = RouteInfo(
    operationId: 'price',
    method: 'GET',
    path: '/orders/price',
    controller: OrdersController,
    handler: 'price',
    annotations: [Controller('/orders'), Get('/price')],
    params: [],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()
            ..add('POST', '/orders', _operation(_createRoute, _create))
            ..add('GET', '/orders/price', _operation(_priceRoute, _price)))
          .call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _create(Request $request) async {
    final $controller = _controllerFor($request);
    final order = await requireBody(
      $request,
      'order',
      ($json) => OrderDto.fromJson($json as Map<String, dynamic>),
    );
    final $result = await invokeOperation(
      _createRoute,
      [order],
      interceptors,
      () => $controller.create(order),
    );
    final $value = $result as OrderDto;
    return jsonResponse(200, $value.toJson());
  }

  Future<Response> _price(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _priceRoute,
      [],
      interceptors,
      () => $controller.price(),
    );
    final $value = $result as Money;
    return jsonResponse(200, $value.toJson());
  }
}
