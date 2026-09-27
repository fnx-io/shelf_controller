import 'package:analyzer/dart/constant/value.dart';
import 'package:source_gen/source_gen.dart';

import '../dart_object_json.dart';
import '../json_shape.dart';
import '../model/controller_model.dart';
import 'fragment.dart';
import 'http_status.dart';
import 'schema_builder.dart';

/// Describes controller operations as OpenAPI operation objects.
class OperationDescriber {
  final SchemaBuilder _schemas;

  OperationDescriber(this._schemas);

  FragmentOperation describe(
    ControllerModel controller,
    OperationModel operation,
  ) {
    final responses = _responses(operation);
    return FragmentOperation(
      path: operation.path.openApiPath,
      method: operation.httpMethod.toLowerCase(),
      origin: '${controller.name}.${operation.name}',
      hasInput: operation.hasInput,
      errorResponses: [
        for (final MapEntry(:key, :value) in responses.entries)
          if (value.isError) key,
      ],
      operation: {
        if (controller.tag != null) 'tags': [controller.tag],
        'summary': ?operation.doc.summary,
        'description': ?operation.doc.description,
        'operationId': operation.operationId,
        if (_parameters(operation) case final parameters
            when parameters.isNotEmpty)
          'parameters': parameters,
        'requestBody': ?_requestBody(operation),
        'responses': {
          for (final MapEntry(:key, :value) in responses.entries)
            key: value.object,
        },
        if (operation.isDeprecated) 'deprecated': true,
        'security': ?_security(operation.security),
      },
    );
  }

  List<Map<String, Object?>> _parameters(OperationModel operation) {
    final patterns = {
      for (final param in operation.path.params) param.name: param.pattern,
    };
    return [
      for (final param in operation.params)
        if (param.source
            case ParamSource.path || ParamSource.query || ParamSource.header)
          {
            'name': param.key,
            'in': param.source.name,
            'description': ?param.description,
            'required': param.source == ParamSource.path || param.isRequired,
            'schema': _parameterSchema(param, patterns[param.key]),
          },
    ];
  }

  Schema _parameterSchema(ParamModel param, String? routePattern) {
    final defaultValue = param.element.hasDefaultValue
        ? param.element.computeConstantValue()
        : null;
    final schema = _schemas.forInput(param.shape!);
    return _schemas.withApiField({
      ...schema,
      // JSON Schema applies `pattern` to strings only.
      if (routePattern != null && schema['type'] == 'string')
        'pattern': '^$routePattern\$',
      if (defaultValue != null) 'default': dartObjectToJson(defaultValue),
    }, param.element);
  }

  Map<String, Object?>? _requestBody(OperationModel operation) {
    final body = operation.params
        .where((p) => p.source == ParamSource.body)
        .firstOrNull;
    if (body == null) return null;
    return {
      'description': ?body.description,
      'required': body.isRequired,
      'content': _json(
        _schemas.withApiField(_schemas.forInput(body.shape!), body.element),
      ),
    };
  }

  Map<String, _Response> _responses(OperationModel operation) {
    final responses = <int, _Response>{
      operation.successStatus: _successResponse(operation),
    };
    for (final annotation in operation.apiResponses) {
      final response = ConstantReader(annotation);
      final code = response.read('code').intValue;
      final description =
          response.peek('description')?.stringValue ?? reasonPhrase(code);
      final type = response.peek('type')?.typeValue;
      responses[code] = type == null
          ? _Response({'description': description}, isError: code >= 400)
          : _Response({
              'description': description,
              'content': {
                response.peek('contentType')?.stringValue ?? _jsonType: {
                  'schema': _schemas.forValue(classifyJsonType(type)),
                },
              },
            });
    }
    final codes = responses.keys.toList()..sort();
    return {for (final code in codes) '$code': responses[code]!};
  }

  _Response _successResponse(OperationModel operation) {
    final description = reasonPhrase(operation.successStatus);
    final shape = operation.resultShape;
    return _Response({
      'description': description,
      if (shape != null) 'content': _json(_schemas.forValue(shape)),
    });
  }

  static const _jsonType = 'application/json';

  Map<String, Object?> _json(Schema schema) => {
    _jsonType: {'schema': schema},
  };

  List<Map<String, List<String>>>? _security(List<DartObject>? security) {
    if (security == null) return null;
    final requirements = [
      for (final annotation in security)
        if (ConstantReader(annotation).peek('scheme')?.stringValue
            case final scheme?)
          {
            scheme: [
              for (final scope in ConstantReader(
                annotation,
              ).read('scopes').listValue)
                scope.toStringValue()!,
            ],
          }
        else
          <String, List<String>>{},
    ];
    // `ApiSecurity.none()` alone means no security; together with other
    // requirements it makes them optional.
    return requirements.every((r) => r.isEmpty) ? [] : requirements;
  }
}

class _Response {
  final Map<String, Object?> object;
  final bool isError;

  const _Response(this.object, {this.isError = false});
}
