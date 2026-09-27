import 'package:build/build.dart';

/// The error schema used by untyped error responses and the automatic `400`.
class ErrorSchema {
  /// The name in `components/schemas`.
  final String name;

  /// The media type of error responses.
  final String contentType;

  /// The JSON schema.
  final Map<String, Object?> schema;

  const ErrorSchema({
    required this.name,
    required this.contentType,
    required this.schema,
  });

  /// RFC 9457 Problem Details as produced by `problemDetailsMapper`.
  static const problemDetails = ErrorSchema(
    name: 'ProblemDetails',
    contentType: 'application/problem+json',
    schema: {
      'type': 'object',
      'description': 'Problem Details for HTTP APIs (RFC 9457).',
      'properties': {
        'type': {
          'type': 'string',
          'format': 'uri-reference',
          'default': 'about:blank',
        },
        'title': {'type': 'string'},
        'status': {'type': 'integer', 'format': 'int32'},
        'detail': {'type': 'string'},
        'instance': {'type': 'string', 'format': 'uri-reference'},
      },
    },
  );
}

/// Options of the `shelf_controller_generator` builder from `build.yaml`.
class OpenApiOptions {
  /// The path of the generated spec, relative to the package root.
  final String output;
  final Map<String, Object?> info;
  final List<Object?>? servers;
  final Map<String, Object?>? securitySchemes;

  /// The default security requirements of all operations.
  final List<Object?>? security;

  /// The schema of error responses, or `null` to leave them without content.
  final ErrorSchema? errorSchema;

  const OpenApiOptions({
    this.output = 'openapi.yaml',
    this.info = const {'title': 'API', 'version': '1.0.0'},
    this.servers,
    this.securitySchemes,
    this.security,
    this.errorSchema = ErrorSchema.problemDetails,
  });

  static const _knownKeys = {
    'output',
    'info',
    'servers',
    'securitySchemes',
    'security',
    'problemDetails',
    'errorSchema',
  };

  factory OpenApiOptions.fromConfig(Map<String, Object?> config) {
    final unknown = config.keys.toSet().difference(_knownKeys);
    if (unknown.isNotEmpty) {
      throw ArgumentError(
        'Unknown shelf_controller_generator options: ${unknown.join(', ')}. '
        'Supported: ${_knownKeys.join(', ')}.',
      );
    }
    return OpenApiOptions(
      output: config['output'] as String? ?? 'openapi.yaml',
      info: _map(config['info']) ?? const {'title': 'API', 'version': '1.0.0'},
      servers: _plain(config['servers']) as List<Object?>?,
      securitySchemes: _map(config['securitySchemes']),
      security: _plain(config['security']) as List<Object?>?,
      errorSchema: _errorSchema(config),
    );
  }

  factory OpenApiOptions.fromBuilderOptions(BuilderOptions options) =>
      OpenApiOptions.fromConfig(options.config);

  static ErrorSchema? _errorSchema(Map<String, Object?> config) {
    final custom = _map(config['errorSchema']);
    if (custom != null) {
      return ErrorSchema(
        name: custom['name'] as String? ?? 'Error',
        contentType: custom['contentType'] as String? ?? 'application/json',
        schema:
            _map(custom['schema']) ??
            (throw ArgumentError('errorSchema.schema is required')),
      );
    }
    final problemDetails = config['problemDetails'] as bool? ?? true;
    return problemDetails ? ErrorSchema.problemDetails : null;
  }

  /// Converts YAML maps to maps with string keys.
  static Map<String, Object?>? _map(Object? value) =>
      value == null ? null : _plain(value) as Map<String, Object?>;

  static Object? _plain(Object? value) => switch (value) {
    Map() => {
      for (final MapEntry(:key, :value) in value.entries) '$key': _plain(value),
    },
    List() => [for (final item in value) _plain(item)],
    _ => value,
  };
}
