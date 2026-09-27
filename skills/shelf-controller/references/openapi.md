# OpenAPI generation reference

Contents: how the spec is built · build.yaml options · type mapping · DTO
rules · sealed hierarchies · build error messages.

## How the spec is built

1. For every library under `lib/` and `bin/` with `@Controller` classes, the
   builder `shelf_controller_generator:openapi_fragment` writes an
   `.openapi.json` fragment into the build cache.
2. The builder `shelf_controller_generator` (input `$package$`) merges all
   fragments into `openapi.yaml` in the package root (OpenAPI 3.1.0).

The output is deterministic: paths sorted, operations in OpenAPI method
order, responses sorted by code, schemas sorted by name, fixed key order.
`@ApiHidden` operations and controllers are omitted; a controller's tag and
its doc comment (as tag description) appear only if it has visible
operations.

Operation content: `tags` from `@Controller(tag:)`, `summary`/`description`
from the doc comment, `operationId`, `parameters` (path parameters always
`required: true`; others required when non-nullable without default;
`default` from the Dart default; a `<id|regex>` becomes `pattern` on string
schemas), `requestBody` (`required` unless nullable/defaulted), `responses`,
`deprecated`, `security`.

## build.yaml options

Builder key `shelf_controller_generator` under
`targets.$default.builders.<key>.options`. Unknown keys fail the build.

| Option | Default | Effect |
| --- | --- | --- |
| `output` | `openapi.yaml` | Path relative to the package root |
| `info` | `{title: API, version: 1.0.0}` | Copied verbatim |
| `servers` | — | Copied verbatim |
| `securitySchemes` | — | Copied into `components.securitySchemes`; every scheme referenced by `security` or `@ApiSecurity` must be here |
| `security` | — | Default requirement of all operations |
| `problemDetails` | `true` | Adds `400` to operations with bound inputs and uses the `ProblemDetails` schema (`application/problem+json`) for untyped `@ApiResponse` |
| `errorSchema` | — | `{name, schema, contentType: application/json}`; replaces `ProblemDetails` for apps with their own exception mapper |

With `problemDetails: false` and no `errorSchema`, untyped error responses
have no content and no `400` is added.

The fragment builder reads json_serializable's global `field_rename` from the
app's `build.yaml` (keys `json_serializable` or
`json_serializable:json_serializable`), so property names match.

## Type mapping

| Dart | Schema |
| --- | --- |
| `String` | `type: string` |
| `int` | `type: integer, format: int64` |
| `double` | `type: number, format: double` |
| `num` | `type: number` |
| `bool` | `type: boolean` |
| `DateTime` | `type: string, format: date-time` |
| `Uri` | `type: string, format: uri` |
| enum in a DTO | `type: string` (or `integer` if all values are ints) with the json_serializable values (`@JsonValue`, `@JsonEnum(fieldRename:, valueField:)`) |
| enum as parameter / top-level body / result | Dart constant names |
| `List<T>` / `Set<T>` | `type: array, items`; sets add `uniqueItems: true` |
| `Map<String, T>` | `type: object, additionalProperties` |
| `T?` in DTOs and results | `type: [T, 'null']` (enum gets `null` too); `$ref` → `oneOf: [$ref, {type: 'null'}]` |
| `T?` parameter or body | not nullable; `required: false` expresses it |
| class | `$ref: '#/components/schemas/<Name>'` |
| `dynamic`, `Object`, `Object?` | `{}` |

Not mappable (build error): records, functions, `Duration`, `BigInt`, other
SDK classes, maps with non-`String` keys, generic classes.

## DTO rules

A class referenced from a signature (and transitively from DTO fields) needs
`@JsonSerializable`, `@ApiDiscriminator` (sealed base) or
`@ApiSchema(schema:)`. For `@JsonSerializable` classes:

- Fields: instance fields of the class and its superclasses/mixins,
  superclass fields first, then declaration order. Getters only with
  `@JsonKey(includeToJson: true)`. Private fields only with
  `includeFromJson: true`. `@JsonKey(ignore: true)` and
  `ignoreUnannotated` are honored.
- A field is read by `fromJson` when it is a constructor parameter (of the
  `constructor:` option's constructor) or has a setter; `toJson` writes those
  plus explicit `includeToJson: true`, minus `includeToJson: false`.
  `includeFromJson: false` alone drops the field from **both**, exactly as
  json_serializable does.
- Only-read fields → `writeOnly: true`; only-written → `readOnly: true`
  (only when the class generates both directions).
- Name: `@JsonKey(name:)` → class `fieldRename` → global `field_rename`.
- `required`: non-nullable (and not `dynamic`) without a default, or
  `@JsonKey(required: true)`. `default` from `@JsonKey(defaultValue:)` or the
  constructor parameter default.
- Field doc comment → `description`; `@ApiField` → constraints/example;
  field-level `@ApiSchema(schema:)` replaces the field schema.
- Class doc comment → schema `description`.

## Sealed hierarchies

`@ApiDiscriminator('type', mapping: {'link': LinkAttachment})` on a `sealed`
base class produces `oneOf` over the direct subclasses declared in the same
library plus `discriminator.propertyName`/`mapping`. Subtypes without a
`mapping` entry use their schema name as the value. Each subtype schema gets
the property `{type: string, enum: [value]}` (required) unless it declares a
field with that JSON name. The base class must still implement `fromJson`
(switch on the property) and each subtype's `toJson` must write the property;
the generator only documents it.

## Build error messages

| Message (prefix) | Fix |
| --- | --- |
| `Operations must be public instance methods.` | Remove `static`/leading `_` |
| `Parameter \`x\` has more than one binding annotation.` | Keep one of `@Path/@Query/@Header/@Body` |
| `Parameter \`x\` needs @Path, @Query, @Header or @Body.` | Annotate, or type it `Request` |
| `Type \`T\` cannot be bound from the path/query/header.` | Scalar or enum (query also `List`); path non-nullable |
| `Path parameters of \`/p\` do not match the method: missing @Path for a; no segment for b.` | Align `<a>` with `@Path` names |
| `An operation can have only one @Body parameter.` | Merge into one DTO |
| `Route \`GET /p\` is declared more than once.` | Two methods map to the same method+path in one controller |
| `Route GET /p is declared by both A.x and B.y.` | Same, across controllers |
| `operationId \`x\` is used by both A.x and B.x` | `@Get('/', operationId: 'unique')` |
| `Unsupported type \`T\`: \`C\` has no \`fromJson\` constructor` | Add `factory C.fromJson(...)` (or a static `fromJson`) |
| `Unsupported type \`T\`: \`C\` has no \`toJson()\` method` | Add a `toJson()` without required parameters |
| `Unsupported type \`T\`: only \`String\` map keys are supported` | Use `Map<String, V>` |
| `Unsupported type \`T\`: it has no JSON representation` | Change the type, or wrap it in a DTO |
| `Cannot infer the JSON schema of \`C\`: it is not annotated with @JsonSerializable.` | Add `@JsonSerializable` or `@ApiSchema(schema: {...})` |
| `Cannot infer the JSON schema of \`C\`: only non-generic classes are supported.` | `@ApiSchema(schema:)` on the class, or a non-generic DTO per type argument |
| `Cannot infer the JSON schema of \`C.f\`: it uses a JsonConverter.` / `a JsonConverter of the class applies to it` / `it uses JsonKey fromJson/toJson functions` | `@ApiSchema(schema: {...})` on the field |
| `Field \`C.f\`: Unsupported type ...` | Change the field type or add field `@ApiSchema(schema:)` |
| `Two classes map to the schema \`N\`` | `@ApiSchema(name: 'Other')` on one class |
| `\`C\` has @ApiDiscriminator but no subtypes in its library.` | Declare subclasses in the same library |
| `The error schema \`N\` collides with a DTO of the same name.` | Rename `errorSchema.name` or the DTO |
| `Security scheme \`s\` is not defined in the securitySchemes option` | Define it in `build.yaml` |
| `Unknown shelf_controller_generator options: k.` | Fix the key (supported: output, info, servers, securitySchemes, security, problemDetails, errorSchema) |
| `\`T\` is not visible in package:...` | Import the type's library into the controller library |
