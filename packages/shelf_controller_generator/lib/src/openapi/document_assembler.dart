import 'fragment.dart';
import 'http_status.dart';
import 'openapi_options.dart';
import 'schema_builder.dart';

/// Thrown when fragments cannot be combined into one consistent spec.
class OpenApiAssemblyException implements Exception {
  final String message;

  OpenApiAssemblyException(this.message);

  @override
  String toString() => 'OpenApiAssemblyException: $message';
}

/// Combines library fragments and global options into an OpenAPI 3.1
/// document with a deterministic order of paths, operations and schemas.
class DocumentAssembler {
  static const openApiVersion = '3.1.0';

  // The order of operations within a path item defined by OpenAPI.
  static const _methodOrder = [
    'get', 'put', 'post', 'delete', 'options', 'head', 'patch', 'trace', //
  ];

  final OpenApiOptions _options;

  DocumentAssembler(this._options);

  Map<String, Object?> assemble(List<ApiFragment> fragments) {
    final operations = [for (final f in fragments) ...f.operations];
    _checkUniqueOperations(operations);
    final schemas = _mergeSchemas(fragments);
    final errorSchema = _options.errorSchema;
    final paths = _paths(operations);
    final usesErrorSchema =
        errorSchema != null &&
        operations.any((o) => o.hasInput || o.errorResponses.isNotEmpty);
    if (usesErrorSchema) {
      _addErrorSchema(schemas, errorSchema);
    }
    _checkSecuritySchemes(operations);
    final tags = _tags(fragments);
    final sortedSchemas = schemas.keys.toList()..sort();
    return {
      'openapi': openApiVersion,
      'info': _options.info,
      'servers': ?_options.servers,
      'security': ?_options.security,
      if (tags.isNotEmpty) 'tags': tags,
      'paths': paths,
      if (sortedSchemas.isNotEmpty || _options.securitySchemes != null)
        'components': {
          if (sortedSchemas.isNotEmpty)
            'schemas': {
              for (final name in sortedSchemas) name: schemas[name]!.schema,
            },
          'securitySchemes': ?_options.securitySchemes,
        },
    };
  }

  void _checkUniqueOperations(List<FragmentOperation> operations) {
    final routes = <String, String>{};
    final ids = <String, String>{};
    for (final operation in operations) {
      final route = '${operation.method.toUpperCase()} ${operation.path}';
      final id = operation.operation['operationId']! as String;
      if (routes[route] case final other?) {
        throw OpenApiAssemblyException(
          'Route $route is declared by both $other and ${operation.origin}.',
        );
      }
      if (ids[id] case final other?) {
        throw OpenApiAssemblyException(
          'operationId `$id` is used by both $other and ${operation.origin}; '
          'set a unique operationId in the HTTP method annotation.',
        );
      }
      routes[route] = operation.origin;
      ids[id] = operation.origin;
    }
  }

  Map<String, ComponentSchema> _mergeSchemas(List<ApiFragment> fragments) {
    final merged = <String, ComponentSchema>{};
    for (final fragment in fragments) {
      for (final MapEntry(key: name, value: schema)
          in fragment.schemas.entries) {
        final existing = merged[name];
        if (existing != null && existing.source != schema.source) {
          throw OpenApiAssemblyException(
            'Two classes map to the schema `$name`: ${existing.source} and '
            '${schema.source}. Rename one of them with @ApiSchema(name: ...).',
          );
        }
        merged[name] = schema;
      }
    }
    return merged;
  }

  void _addErrorSchema(
    Map<String, ComponentSchema> schemas,
    ErrorSchema error,
  ) {
    if (schemas.containsKey(error.name)) {
      throw OpenApiAssemblyException(
        'The error schema `${error.name}` collides with a DTO of the same name.',
      );
    }
    schemas[error.name] = ComponentSchema('error schema')
      ..schema = error.schema;
  }

  Map<String, Object?> _paths(List<FragmentOperation> operations) {
    final byPath = <String, Map<String, FragmentOperation>>{};
    for (final operation in operations) {
      (byPath[operation.path] ??= {})[operation.method] = operation;
    }
    final sortedPaths = byPath.keys.toList()..sort();
    return {
      for (final path in sortedPaths)
        path: {
          for (final method in _methodOrder)
            if (byPath[path]![method] case final operation?)
              method: _finalize(operation),
        },
    };
  }

  /// Adds the error schema to error responses and the automatic `400`.
  Map<String, Object?> _finalize(FragmentOperation operation) {
    final error = _options.errorSchema;
    final responses = Map<String, Object?>.of(
      operation.operation['responses']! as Map<String, Object?>,
    );
    if (error != null) {
      final content = {
        error.contentType: {
          'schema': {r'$ref': '#/components/schemas/${error.name}'},
        },
      };
      for (final code in operation.errorResponses) {
        responses[code] = {
          ...responses[code]! as Map<String, Object?>,
          'content': content,
        };
      }
      if (operation.hasInput && !responses.containsKey('400')) {
        responses['400'] = {
          'description': reasonPhrase(400),
          'content': content,
        };
      }
    }
    final codes = responses.keys.toList()..sort();
    return {
      for (final MapEntry(:key, :value) in operation.operation.entries)
        key: key == 'responses'
            ? {for (final code in codes) code: responses[code]}
            : value,
    };
  }

  void _checkSecuritySchemes(List<FragmentOperation> operations) {
    final defined = _options.securitySchemes?.keys.toSet() ?? const <String>{};
    final requirements = [
      ...?_options.security,
      for (final operation in operations)
        ...?operation.operation['security'] as List<Object?>?,
    ];
    for (final requirement in requirements.whereType<Map<Object?, Object?>>()) {
      for (final scheme in requirement.keys) {
        if (!defined.contains(scheme)) {
          throw OpenApiAssemblyException(
            'Security scheme `$scheme` is not defined in the securitySchemes '
            'option of shelf_controller_generator.',
          );
        }
      }
    }
  }

  List<Map<String, Object?>> _tags(List<ApiFragment> fragments) {
    final descriptions = <String, String?>{};
    for (final fragment in fragments) {
      for (final MapEntry(:key, :value) in fragment.tags.entries) {
        descriptions[key] = descriptions[key] ?? value;
      }
    }
    final names = descriptions.keys.toList()..sort();
    return [
      for (final name in names)
        {'name': name, 'description': ?descriptions[name]},
    ];
  }
}
