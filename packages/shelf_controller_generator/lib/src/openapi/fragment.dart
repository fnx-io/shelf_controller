import 'schema_builder.dart';

/// An operation in a per-library fragment, not yet combined with global
/// options.
class FragmentOperation {
  /// The path in OpenAPI syntax.
  final String path;

  /// The lower-case HTTP method.
  final String method;

  /// `Controller.method`, used in error messages.
  final String origin;

  /// Whether binding can fail, so the operation may respond with `400`.
  final bool hasInput;

  /// Codes of responses that use the configured error schema.
  final List<String> errorResponses;

  /// The OpenAPI operation object, without error response content.
  final Map<String, Object?> operation;

  const FragmentOperation({
    required this.path,
    required this.method,
    required this.origin,
    required this.hasInput,
    required this.errorResponses,
    required this.operation,
  });

  factory FragmentOperation.fromJson(Map<String, Object?> json) =>
      FragmentOperation(
        path: json['path']! as String,
        method: json['method']! as String,
        origin: json['origin']! as String,
        hasInput: json['hasInput']! as bool,
        errorResponses: (json['errorResponses']! as List<Object?>)
            .cast<String>(),
        operation: json['operation']! as Map<String, Object?>,
      );

  Map<String, Object?> toJson() => {
    'path': path,
    'method': method,
    'origin': origin,
    'hasInput': hasInput,
    'errorResponses': errorResponses,
    'operation': operation,
  };
}

/// The OpenAPI content contributed by one Dart library.
class ApiFragment {
  final List<FragmentOperation> operations;

  /// Component schemas by name.
  final Map<String, ComponentSchema> schemas;

  /// Tag descriptions by tag name; `null` when the tag has no description.
  final Map<String, String?> tags;

  const ApiFragment({
    required this.operations,
    required this.schemas,
    required this.tags,
  });

  factory ApiFragment.fromJson(Map<String, Object?> json) => ApiFragment(
    operations: [
      for (final operation in json['operations']! as List<Object?>)
        FragmentOperation.fromJson(operation! as Map<String, Object?>),
    ],
    schemas: {
      for (final MapEntry(:key, :value)
          in (json['schemas']! as Map<String, Object?>).entries)
        key: _componentFromJson(value! as Map<String, Object?>),
    },
    tags: (json['tags']! as Map<String, Object?>).cast<String, String?>(),
  );

  Map<String, Object?> toJson() => {
    'operations': [for (final operation in operations) operation.toJson()],
    'schemas': {
      for (final MapEntry(:key, :value) in schemas.entries)
        key: {'source': value.source, 'schema': value.schema},
    },
    'tags': tags,
  };

  static ComponentSchema _componentFromJson(Map<String, Object?> json) =>
      ComponentSchema(json['source']! as String)
        ..schema = json['schema']! as Map<String, Object?>;
}
