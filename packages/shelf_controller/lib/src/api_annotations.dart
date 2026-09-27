/// Annotations that only affect the generated OpenAPI spec.
///
/// None of them has any effect at runtime.
library;

/// Documents an additional response of an operation, typically an error.
///
/// On a controller class it applies to every operation of the controller;
/// an annotation on the method with the same [code] takes precedence.
///
/// Without a [type], the response uses the configured error schema
/// (RFC 9457 Problem Details by default).
class ApiResponse {
  /// The HTTP status code of the response.
  final int code;

  /// The Dart type of the response body, for example `ProjectDto` or
  /// `List<ProjectDto>`.
  final Type? type;

  /// The description of the response; defaults to the reason phrase.
  final String? description;

  /// The media type of a response with a [type]; defaults to
  /// `application/json`.
  ///
  /// Useful for operations returning a plain `Response`, such as a CSV
  /// export documented with `type: String`.
  final String? contentType;

  /// Creates a documented response.
  const ApiResponse(this.code, {this.type, this.description, this.contentType});
}

/// Declares a security requirement of an operation in the OpenAPI spec.
///
/// Several annotations on the same element are alternatives, any one of them
/// satisfies the requirement. A method annotation replaces the annotations of
/// the controller class, which in turn replace the global `security` option.
class ApiSecurity {
  /// The name of the security scheme from the `securitySchemes` option, or
  /// `null` for [ApiSecurity.none].
  final String? scheme;

  /// The scopes required by the scheme.
  final List<String> scopes;

  /// Creates a requirement of the security [scheme].
  const ApiSecurity(String this.scheme, {this.scopes = const []});

  /// Marks the operation as public, overriding any inherited requirement.
  const ApiSecurity.none() : scheme = null, scopes = const [];
}

/// Excludes an operation or a whole controller from the OpenAPI spec.
///
/// The operation is still part of the generated router.
class ApiHidden {
  /// Creates the annotation.
  const ApiHidden();
}

/// Overrides the schema generated for a class, an enum or a field.
///
/// Use [name] to resolve two classes with the same name, and [schema] to
/// describe JSON the generator cannot infer, such as a custom `toJson` or a
/// `JsonConverter`.
///
/// ```dart
/// @ApiSchema(schema: {'type': 'string', 'format': 'money'})
/// class Money { ... }
/// ```
class ApiSchema {
  /// The name of the schema in `components/schemas`.
  final String? name;

  /// The literal JSON schema used instead of the generated one.
  final Map<String, Object?>? schema;

  /// Creates a schema override.
  const ApiSchema({this.name, this.schema});
}

/// Describes a `sealed` class hierarchy as a `oneOf` schema with a
/// discriminator.
///
/// The [mapping] assigns discriminator values to subtypes; subtypes missing
/// from it use their schema name. The generator documents the shape only,
/// the base class still has to implement `fromJson` itself.
///
/// ```dart
/// @ApiDiscriminator('type', mapping: {'circle': Circle, 'square': Square})
/// sealed class Shape { ... }
/// ```
class ApiDiscriminator {
  /// The name of the JSON property holding the discriminator value.
  final String propertyName;

  /// Discriminator values of the subtypes.
  final Map<String, Type> mapping;

  /// Creates a discriminator on [propertyName].
  const ApiDiscriminator(this.propertyName, {this.mapping = const {}});
}

/// Adds constraints and an example to the schema of a field or a parameter.
///
/// The annotation is purely documentary, nothing is validated at runtime.
class ApiField {
  /// The minimum length of a string.
  final int? minLength;

  /// The maximum length of a string.
  final int? maxLength;

  /// The regular expression a string must match.
  final String? pattern;

  /// The inclusive minimum of a number.
  final num? minimum;

  /// The inclusive maximum of a number.
  final num? maximum;

  /// An example value.
  final Object? example;

  /// Creates field constraints.
  const ApiField({
    this.minLength,
    this.maxLength,
    this.pattern,
    this.minimum,
    this.maximum,
    this.example,
  });
}
