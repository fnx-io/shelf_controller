import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import '../checkers.dart';
import '../doc_text.dart';
import '../json_shape.dart';
import 'controller_model.dart';
import 'route_path.dart';

/// Reads a `@Controller` class into a [ControllerModel], validating the
/// signatures of its operations.
class ControllerReader {
  const ControllerReader();

  ControllerModel read(ClassElement element) {
    final controller = ConstantReader(
      controllerChecker.firstAnnotationOf(element),
    );
    final prefix = controller.read('path').stringValue;
    final operations = [
      for (final method in element.methods)
        if (operationChecker.hasAnnotationOf(method))
          _readOperation(element, prefix, method),
    ];
    _checkUniqueRoutes(operations);
    return ControllerModel(
      element: element,
      tag: controller.peek('tag')?.stringValue,
      doc: DocText.of(element),
      operations: operations,
    );
  }

  OperationModel _readOperation(
    ClassElement controller,
    String prefix,
    MethodElement method,
  ) {
    if (method.isStatic || method.isPrivate) {
      throw InvalidGenerationSource(
        'Operations must be public instance methods.',
        element: method,
      );
    }
    final operation = ConstantReader(
      operationChecker.firstAnnotationOf(method),
    );
    final path = RoutePath.join(prefix, operation.read('path').stringValue);
    final params = method.formalParameters.map(_readParam).toList();
    _checkPathParams(method, path, params);
    _checkSingleBody(method, params);
    final (resultKind, resultShape) = _readResult(method);
    return OperationModel(
      method: method,
      httpMethod: operation.read('method').stringValue,
      path: path,
      operationId: operation.peek('operationId')?.stringValue ?? method.name!,
      successStatus: _successStatus(method, resultKind),
      resultKind: resultKind,
      resultShape: resultShape,
      params: params,
      doc: DocText.of(method),
      isHidden:
          apiHiddenChecker.hasAnnotationOf(controller) ||
          apiHiddenChecker.hasAnnotationOf(method),
      isDeprecated: method.metadata.hasDeprecated,
      apiResponses: [
        ...apiResponseChecker.annotationsOf(controller),
        ...apiResponseChecker.annotationsOf(method),
      ],
      security: _security(controller, method),
      annotationSources: [
        ..._annotationSources(controller),
        ..._annotationSources(method),
      ],
    );
  }

  ParamModel _readParam(FormalParameterElement param) {
    final bindings = <ParamSource, ConstantReader>{
      for (final (source, checker) in _bindingCheckers)
        if (checker.firstAnnotationOf(param) case final annotation?)
          source: ConstantReader(annotation),
    };
    if (bindings.length > 1) {
      throw InvalidGenerationSource(
        'Parameter `${param.name}` has more than one binding annotation.',
        element: param,
      );
    }
    if (bindings.isEmpty) return _readUnannotatedParam(param);
    final MapEntry(key: source, value: annotation) = bindings.entries.single;
    return ParamModel(
      element: param,
      source: source,
      key: source == ParamSource.body
          ? null
          : annotation.peek('name')?.stringValue ?? param.name,
      description: annotation.peek('description')?.stringValue,
      shape: _paramShape(param, source),
    );
  }

  static const _bindingCheckers = [
    (ParamSource.path, pathChecker),
    (ParamSource.query, queryChecker),
    (ParamSource.header, headerChecker),
    (ParamSource.body, bodyChecker),
  ];

  ParamModel _readUnannotatedParam(FormalParameterElement param) {
    if (!requestChecker.isExactlyType(param.type)) {
      throw InvalidGenerationSource(
        'Parameter `${param.name}` needs @Path, @Query, @Header or @Body.',
        todo: 'Only a parameter of type `Request` may be left unannotated.',
        element: param,
      );
    }
    return ParamModel(
      element: param,
      source: ParamSource.request,
      key: null,
      description: null,
      shape: null,
    );
  }

  JsonShape _paramShape(FormalParameterElement param, ParamSource source) {
    final shape = _classify(param.type, param);
    final isValid = switch (source) {
      ParamSource.body => true,
      ParamSource.query => _isSimple(shape) || _isSimpleList(shape),
      ParamSource.path => _isSimple(shape) && !shape.isNullable,
      ParamSource.header => _isSimple(shape),
      ParamSource.request => false,
    };
    if (!isValid) {
      throw InvalidGenerationSource(
        'Type `${param.type.getDisplayString()}` cannot be bound from '
        'the ${source.name}.',
        todo: source == ParamSource.path
            ? 'Path parameters must be non-nullable String, int, double, num, '
                  'bool, DateTime, Uri or an enum.'
            : 'Use String, int, double, num, bool, DateTime, Uri, an enum'
                  '${source == ParamSource.query ? ' or a List of them' : ''}.',
        element: param,
      );
    }
    return shape;
  }

  bool _isSimple(JsonShape shape) => shape is ScalarShape || shape is EnumShape;

  bool _isSimpleList(JsonShape shape) =>
      shape is ArrayShape &&
      !shape.isSet &&
      !shape.items.isNullable &&
      _isSimple(shape.items);

  (ResultKind, JsonShape?) _readResult(MethodElement method) {
    final type = _unwrapFuture(method.returnType);
    if (type is VoidType || type.isDartCoreNull) {
      return (ResultKind.empty, null);
    }
    if (responseChecker.isExactlyType(type)) return (ResultKind.response, null);
    return (ResultKind.json, _classify(type, method));
  }

  DartType _unwrapFuture(DartType type) =>
      (type.isDartAsyncFuture || type.isDartAsyncFutureOr) &&
          type is InterfaceType
      ? type.typeArguments.single
      : type;

  JsonShape _classify(DartType type, Element element) {
    try {
      return classifyJsonType(type);
    } on UnsupportedTypeException catch (e) {
      throw InvalidGenerationSource('$e', element: element);
    }
  }

  int _successStatus(MethodElement method, ResultKind resultKind) {
    final status = statusChecker.firstAnnotationOf(method);
    if (status != null) return ConstantReader(status).read('code').intValue;
    return resultKind == ResultKind.empty ? 204 : 200;
  }

  List<DartObject>? _security(ClassElement controller, MethodElement method) {
    final methodLevel = apiSecurityChecker.annotationsOf(method).toList();
    if (methodLevel.isNotEmpty) return methodLevel;
    final classLevel = apiSecurityChecker.annotationsOf(controller).toList();
    return classLevel.isEmpty ? null : classLevel;
  }

  List<String> _annotationSources(Element element) => [
    for (final annotation in element.metadata.annotations)
      annotation.toSource().substring(1),
  ];

  void _checkPathParams(
    MethodElement method,
    RoutePath path,
    List<ParamModel> params,
  ) {
    final declared = {for (final param in path.params) param.name};
    final bound = {
      for (final param in params)
        if (param.source == ParamSource.path) param.key!,
    };
    final unbound = declared.difference(bound);
    final unknown = bound.difference(declared);
    if (unbound.isNotEmpty || unknown.isNotEmpty) {
      throw InvalidGenerationSource(
        'Path parameters of `${path.shelfPath}` do not match the method: '
        '${[if (unbound.isNotEmpty) 'missing @Path for ${unbound.join(', ')}', if (unknown.isNotEmpty) 'no segment for ${unknown.join(', ')}'].join('; ')}.',
        element: method,
      );
    }
  }

  void _checkSingleBody(MethodElement method, List<ParamModel> params) {
    if (params.where((p) => p.source == ParamSource.body).length > 1) {
      throw InvalidGenerationSource(
        'An operation can have only one @Body parameter.',
        element: method,
      );
    }
  }

  void _checkUniqueRoutes(List<OperationModel> operations) {
    final seen = <String>{};
    for (final operation in operations) {
      final route = '${operation.httpMethod} ${operation.path.shelfPath}';
      if (!seen.add(route)) {
        throw InvalidGenerationSource(
          'Route `$route` is declared more than once.',
          element: operation.method,
        );
      }
    }
  }
}
