// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

/// Binds HTTP requests to the operations of [ParametersController].
class ParametersControllerRouter {
  /// Creates a router calling a single [controller] instance.
  ParametersControllerRouter(
    ParametersController controller, {
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
  ParametersControllerRouter.perRequest(
    ParametersController Function(Request request) controllerFor, {
    this.middleware = const [],
    this.interceptors = const [],
    this.exceptionMapper = problemDetailsMapper,
  }) : _controllerFor = controllerFor;

  final ParametersController Function(Request request) _controllerFor;

  /// Middleware run after routing and before binding; the first is the
  /// outermost.
  final List<Middleware> middleware;

  /// Interceptors run around the controller method; the first is the
  /// outermost.
  final List<OperationInterceptor> interceptors;

  /// Converts exceptions to responses.
  final ExceptionMapper exceptionMapper;

  /// Metadata of all operations of the controller.
  static const routes = <RouteInfo>[_searchRoute, _allRoute, _rawRoute];

  static const _searchRoute = RouteInfo(
    operationId: 'search',
    method: 'GET',
    path: '/items/<id|[0-9]+>/children/<childName|[a-z]+>',
    controller: ParametersController,
    handler: 'search',
    annotations: [
      Controller('/items'),
      Get('/<id|[0-9]+>/children/<childName|[a-z]+>'),
    ],
    params: [
      ParamInfo(
        name: 'id',
        source: ParamSource.path,
        type: 'int',
        key: 'id',
        annotations: [Path()],
      ),
      ParamInfo(
        name: 'child',
        source: ParamSource.path,
        type: 'String',
        key: 'childName',
        annotations: [Path('childName', 'Name of the child')],
      ),
      ParamInfo(
        name: 'query',
        source: ParamSource.query,
        type: 'String?',
        key: 'q',
        annotations: [Query('q', 'Full-text query')],
      ),
      ParamInfo(
        name: 'limit',
        source: ParamSource.query,
        type: 'int',
        key: 'limit',
        annotations: [Query(), ApiField(minimum: 1, maximum: 100)],
      ),
      ParamInfo(
        name: 'requestId',
        source: ParamSource.header,
        type: 'String',
        key: 'X-Request-Id',
        annotations: [Header('X-Request-Id')],
      ),
      ParamInfo(
        name: 'trace',
        source: ParamSource.header,
        type: 'bool?',
        key: 'X-Trace',
        annotations: [Header('X-Trace', 'Tracing flag')],
      ),
      ParamInfo(
        name: 'request',
        source: ParamSource.request,
        type: 'Request',
        annotations: [],
      ),
      ParamInfo(
        name: 'sort',
        source: ParamSource.query,
        type: 'Sort',
        key: 'sort',
        annotations: [Query()],
      ),
      ParamInfo(
        name: 'tags',
        source: ParamSource.query,
        type: 'List<String>',
        key: 'tag',
        annotations: [Query('tag')],
      ),
      ParamInfo(
        name: 'since',
        source: ParamSource.query,
        type: 'DateTime?',
        key: 'since',
        annotations: [Query()],
      ),
    ],
  );

  static const _allRoute = RouteInfo(
    operationId: 'all',
    method: 'GET',
    path: '/items',
    controller: ParametersController,
    handler: 'all',
    annotations: [Controller('/items'), Get('/')],
    params: [],
  );

  static const _rawRoute = RouteInfo(
    operationId: 'raw',
    method: 'GET',
    path: '/items/raw',
    controller: ParametersController,
    handler: 'raw',
    annotations: [Controller('/items'), Get('/raw')],
    params: [
      ParamInfo(
        name: 'request',
        source: ParamSource.request,
        type: 'Request',
        annotations: [],
      ),
    ],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()
            ..add(
              'GET',
              '/items/<id|[0-9]+>/children/<childName|[a-z]+>',
              _operation(_searchRoute, _search),
            )
            ..add('GET', '/items', _operation(_allRoute, _all))
            ..add('GET', '/items/raw', _operation(_rawRoute, _raw)))
          .call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _search(Request $request) async {
    final $controller = _controllerFor($request);
    final id = requireParam(
      $request,
      ParamSource.path,
      'id',
      ParamParser.integer,
    );
    final child = requireParam(
      $request,
      ParamSource.path,
      'childName',
      ParamParser.string,
    );
    final query = optionalParam(
      $request,
      ParamSource.query,
      'q',
      ParamParser.string,
    );
    final limit = requireParam(
      $request,
      ParamSource.query,
      'limit',
      ParamParser.integer,
    );
    final requestId = requireParam(
      $request,
      ParamSource.header,
      'X-Request-Id',
      ParamParser.string,
    );
    final trace = optionalParam(
      $request,
      ParamSource.header,
      'X-Trace',
      ParamParser.boolean,
    );
    final request = $request;
    final sort =
        optionalParam(
          $request,
          ParamSource.query,
          'sort',
          ParamParser.enumeration(Sort.values),
        ) ??
        Sort.name;
    final tags =
        optionalQueryList($request, 'tag', ParamParser.string) ??
        const ['a', 'b'];
    final since = optionalParam(
      $request,
      ParamSource.query,
      'since',
      ParamParser.dateTime,
    );
    final $result = await invokeOperation(
      _searchRoute,
      [id, child, query, limit, requestId, trace, request, sort, tags, since],
      interceptors,
      () => $controller.search(
        id,
        child,
        query,
        limit,
        requestId,
        trace,
        request,
        sort: sort,
        tags: tags,
        since: since,
      ),
    );
    final $value = $result as List<String>;
    return jsonResponse(200, $value);
  }

  Future<Response> _all(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _allRoute,
      [],
      interceptors,
      () => $controller.all(),
    );
    final $value = $result as List<String>;
    return jsonResponse(200, $value);
  }

  Future<Response> _raw(Request $request) async {
    final $controller = _controllerFor($request);
    final request = $request;
    final $result = await invokeOperation(
      _rawRoute,
      [request],
      interceptors,
      () => $controller.raw(request),
    );
    final $value = $result as String;
    return jsonResponse(200, $value);
  }
}
