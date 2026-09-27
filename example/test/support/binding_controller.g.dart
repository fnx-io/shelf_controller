// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'binding_controller.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

/// Binds HTTP requests to the operations of [BindingController].
class BindingControllerRouter {
  /// Creates a router calling a single [controller] instance.
  BindingControllerRouter(
    BindingController controller, {
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
  BindingControllerRouter.perRequest(
    BindingController Function(Request request) controllerFor, {
    this.middleware = const [],
    this.interceptors = const [],
    this.exceptionMapper = problemDetailsMapper,
  }) : _controllerFor = controllerFor;

  final BindingController Function(Request request) _controllerFor;

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
    _pathRoute,
    _scalarsRoute,
    _optionalRoute,
    _requiredListRoute,
    _headerRoute,
    _objectBodyRoute,
    _listBodyRoute,
    _mapBodyRoute,
    _optionalBodyRoute,
    _primitiveBodyRoute,
    _setResultRoute,
    _dateResultRoute,
    _nullableResultRoute,
    _mapResultRoute,
    _voidResultRoute,
    _rawResponseRoute,
    _failureRoute,
    _tracedRoute,
  ];

  static const _pathRoute = RouteInfo(
    operationId: 'path',
    method: 'GET',
    path: '/bind/path/<id|[0-9]+>/<name>',
    controller: BindingController,
    handler: 'path',
    annotations: [
      Controller('/bind', tag: 'Binding'),
      Get('/path/<id|[0-9]+>/<name>'),
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
        name: 'name',
        source: ParamSource.path,
        type: 'String',
        key: 'name',
        annotations: [Path()],
      ),
    ],
  );

  static const _scalarsRoute = RouteInfo(
    operationId: 'scalars',
    method: 'GET',
    path: '/bind/scalars',
    controller: BindingController,
    handler: 'scalars',
    annotations: [
      Controller('/bind', tag: 'Binding'),
      Get('/scalars'),
    ],
    params: [
      ParamInfo(
        name: 'text',
        source: ParamSource.query,
        type: 'String',
        key: 'text',
        annotations: [Query()],
      ),
      ParamInfo(
        name: 'count',
        source: ParamSource.query,
        type: 'int',
        key: 'count',
        annotations: [Query()],
      ),
      ParamInfo(
        name: 'ratio',
        source: ParamSource.query,
        type: 'double',
        key: 'ratio',
        annotations: [Query()],
      ),
      ParamInfo(
        name: 'amount',
        source: ParamSource.query,
        type: 'num',
        key: 'amount',
        annotations: [Query()],
      ),
      ParamInfo(
        name: 'flag',
        source: ParamSource.query,
        type: 'bool',
        key: 'flag',
        annotations: [Query()],
      ),
      ParamInfo(
        name: 'at',
        source: ParamSource.query,
        type: 'DateTime',
        key: 'at',
        annotations: [Query()],
      ),
      ParamInfo(
        name: 'link',
        source: ParamSource.query,
        type: 'Uri',
        key: 'link',
        annotations: [Query()],
      ),
      ParamInfo(
        name: 'color',
        source: ParamSource.query,
        type: 'Color',
        key: 'color',
        annotations: [Query()],
      ),
    ],
  );

  static const _optionalRoute = RouteInfo(
    operationId: 'optional',
    method: 'GET',
    path: '/bind/optional',
    controller: BindingController,
    handler: 'optional',
    annotations: [
      Controller('/bind', tag: 'Binding'),
      Get('/optional'),
    ],
    params: [
      ParamInfo(
        name: 'page',
        source: ParamSource.query,
        type: 'int?',
        key: 'page',
        annotations: [Query()],
      ),
      ParamInfo(
        name: 'size',
        source: ParamSource.query,
        type: 'int',
        key: 'page-size',
        annotations: [Query('page-size')],
      ),
      ParamInfo(
        name: 'tags',
        source: ParamSource.query,
        type: 'List<String>?',
        key: 'tag',
        annotations: [Query('tag')],
      ),
      ParamInfo(
        name: 'ids',
        source: ParamSource.query,
        type: 'List<int>',
        key: 'id',
        annotations: [Query('id')],
      ),
    ],
  );

  static const _requiredListRoute = RouteInfo(
    operationId: 'requiredList',
    method: 'GET',
    path: '/bind/required-list',
    controller: BindingController,
    handler: 'requiredList',
    annotations: [
      Controller('/bind', tag: 'Binding'),
      Get('/required-list'),
    ],
    params: [
      ParamInfo(
        name: 'colors',
        source: ParamSource.query,
        type: 'List<Color>',
        key: 'c',
        annotations: [Query('c')],
      ),
    ],
  );

  static const _headerRoute = RouteInfo(
    operationId: 'header',
    method: 'GET',
    path: '/bind/header',
    controller: BindingController,
    handler: 'header',
    annotations: [
      Controller('/bind', tag: 'Binding'),
      Get('/header'),
    ],
    params: [
      ParamInfo(
        name: 'count',
        source: ParamSource.header,
        type: 'int',
        key: 'X-Count',
        annotations: [Header('X-Count')],
      ),
      ParamInfo(
        name: 'name',
        source: ParamSource.header,
        type: 'String?',
        key: 'X-Name',
        annotations: [Header('X-Name')],
      ),
    ],
  );

  static const _objectBodyRoute = RouteInfo(
    operationId: 'objectBody',
    method: 'POST',
    path: '/bind/body/object',
    controller: BindingController,
    handler: 'objectBody',
    annotations: [
      Controller('/bind', tag: 'Binding'),
      Post('/body/object'),
    ],
    params: [
      ParamInfo(
        name: 'project',
        source: ParamSource.body,
        type: 'ProjectDto',
        annotations: [Body()],
      ),
    ],
  );

  static const _listBodyRoute = RouteInfo(
    operationId: 'listBody',
    method: 'POST',
    path: '/bind/body/list',
    controller: BindingController,
    handler: 'listBody',
    annotations: [
      Controller('/bind', tag: 'Binding'),
      Post('/body/list'),
    ],
    params: [
      ParamInfo(
        name: 'items',
        source: ParamSource.body,
        type: 'List<CreateProjectDto>',
        annotations: [Body()],
      ),
    ],
  );

  static const _mapBodyRoute = RouteInfo(
    operationId: 'mapBody',
    method: 'POST',
    path: '/bind/body/map',
    controller: BindingController,
    handler: 'mapBody',
    annotations: [
      Controller('/bind', tag: 'Binding'),
      Post('/body/map'),
    ],
    params: [
      ParamInfo(
        name: 'counts',
        source: ParamSource.body,
        type: 'Map<String, int>',
        annotations: [Body()],
      ),
    ],
  );

  static const _optionalBodyRoute = RouteInfo(
    operationId: 'optionalBody',
    method: 'POST',
    path: '/bind/body/optional',
    controller: BindingController,
    handler: 'optionalBody',
    annotations: [
      Controller('/bind', tag: 'Binding'),
      Post('/body/optional'),
    ],
    params: [
      ParamInfo(
        name: 'project',
        source: ParamSource.body,
        type: 'CreateProjectDto?',
        annotations: [Body()],
      ),
    ],
  );

  static const _primitiveBodyRoute = RouteInfo(
    operationId: 'primitiveBody',
    method: 'POST',
    path: '/bind/body/primitive',
    controller: BindingController,
    handler: 'primitiveBody',
    annotations: [
      Controller('/bind', tag: 'Binding'),
      Post('/body/primitive'),
    ],
    params: [
      ParamInfo(
        name: 'value',
        source: ParamSource.body,
        type: 'int',
        annotations: [Body()],
      ),
    ],
  );

  static const _setResultRoute = RouteInfo(
    operationId: 'setResult',
    method: 'GET',
    path: '/bind/result/set',
    controller: BindingController,
    handler: 'setResult',
    annotations: [
      Controller('/bind', tag: 'Binding'),
      Get('/result/set'),
    ],
    params: [],
  );

  static const _dateResultRoute = RouteInfo(
    operationId: 'dateResult',
    method: 'GET',
    path: '/bind/result/date',
    controller: BindingController,
    handler: 'dateResult',
    annotations: [
      Controller('/bind', tag: 'Binding'),
      Get('/result/date'),
    ],
    params: [],
  );

  static const _nullableResultRoute = RouteInfo(
    operationId: 'nullableResult',
    method: 'GET',
    path: '/bind/result/nullable',
    controller: BindingController,
    handler: 'nullableResult',
    annotations: [
      Controller('/bind', tag: 'Binding'),
      Get('/result/nullable'),
    ],
    params: [],
  );

  static const _mapResultRoute = RouteInfo(
    operationId: 'mapResult',
    method: 'GET',
    path: '/bind/result/map',
    controller: BindingController,
    handler: 'mapResult',
    annotations: [
      Controller('/bind', tag: 'Binding'),
      Get('/result/map'),
    ],
    params: [],
  );

  static const _voidResultRoute = RouteInfo(
    operationId: 'voidResult',
    method: 'POST',
    path: '/bind/void',
    controller: BindingController,
    handler: 'voidResult',
    annotations: [
      Controller('/bind', tag: 'Binding'),
      Post('/void'),
    ],
    params: [],
  );

  static const _rawResponseRoute = RouteInfo(
    operationId: 'rawResponse',
    method: 'GET',
    path: '/bind/response',
    controller: BindingController,
    handler: 'rawResponse',
    annotations: [
      Controller('/bind', tag: 'Binding'),
      Get('/response'),
    ],
    params: [
      ParamInfo(
        name: 'request',
        source: ParamSource.request,
        type: 'Request',
        annotations: [],
      ),
    ],
  );

  static const _failureRoute = RouteInfo(
    operationId: 'failure',
    method: 'GET',
    path: '/bind/failure',
    controller: BindingController,
    handler: 'failure',
    annotations: [
      Controller('/bind', tag: 'Binding'),
      Get('/failure'),
    ],
    params: [],
  );

  static const _tracedRoute = RouteInfo(
    operationId: 'traced',
    method: 'GET',
    path: '/bind/traced/<id>',
    controller: BindingController,
    handler: 'traced',
    annotations: [
      Controller('/bind', tag: 'Binding'),
      Get('/traced/<id>'),
      Secured(['tracing']),
    ],
    params: [
      ParamInfo(
        name: 'id',
        source: ParamSource.path,
        type: 'String',
        key: 'id',
        annotations: [Path()],
      ),
    ],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()
            ..add(
              'GET',
              '/bind/path/<id|[0-9]+>/<name>',
              _operation(_pathRoute, _path),
            )
            ..add('GET', '/bind/scalars', _operation(_scalarsRoute, _scalars))
            ..add(
              'GET',
              '/bind/optional',
              _operation(_optionalRoute, _optional),
            )
            ..add(
              'GET',
              '/bind/required-list',
              _operation(_requiredListRoute, _requiredList),
            )
            ..add('GET', '/bind/header', _operation(_headerRoute, _header))
            ..add(
              'POST',
              '/bind/body/object',
              _operation(_objectBodyRoute, _objectBody),
            )
            ..add(
              'POST',
              '/bind/body/list',
              _operation(_listBodyRoute, _listBody),
            )
            ..add('POST', '/bind/body/map', _operation(_mapBodyRoute, _mapBody))
            ..add(
              'POST',
              '/bind/body/optional',
              _operation(_optionalBodyRoute, _optionalBody),
            )
            ..add(
              'POST',
              '/bind/body/primitive',
              _operation(_primitiveBodyRoute, _primitiveBody),
            )
            ..add(
              'GET',
              '/bind/result/set',
              _operation(_setResultRoute, _setResult),
            )
            ..add(
              'GET',
              '/bind/result/date',
              _operation(_dateResultRoute, _dateResult),
            )
            ..add(
              'GET',
              '/bind/result/nullable',
              _operation(_nullableResultRoute, _nullableResult),
            )
            ..add(
              'GET',
              '/bind/result/map',
              _operation(_mapResultRoute, _mapResult),
            )
            ..add(
              'POST',
              '/bind/void',
              _operation(_voidResultRoute, _voidResult),
            )
            ..add(
              'GET',
              '/bind/response',
              _operation(_rawResponseRoute, _rawResponse),
            )
            ..add('GET', '/bind/failure', _operation(_failureRoute, _failure))
            ..add(
              'GET',
              '/bind/traced/<id>',
              _operation(_tracedRoute, _traced),
            ))
          .call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

  Future<Response> _path(Request $request) async {
    final $controller = _controllerFor($request);
    final id = requireParam(
      $request,
      ParamSource.path,
      'id',
      ParamParser.integer,
    );
    final name = requireParam(
      $request,
      ParamSource.path,
      'name',
      ParamParser.string,
    );
    final $result = await invokeOperation(
      _pathRoute,
      [id, name],
      interceptors,
      () => $controller.path(id, name),
    );
    final $value = $result as Map<String, Object?>;
    return jsonResponse(200, $value);
  }

  Future<Response> _scalars(Request $request) async {
    final $controller = _controllerFor($request);
    final text = requireParam(
      $request,
      ParamSource.query,
      'text',
      ParamParser.string,
    );
    final count = requireParam(
      $request,
      ParamSource.query,
      'count',
      ParamParser.integer,
    );
    final ratio = requireParam(
      $request,
      ParamSource.query,
      'ratio',
      ParamParser.float,
    );
    final amount = requireParam(
      $request,
      ParamSource.query,
      'amount',
      ParamParser.number,
    );
    final flag = requireParam(
      $request,
      ParamSource.query,
      'flag',
      ParamParser.boolean,
    );
    final at = requireParam(
      $request,
      ParamSource.query,
      'at',
      ParamParser.dateTime,
    );
    final link = requireParam(
      $request,
      ParamSource.query,
      'link',
      ParamParser.uri,
    );
    final color = requireParam(
      $request,
      ParamSource.query,
      'color',
      ParamParser.enumeration(Color.values),
    );
    final $result = await invokeOperation(
      _scalarsRoute,
      [text, count, ratio, amount, flag, at, link, color],
      interceptors,
      () => $controller.scalars(
        text,
        count,
        ratio,
        amount,
        flag,
        at,
        link,
        color,
      ),
    );
    final $value = $result as Map<String, Object?>;
    return jsonResponse(200, $value);
  }

  Future<Response> _optional(Request $request) async {
    final $controller = _controllerFor($request);
    final page = optionalParam(
      $request,
      ParamSource.query,
      'page',
      ParamParser.integer,
    );
    final size =
        optionalParam(
          $request,
          ParamSource.query,
          'page-size',
          ParamParser.integer,
        ) ??
        10;
    final tags = optionalQueryList($request, 'tag', ParamParser.string);
    final ids =
        optionalQueryList($request, 'id', ParamParser.integer) ?? const [1];
    final $result = await invokeOperation(
      _optionalRoute,
      [page, size, tags, ids],
      interceptors,
      () => $controller.optional(page: page, size: size, tags: tags, ids: ids),
    );
    final $value = $result as Map<String, Object?>;
    return jsonResponse(200, $value);
  }

  Future<Response> _requiredList(Request $request) async {
    final $controller = _controllerFor($request);
    final colors = requireQueryList(
      $request,
      'c',
      ParamParser.enumeration(Color.values),
    );
    final $result = await invokeOperation(
      _requiredListRoute,
      [colors],
      interceptors,
      () => $controller.requiredList(colors),
    );
    final $value = $result as List<Color>;
    return jsonResponse(200, $value.map(($v1) => $v1.name).toList());
  }

  Future<Response> _header(Request $request) async {
    final $controller = _controllerFor($request);
    final count = requireParam(
      $request,
      ParamSource.header,
      'X-Count',
      ParamParser.integer,
    );
    final name = optionalParam(
      $request,
      ParamSource.header,
      'X-Name',
      ParamParser.string,
    );
    final $result = await invokeOperation(
      _headerRoute,
      [count, name],
      interceptors,
      () => $controller.header(count, name),
    );
    final $value = $result as Map<String, Object?>;
    return jsonResponse(200, $value);
  }

  Future<Response> _objectBody(Request $request) async {
    final $controller = _controllerFor($request);
    final project = await requireBody(
      $request,
      'project',
      ($json) => ProjectDto.fromJson($json as Map<String, dynamic>),
    );
    final $result = await invokeOperation(
      _objectBodyRoute,
      [project],
      interceptors,
      () => $controller.objectBody(project),
    );
    final $value = $result as ProjectDto;
    return jsonResponse(200, $value.toJson());
  }

  Future<Response> _listBody(Request $request) async {
    final $controller = _controllerFor($request);
    final items = await requireBody(
      $request,
      'items',
      ($json) => [
        for (final $v1 in $json as List<Object?>)
          CreateProjectDto.fromJson($v1 as Map<String, dynamic>),
      ],
    );
    final $result = await invokeOperation(
      _listBodyRoute,
      [items],
      interceptors,
      () => $controller.listBody(items),
    );
    final $value = $result as List<CreateProjectDto>;
    return jsonResponse(200, $value.map(($v1) => $v1.toJson()).toList());
  }

  Future<Response> _mapBody(Request $request) async {
    final $controller = _controllerFor($request);
    final counts = await requireBody(
      $request,
      'counts',
      ($json) => {
        for (final MapEntry(key: $k1, value: $v1)
            in ($json as Map<String, Object?>).entries)
          $k1: ($v1 as num).toInt(),
      },
    );
    final $result = await invokeOperation(
      _mapBodyRoute,
      [counts],
      interceptors,
      () => $controller.mapBody(counts),
    );
    final $value = $result as Map<String, int>;
    return jsonResponse(200, $value);
  }

  Future<Response> _optionalBody(Request $request) async {
    final $controller = _controllerFor($request);
    final project = await optionalBody(
      $request,
      'project',
      ($json) => ($json == null
          ? null
          : CreateProjectDto.fromJson($json as Map<String, dynamic>)),
    );
    final $result = await invokeOperation(
      _optionalBodyRoute,
      [project],
      interceptors,
      () => $controller.optionalBody(project),
    );
    final $value = $result as String;
    return jsonResponse(200, $value);
  }

  Future<Response> _primitiveBody(Request $request) async {
    final $controller = _controllerFor($request);
    final value = await requireBody(
      $request,
      'value',
      ($json) => ($json as num).toInt(),
    );
    final $result = await invokeOperation(
      _primitiveBodyRoute,
      [value],
      interceptors,
      () => $controller.primitiveBody(value),
    );
    final $value = $result as int;
    return jsonResponse(200, $value);
  }

  Future<Response> _setResult(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _setResultRoute,
      [],
      interceptors,
      () => $controller.setResult(),
    );
    final $value = $result as Set<Color>;
    return jsonResponse(200, $value.map(($v1) => $v1.name).toList());
  }

  Future<Response> _dateResult(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _dateResultRoute,
      [],
      interceptors,
      () => $controller.dateResult(),
    );
    final $value = $result as DateTime;
    return jsonResponse(200, $value.toIso8601String());
  }

  Future<Response> _nullableResult(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _nullableResultRoute,
      [],
      interceptors,
      () => $controller.nullableResult(),
    );
    final $value = $result as CreateProjectDto?;
    return jsonResponse(200, $value?.toJson());
  }

  Future<Response> _mapResult(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _mapResultRoute,
      [],
      interceptors,
      () => $controller.mapResult(),
    );
    final $value = $result as Map<String, List<CreateProjectDto>>;
    return jsonResponse(
      200,
      $value.map(
        ($k1, $v1) => MapEntry($k1, $v1.map(($v2) => $v2.toJson()).toList()),
      ),
    );
  }

  Future<Response> _voidResult(Request $request) async {
    final $controller = _controllerFor($request);

    await invokeOperation(
      _voidResultRoute,
      [],
      interceptors,
      () => $controller.voidResult(),
    );
    return emptyResponse(204);
  }

  Future<Response> _rawResponse(Request $request) async {
    final $controller = _controllerFor($request);
    final request = $request;
    final $result = await invokeOperation(
      _rawResponseRoute,
      [request],
      interceptors,
      () => $controller.rawResponse(request),
    );
    return $result as Response;
  }

  Future<Response> _failure(Request $request) async {
    final $controller = _controllerFor($request);

    final $result = await invokeOperation(
      _failureRoute,
      [],
      interceptors,
      () => $controller.failure(),
    );
    final $value = $result as String;
    return jsonResponse(200, $value);
  }

  Future<Response> _traced(Request $request) async {
    final $controller = _controllerFor($request);
    final id = requireParam(
      $request,
      ParamSource.path,
      'id',
      ParamParser.string,
    );
    final $result = await invokeOperation(
      _tracedRoute,
      [id],
      interceptors,
      () => $controller.traced(id),
    );
    final $value = $result as String;
    return jsonResponse(200, $value);
  }
}
