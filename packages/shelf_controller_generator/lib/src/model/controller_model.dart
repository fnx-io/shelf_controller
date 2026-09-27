import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../doc_text.dart';
import '../json_shape.dart';
import 'route_path.dart';

/// Where the value of a method parameter comes from.
///
/// Mirrors `ParamSource` of `shelf_controller`; the names must match.
enum ParamSource { path, query, header, body, request }

/// A parameter of a controller method.
class ParamModel {
  final FormalParameterElement element;
  final ParamSource source;

  /// The name in the request (path segment, query parameter or header).
  final String? key;

  /// The description from the binding annotation.
  final String? description;

  /// The JSON shape of the value; `null` for [ParamSource.request].
  final JsonShape? shape;

  const ParamModel({
    required this.element,
    required this.source,
    required this.key,
    required this.description,
    required this.shape,
  });

  String get name => element.name!;

  DartType get type => element.type;

  bool get isNullable => isNullableType(type);

  /// The source code of the default value, if the parameter declares one.
  String? get defaultValueCode => element.defaultValueCode;

  /// Whether the request must provide the value.
  bool get isRequired => !isNullable && defaultValueCode == null;
}

/// What a controller method returns.
enum ResultKind {
  /// `void`; the response has no body.
  empty,

  /// A shelf `Response` passed through unchanged.
  response,

  /// A value serialized as JSON.
  json,
}

/// A single operation, that is an annotated controller method.
class OperationModel {
  final MethodElement method;
  final String httpMethod;
  final RoutePath path;
  final String operationId;
  final int successStatus;
  final ResultKind resultKind;

  /// The JSON shape of the result when [resultKind] is [ResultKind.json].
  final JsonShape? resultShape;
  final List<ParamModel> params;
  final DocText doc;
  final bool isHidden;
  final bool isDeprecated;

  /// `ApiResponse` annotations of the controller followed by those of the
  /// method.
  final List<DartObject> apiResponses;

  /// Effective `ApiSecurity` annotations; `null` inherits the global setting.
  final List<DartObject>? security;

  /// Source code of the controller and method annotations.
  final List<String> annotationSources;

  const OperationModel({
    required this.method,
    required this.httpMethod,
    required this.path,
    required this.operationId,
    required this.successStatus,
    required this.resultKind,
    required this.resultShape,
    required this.params,
    required this.doc,
    required this.isHidden,
    required this.isDeprecated,
    required this.apiResponses,
    required this.security,
    required this.annotationSources,
  });

  String get name => method.name!;

  /// Whether any parameter is bound from the request, so binding can fail.
  bool get hasInput => params.any((p) => p.source != ParamSource.request);
}

/// A class annotated with `@Controller`.
class ControllerModel {
  final ClassElement element;
  final String? tag;
  final DocText doc;
  final List<OperationModel> operations;

  const ControllerModel({
    required this.element,
    required this.tag,
    required this.doc,
    required this.operations,
  });

  String get name => element.name!;
}
