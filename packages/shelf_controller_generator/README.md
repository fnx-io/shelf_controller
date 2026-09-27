# shelf_controller_generator

The `build_runner` builders of [shelf_controller](https://github.com/fnx-io/shelf_controller/tree/master/packages/shelf_controller). From
typed shelf controllers they generate:

- a `<Controller>Router` class per controller, in the `.g.dart` part shared
  with json_serializable, which binds requests to method arguments and
  serializes results, and
- a single `openapi.yaml` in [OpenAPI 3.1](https://spec.openapis.org/oas/v3.1.0)
  describing all operations and the schemas of their DTOs.

Both outputs come from the same method signatures, so the spec always matches
what the server does. See the [shelf_controller README](https://github.com/fnx-io/shelf_controller/tree/master/packages/shelf_controller)
for writing controllers; this page covers the generated spec.

## Setup

Add the generator next to `build_runner` and `json_serializable`:

```yaml
dev_dependencies:
  build_runner: ^2.16.0
  json_serializable: ^6.14.0
  shelf_controller_generator:
    git:
      url: https://github.com/fnx-io/shelf_controller.git
      path: packages/shelf_controller_generator
      ref: master # or a tag
```

Then run:

```sh
dart run build_runner build
```

The generator has no dependency on `json_annotation`; it recognizes its
annotations by URL, so it does not constrain your json_serializable version.

## Configuration

Global parts of the spec come from the `build.yaml` of the application:

```yaml
targets:
  $default:
    builders:
      shelf_controller_generator:
        options:
          output: openapi.yaml          # default
          info:
            title: Projects API
            version: 1.0.0
          servers:
            - url: https://api.example.com
          securitySchemes:
            bearer: { type: http, scheme: bearer, bearerFormat: JWT }
          security: [ { bearer: [] } ]  # default for all operations
          problemDetails: true          # default
```

| Option | Meaning |
| --- | --- |
| `output` | Path of the spec relative to the package root |
| `info`, `servers`, `securitySchemes`, `security` | Copied into the spec as they are |
| `problemDetails` | Adds a `400` response to every operation with parameters or a body, and uses the RFC 9457 `ProblemDetails` schema for `@ApiResponse` without a `type` |
| `errorSchema` | Replaces `ProblemDetails` when the application has its own exception mapper: `{name: ApiError, contentType: application/json, schema: {...}}` |

Unknown options fail the build, so typos do not go unnoticed. Every security
scheme referenced by `@ApiSecurity` or `security` must be defined in
`securitySchemes`.

Global json_serializable options such as `field_rename` are read from the same
`build.yaml`, so the schemas use the property names json_serializable really
writes.

Serving the spec and a UI (Swagger UI, Scalar, Redoc) is up to the
application, for example with `shelf_static`.

## Type mapping

| Dart type | OpenAPI 3.1 schema |
| --- | --- |
| `String` | `type: string` |
| `int` | `type: integer`, `format: int64` |
| `double` | `type: number`, `format: double` |
| `num` | `type: number` |
| `bool` | `type: boolean` |
| `DateTime` | `type: string`, `format: date-time` |
| `Uri` | `type: string`, `format: uri` |
| `enum` | `type: string` (or `integer`) with `enum` values as json_serializable writes them (`@JsonValue`, `@JsonEnum(fieldRename:, valueField:)`) |
| `List<T>`, `Set<T>` | `type: array`, `items: T`; sets add `uniqueItems: true` |
| `Map<String, T>` | `type: object`, `additionalProperties: T` |
| `T?` | `type: [T, 'null']`, or `oneOf: [T, {type: 'null'}]` around a `$ref` |
| class with `fromJson`/`toJson` | `$ref: '#/components/schemas/<Class>'` |
| `dynamic`, `Object?` | `{}`, any value |

Parameters and request bodies express optionality through `required`, so
their schemas are not nullable. Enums outside DTOs (parameters, top-level
bodies and results) are bound by the Dart name of the constant, and their
schema lists those names.

## DTO rules

For classes annotated with `@JsonSerializable` the schema follows what
json_serializable generates:

- Property names follow `@JsonKey(name:)`, the class `fieldRename` and the
  global `field_rename`.
- Inherited fields come first, then fields in declaration order.
- A field read by `fromJson` only is `writeOnly`; a field written by `toJson`
  only (`includeFromJson: false, includeToJson: true`, or a getter with
  `includeToJson: true`) is `readOnly`. Fields in neither are omitted.
- `required` lists the non-nullable fields without a default value, plus
  fields with `@JsonKey(required: true)`. `@JsonKey(defaultValue:)` and
  constructor defaults become `default`.
- The doc comment of a field is its `description`; `@ApiField` adds
  constraints and an example.

The build fails instead of guessing when:

- a body type has no `fromJson` or a result type has no `toJson()`,
- a DTO is not annotated with `@JsonSerializable` (a hand-written `toJson`),
- a field uses a `JsonConverter` or `@JsonKey(fromJson:/toJson:)`,
- a type has no JSON mapping (`Duration`, records, generic DTOs),
- two different classes map to the same schema name.

Describe such types with `@ApiSchema(schema: {...})` on the class or field, and
resolve name clashes with `@ApiSchema(name: ...)`:

```dart
@ApiSchema(schema: {'type': 'string', 'example': '100 CZK'})
class Money {
  factory Money.fromJson(String json) => ...;
  String toJson() => '$amount $currency';
}
```

### Sealed hierarchies

A `sealed` class with `@ApiDiscriminator` becomes a `oneOf` of its subtypes
with a discriminator. Each subtype schema gets the discriminator property
unless it declares it itself. The values come from `mapping`, defaulting to
the schema name of the subtype:

```dart
@ApiDiscriminator('type', mapping: {'link': LinkAttachment, 'note': NoteAttachment})
sealed class Attachment {
  factory Attachment.fromJson(Map<String, dynamic> json) => switch (json['type']) {
    'link' => LinkAttachment.fromJson(json),
    'note' => NoteAttachment.fromJson(json),
    final type => throw FormatException('Unknown attachment type: $type'),
  };
  Map<String, dynamic> toJson();
}
```

Deserialization by the discriminator is written by hand in `fromJson` of the
base class, as shown.

## Output

The build writes one `openapi.yaml` in two steps: each library with
controllers produces an `.openapi.json` fragment in the build cache, and an
aggregating builder merges them into the spec. The output is deterministic:
paths, operations, responses and schemas are sorted and the key order is
fixed, so a diff of the spec in a code review shows only real changes of the
contract.

API versions are part of the controller path (`/api/v1/projects`); all
versions go into one spec, with `operationId` kept unique across them.

Commit `openapi.yaml` and let CI verify it is up to date:

```sh
dart run build_runner build
git diff --exit-code openapi.yaml
```

The build then fails whenever the committed spec does not match the code, so
every contract change is visible in review.

## AI coding agents

The repository ships an [agent skill](https://github.com/fnx-io/shelf_controller/tree/master/skills/shelf-controller)
that teaches AI coding agents to use shelf_controller correctly. Install it
with `apm install fnx-io/shelf_controller/skills/shelf-controller`, or copy
the directory into your agent's skills folder.

## Testing

The generator is covered by golden tests: every directory in
[`test/goldens`](https://github.com/fnx-io/shelf_controller/tree/master/packages/shelf_controller_generator/test/goldens) holds an input library with the expected
`.g.dart` and `openapi.yaml`, including one case per row of the type mapping
table. After an intended change, regenerate them with:

```sh
UPDATE_GOLDENS=1 dart test test/golden_test.dart
```

All generated specs are validated with [Redocly CLI](https://redocly.com/docs/cli/)
when `npx` is available.
