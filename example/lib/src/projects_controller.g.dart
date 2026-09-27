// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projects_controller.dart';

// **************************************************************************
// RouterGenerator
// **************************************************************************

/// Binds HTTP requests to the operations of [ProjectsController].
class ProjectsControllerRouter {
  /// Creates a router calling a single [controller] instance.
  ProjectsControllerRouter(
    ProjectsController controller, {
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
  ProjectsControllerRouter.perRequest(
    ProjectsController Function(Request request) controllerFor, {
    this.middleware = const [],
    this.interceptors = const [],
    this.exceptionMapper = problemDetailsMapper,
  }) : _controllerFor = controllerFor;

  final ProjectsController Function(Request request) _controllerFor;

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
    _createRoute,
    _listRoute,
    _detailRoute,
    _attachRoute,
    _archiveRoute,
    _deleteRoute,
    _exportRoute,
  ];

  static const _createRoute = RouteInfo(
    operationId: 'create',
    method: 'POST',
    path: '/api/v1/projects',
    controller: ProjectsController,
    handler: 'create',
    annotations: [
      Controller('/api/v1/projects', tag: 'Projects'),
      ApiResponse(401, description: 'Missing or invalid credentials'),
      Post('/'),
      Status(201),
      ApiResponse(403),
      ApiResponse(409, description: 'A project with this code already exists'),
      ApiResponse(422, description: 'The project code is invalid'),
      Secured(['admin']),
    ],
    params: [
      ParamInfo(
        name: 'body',
        source: ParamSource.body,
        type: 'CreateProjectDto',
        annotations: [Body()],
      ),
    ],
  );

  static const _listRoute = RouteInfo(
    operationId: 'list',
    method: 'GET',
    path: '/api/v1/projects',
    controller: ProjectsController,
    handler: 'list',
    annotations: [
      Controller('/api/v1/projects', tag: 'Projects'),
      ApiResponse(401, description: 'Missing or invalid credentials'),
      Get('/'),
    ],
    params: [
      ParamInfo(
        name: 'states',
        source: ParamSource.query,
        type: 'List<ProjectState>?',
        key: 'state',
        annotations: [Query('state', 'Only projects in one of these states')],
      ),
      ParamInfo(
        name: 'limit',
        source: ParamSource.query,
        type: 'int',
        key: 'limit',
        annotations: [Query(), ApiField(minimum: 1, maximum: 100)],
      ),
    ],
  );

  static const _detailRoute = RouteInfo(
    operationId: 'detail',
    method: 'GET',
    path: '/api/v1/projects/<code>',
    controller: ProjectsController,
    handler: 'detail',
    annotations: [
      Controller('/api/v1/projects', tag: 'Projects'),
      ApiResponse(401, description: 'Missing or invalid credentials'),
      Get('/<code>'),
      ApiResponse(404),
    ],
    params: [
      ParamInfo(
        name: 'code',
        source: ParamSource.path,
        type: 'String',
        key: 'code',
        annotations: [Path()],
      ),
    ],
  );

  static const _attachRoute = RouteInfo(
    operationId: 'attach',
    method: 'POST',
    path: '/api/v1/projects/<code>/attachments',
    controller: ProjectsController,
    handler: 'attach',
    annotations: [
      Controller('/api/v1/projects', tag: 'Projects'),
      ApiResponse(401, description: 'Missing or invalid credentials'),
      Post('/<code>/attachments'),
      ApiResponse(404),
    ],
    params: [
      ParamInfo(
        name: 'code',
        source: ParamSource.path,
        type: 'String',
        key: 'code',
        annotations: [Path()],
      ),
      ParamInfo(
        name: 'attachment',
        source: ParamSource.body,
        type: 'Attachment',
        annotations: [Body()],
      ),
    ],
  );

  static const _archiveRoute = RouteInfo(
    operationId: 'archive',
    method: 'PUT',
    path: '/api/v1/projects/<code>/archive',
    controller: ProjectsController,
    handler: 'archive',
    annotations: [
      Controller('/api/v1/projects', tag: 'Projects'),
      ApiResponse(401, description: 'Missing or invalid credentials'),
      Put('/<code>/archive'),
      ApiResponse(404),
      Secured(['admin']),
    ],
    params: [
      ParamInfo(
        name: 'code',
        source: ParamSource.path,
        type: 'String',
        key: 'code',
        annotations: [Path()],
      ),
    ],
  );

  static const _deleteRoute = RouteInfo(
    operationId: 'delete',
    method: 'DELETE',
    path: '/api/v1/projects/<code>',
    controller: ProjectsController,
    handler: 'delete',
    annotations: [
      Controller('/api/v1/projects', tag: 'Projects'),
      ApiResponse(401, description: 'Missing or invalid credentials'),
      Delete('/<code>'),
      ApiResponse(404),
      Secured(['admin']),
      Deprecated('Archive projects instead'),
    ],
    params: [
      ParamInfo(
        name: 'code',
        source: ParamSource.path,
        type: 'String',
        key: 'code',
        annotations: [Path()],
      ),
    ],
  );

  static const _exportRoute = RouteInfo(
    operationId: 'export',
    method: 'GET',
    path: '/api/v1/projects/<code>/export',
    controller: ProjectsController,
    handler: 'export',
    annotations: [
      Controller('/api/v1/projects', tag: 'Projects'),
      ApiResponse(401, description: 'Missing or invalid credentials'),
      Get('/<code>/export'),
      ApiResponse(
        200,
        type: String,
        contentType: 'text/csv',
        description: 'The project as CSV',
      ),
      ApiResponse(404),
    ],
    params: [
      ParamInfo(
        name: 'code',
        source: ParamSource.path,
        type: 'String',
        key: 'code',
        annotations: [Path()],
      ),
      ParamInfo(
        name: 'separator',
        source: ParamSource.header,
        type: 'String?',
        key: 'X-Separator',
        annotations: [Header('X-Separator')],
      ),
    ],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()
            ..add('POST', '/api/v1/projects', _operation(_createRoute, _create))
            ..add('GET', '/api/v1/projects', _operation(_listRoute, _list))
            ..add(
              'GET',
              '/api/v1/projects/<code>',
              _operation(_detailRoute, _detail),
            )
            ..add(
              'POST',
              '/api/v1/projects/<code>/attachments',
              _operation(_attachRoute, _attach),
            )
            ..add(
              'PUT',
              '/api/v1/projects/<code>/archive',
              _operation(_archiveRoute, _archive),
            )
            ..add(
              'DELETE',
              '/api/v1/projects/<code>',
              _operation(_deleteRoute, _delete),
            )
            ..add(
              'GET',
              '/api/v1/projects/<code>/export',
              _operation(_exportRoute, _export),
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
    final body = await requireBody(
      $request,
      'body',
      ($json) => CreateProjectDto.fromJson($json as Map<String, dynamic>),
    );
    final $result = await invokeOperation(
      _createRoute,
      [body],
      interceptors,
      () => $controller.create(body),
    );
    final $value = $result as ProjectDto;
    return jsonResponse(201, $value.toJson());
  }

  Future<Response> _list(Request $request) async {
    final $controller = _controllerFor($request);
    final states = optionalQueryList(
      $request,
      'state',
      ParamParser.enumeration(ProjectState.values),
    );
    final limit =
        optionalParam(
          $request,
          ParamSource.query,
          'limit',
          ParamParser.integer,
        ) ??
        20;
    final $result = await invokeOperation(
      _listRoute,
      [states, limit],
      interceptors,
      () => $controller.list(states: states, limit: limit),
    );
    final $value = $result as List<ProjectDto>;
    return jsonResponse(200, $value.map(($v1) => $v1.toJson()).toList());
  }

  Future<Response> _detail(Request $request) async {
    final $controller = _controllerFor($request);
    final code = requireParam(
      $request,
      ParamSource.path,
      'code',
      ParamParser.string,
    );
    final $result = await invokeOperation(
      _detailRoute,
      [code],
      interceptors,
      () => $controller.detail(code),
    );
    final $value = $result as ProjectDto;
    return jsonResponse(200, $value.toJson());
  }

  Future<Response> _attach(Request $request) async {
    final $controller = _controllerFor($request);
    final code = requireParam(
      $request,
      ParamSource.path,
      'code',
      ParamParser.string,
    );
    final attachment = await requireBody(
      $request,
      'attachment',
      ($json) => Attachment.fromJson($json as Map<String, dynamic>),
    );
    final $result = await invokeOperation(
      _attachRoute,
      [code, attachment],
      interceptors,
      () => $controller.attach(code, attachment),
    );
    final $value = $result as ProjectDto;
    return jsonResponse(200, $value.toJson());
  }

  Future<Response> _archive(Request $request) async {
    final $controller = _controllerFor($request);
    final code = requireParam(
      $request,
      ParamSource.path,
      'code',
      ParamParser.string,
    );
    await invokeOperation(
      _archiveRoute,
      [code],
      interceptors,
      () => $controller.archive(code),
    );
    return emptyResponse(204);
  }

  Future<Response> _delete(Request $request) async {
    final $controller = _controllerFor($request);
    final code = requireParam(
      $request,
      ParamSource.path,
      'code',
      ParamParser.string,
    );
    await invokeOperation(
      _deleteRoute,
      [code],
      interceptors,
      () => $controller.delete(code),
    );
    return emptyResponse(204);
  }

  Future<Response> _export(Request $request) async {
    final $controller = _controllerFor($request);
    final code = requireParam(
      $request,
      ParamSource.path,
      'code',
      ParamParser.string,
    );
    final separator = optionalParam(
      $request,
      ParamSource.header,
      'X-Separator',
      ParamParser.string,
    );
    final $result = await invokeOperation(
      _exportRoute,
      [code, separator],
      interceptors,
      () => $controller.export(code, separator),
    );
    return $result as Response;
  }
}
