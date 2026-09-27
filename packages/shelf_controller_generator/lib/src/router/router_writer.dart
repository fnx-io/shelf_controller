import '../json_shape.dart';
import '../model/controller_model.dart';
import '../type_namer.dart';
import 'dart_literal.dart';
import 'json_codec_writer.dart';

/// Writes the `<Controller>Router` class of a controller.
class RouterWriter {
  final TypeNamer _namer;
  final JsonCodecWriter _codec;

  RouterWriter(this._namer) : _codec = JsonCodecWriter(_namer);

  String write(ControllerModel controller) {
    final c = controller.name;
    final router = '${c}Router';
    return '''
/// Binds HTTP requests to the operations of [$c].
class $router {
  /// Creates a router calling a single [controller] instance.
  $router(
    $c controller, {
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
  $router.perRequest(
    $c Function(Request request) controllerFor, {
    this.middleware = const [],
    this.interceptors = const [],
    this.exceptionMapper = problemDetailsMapper,
  }) : _controllerFor = controllerFor;

  final $c Function(Request request) _controllerFor;

  /// Middleware run after routing and before binding; the first is the
  /// outermost.
  final List<Middleware> middleware;

  /// Interceptors run around the controller method; the first is the
  /// outermost.
  final List<OperationInterceptor> interceptors;

  /// Converts exceptions to responses.
  final ExceptionMapper exceptionMapper;

  /// Metadata of all operations of the controller.
  static const routes = <RouteInfo>[${controller.operations.map((o) => '${_routeConstant(o)}, ').join()}];

${controller.operations.map((o) => _routeInfo(controller, o)).join('\n')}

  /// The shelf handler of all operations.
  late final Handler handler = (Router()
${controller.operations.map(_registration).join('\n')}
  ).call;

  Handler _operation(RouteInfo route, Handler handler) => operationHandler(
    route,
    handler,
    middleware: middleware,
    exceptionMapper: exceptionMapper,
  );

${controller.operations.map(_handlerMethod).join('\n')}
}
''';
  }

  String _routeConstant(OperationModel operation) => '_${operation.name}Route';

  String _routeInfo(ControllerModel controller, OperationModel operation) =>
      '''
  static const ${_routeConstant(operation)} = RouteInfo(
    operationId: ${dartString(operation.operationId)},
    method: ${dartString(operation.httpMethod)},
    path: ${dartString(operation.path.shelfPath)},
    controller: ${controller.name},
    handler: ${dartString(operation.name)},
    annotations: [${operation.annotationSources.map((a) => '$a, ').join()}],
    params: [${operation.params.map(_paramInfo).join()}],
  );
''';

  String _paramInfo(ParamModel param) =>
      '''
      ParamInfo(
        name: ${dartString(param.name)},
        source: ParamSource.${param.source.name},
        type: ${dartString(param.type.getDisplayString())},
        ${param.key == null ? '' : 'key: ${dartString(param.key!)},\n        '}annotations: [${param.element.metadata.annotations.map((a) => '${a.toSource().substring(1)}, ').join()}],
      ),''';

  String _registration(OperationModel operation) =>
      '    ..add(${dartString(operation.httpMethod)}, '
      '${dartString(operation.path.shelfPath)}, '
      '_operation(${_routeConstant(operation)}, _${operation.name}))';

  String _handlerMethod(OperationModel operation) {
    final arguments = operation.params.map((p) => p.name).join(', ');
    return '''
  Future<Response> _${operation.name}(Request \$request) async {
    final \$controller = _controllerFor(\$request);
${operation.params.map((p) => '    final ${p.name} = ${_binding(p)};').join('\n')}
    ${operation.resultKind == ResultKind.empty ? '' : 'final \$result = '}await invokeOperation(
      ${_routeConstant(operation)},
      [$arguments],
      interceptors,
      () => \$controller.${operation.name}(${_callArguments(operation)}),
    );
    ${_response(operation)}
  }
''';
  }

  String _callArguments(OperationModel operation) => operation.params
      .map((p) => p.element.isNamed ? '${p.name}: ${p.name}' : p.name)
      .join(', ');

  String _binding(ParamModel param) {
    final fallback = param.defaultValueCode == null
        ? ''
        : ' ?? ${param.defaultValueCode}';
    final optional = !param.isRequired;
    switch (param.source) {
      case ParamSource.request:
        return '\$request';
      case ParamSource.body:
        final decode = _codec.decode(param.shape!, r'$json');
        final function = optional ? 'optionalBody' : 'requireBody';
        return 'await $function(\$request, ${dartString(param.name)}, '
            '(\$json) => $decode)$fallback';
      case ParamSource.query when param.shape is ArrayShape:
        final items = (param.shape! as ArrayShape).items;
        final function = optional ? 'optionalQueryList' : 'requireQueryList';
        return '$function(\$request, ${dartString(param.key!)}, '
            '${_parser(items)})$fallback';
      case ParamSource.path || ParamSource.query || ParamSource.header:
        final function = optional ? 'optionalParam' : 'requireParam';
        return '$function(\$request, ParamSource.${param.source.name}, '
            '${dartString(param.key!)}, ${_parser(param.shape!)})$fallback';
    }
  }

  String _parser(JsonShape shape) => switch (shape) {
    EnumShape() =>
      'ParamParser.enumeration(${_namer.nonNullNameOf(shape.type)}.values)',
    ScalarShape(:final kind) => 'ParamParser.${_parserNames[kind]}',
    _ => throw StateError('No parser for ${shape.type}'),
  };

  static const _parserNames = {
    ScalarKind.string: 'string',
    ScalarKind.integer: 'integer',
    ScalarKind.float: 'float',
    ScalarKind.number: 'number',
    ScalarKind.boolean: 'boolean',
    ScalarKind.dateTime: 'dateTime',
    ScalarKind.uri: 'uri',
  };

  String _response(OperationModel operation) {
    final status = operation.successStatus;
    switch (operation.resultKind) {
      case ResultKind.empty:
        return 'return emptyResponse($status);';
      case ResultKind.response:
        return 'return \$result as Response;';
      case ResultKind.json:
        final shape = operation.resultShape!;
        return 'final \$value = \$result as ${_namer.nameOf(shape.type)};\n'
            '    return jsonResponse($status, ${_codec.encode(shape, r'$value')});';
    }
  }
}
