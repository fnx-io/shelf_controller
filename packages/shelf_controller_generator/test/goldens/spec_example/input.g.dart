// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input.dart';

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
  static const routes = <RouteInfo>[_createRoute, _detailRoute];

  static const _createRoute = RouteInfo(
    operationId: 'create',
    method: 'POST',
    path: '/api/projects',
    controller: ProjectsController,
    handler: 'create',
    annotations: [
      Controller('/api/projects', tag: 'Projects'),
      Post('/'),
      Status(201),
      ApiResponse(409, description: 'Projekt s tímto kódem už existuje'),
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

  static const _detailRoute = RouteInfo(
    operationId: 'detail',
    method: 'GET',
    path: '/api/projects/<id>',
    controller: ProjectsController,
    handler: 'detail',
    annotations: [
      Controller('/api/projects', tag: 'Projects'),
      Get('/<id>'),
      ApiResponse(404),
    ],
    params: [
      ParamInfo(
        name: 'id',
        source: ParamSource.path,
        type: 'String',
        key: 'id',
        annotations: [Path()],
      ),
      ParamInfo(
        name: 'withMembers',
        source: ParamSource.query,
        type: 'bool?',
        key: 'withMembers',
        annotations: [Query()],
      ),
    ],
  );

  /// The shelf handler of all operations.
  late final Handler handler =
      (Router()
            ..add('POST', '/api/projects', _operation(_createRoute, _create))
            ..add(
              'GET',
              '/api/projects/<id>',
              _operation(_detailRoute, _detail),
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

  Future<Response> _detail(Request $request) async {
    final $controller = _controllerFor($request);
    final id = requireParam(
      $request,
      ParamSource.path,
      'id',
      ParamParser.string,
    );
    final withMembers = optionalParam(
      $request,
      ParamSource.query,
      'withMembers',
      ParamParser.boolean,
    );
    final $result = await invokeOperation(
      _detailRoute,
      [id, withMembers],
      interceptors,
      () => $controller.detail(id, withMembers),
    );
    final $value = $result as ProjectDto;
    return jsonResponse(200, $value.toJson());
  }
}
