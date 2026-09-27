# shelf_controller

Typed controllers for [shelf](https://pub.dev/packages/shelf), with the router
and an OpenAPI 3.1 spec generated at build time.

You write a plain class with annotated methods and typed parameters:

```dart
@Controller('/api/projects', tag: 'Projects')
class ProjectsController {
  ProjectsController(this._projects);
  final ProjectService _projects;

  /// Creates a project.
  @Post('/')
  @Status(201)
  @ApiResponse(409, description: 'A project with this code already exists')
  Future<ProjectDto> create(@Body() CreateProjectDto body) =>
      _projects.create(body);

  /// Returns a project.
  @Get('/<id>')
  @ApiResponse(404)
  Future<ProjectDto> detail(@Path() String id, @Query() bool? withMembers) =>
      _projects.detail(id, withMembers: withMembers ?? false);
}
```

[`shelf_controller_generator`](https://github.com/fnx-io/shelf_controller/tree/master/packages/shelf_controller_generator) then generates,
from the very same signatures:

- a `ProjectsControllerRouter` binding path, query, header and JSON body values
  to the typed arguments and serializing the result, and
- an `openapi.yaml` describing exactly these operations and DTOs.

Because both come from one source, the spec and the behavior cannot drift
apart. Everything happens at compile time, without reflection, so it works in
AOT-compiled servers. The approach is inspired by Micronaut and
micronaut-openapi.

This package holds the annotations and the small runtime the generated code
calls. The generator is a dev dependency only.

## Contents

- [Installation](#installation)
- [Controllers and operations](#controllers-and-operations)
- [Binding parameters](#binding-parameters)
- [Results](#results)
- [Wiring it up](#wiring-it-up)
- [Errors](#errors)
- [Extension points](#extension-points)
- [OpenAPI annotations](#openapi-annotations)
- [What is out of scope](#what-is-out-of-scope)

## Installation

The packages are distributed from GitHub until they are published on pub.dev.
Pin them to a tag or a commit:

```yaml
dependencies:
  shelf_controller:
    git:
      url: https://github.com/fnx-io/shelf_controller.git
      path: packages/shelf_controller
      ref: master # or a tag, for example v0.1.0
  json_annotation: ^4.12.0

dev_dependencies:
  build_runner: ^2.16.0
  json_serializable: ^6.14.0
  shelf_controller_generator:
    git:
      url: https://github.com/fnx-io/shelf_controller.git
      path: packages/shelf_controller_generator
      ref: master
```

Requires Dart 3.11 or newer.

## Controllers and operations

A controller is an ordinary class annotated with `@Controller`. Its library
declares a part file shared with json_serializable:

```dart
import 'package:shelf_controller/shelf_controller.dart';

part 'projects_controller.g.dart';
```

Importing `package:shelf_controller/shelf_controller.dart` is enough; it also
exports the shelf types used by the generated code (`Request`, `Response`,
`Handler`, `Middleware`, `Router`).

| Annotation | Target | Meaning |
| --- | --- | --- |
| `@Controller(path, tag:)` | class | Path prefix and default OpenAPI tag of all operations |
| `@Get`, `@Post`, `@Put`, `@Patch`, `@Delete(path, operationId:)` | method | HTTP method and path in `shelf_router` syntax (`<id>`, `<id\|[0-9]+>`); `operationId` defaults to the method name |
| `@Status(code)` | method | Status of a successful response; defaults to `200`, or `204` for `void` |

The full path is the controller path joined with the operation path, without
a trailing slash: `@Controller('/api/projects')` with `@Post('/')` maps to
`POST /api/projects`.

The first paragraph of a method's doc comment becomes the OpenAPI `summary`,
the rest its `description`. The doc comment of the controller describes its
tag.

## Binding parameters

Every parameter needs exactly one binding annotation, except a parameter of
type `Request`, which receives the shelf request itself.

| Annotation | Source | Supported types |
| --- | --- | --- |
| `@Path([name])` | path segment, percent-decoded | `String`, `int`, `double`, `num`, `bool`, `DateTime`, `Uri`, `enum` (non-nullable) |
| `@Query([name])` | query parameter | the same, nullable, and `List<T>` for repeated parameters (`?tag=a&tag=b`) |
| `@Header(name)` | request header, case-insensitive | the same scalars, nullable |
| `@Body()` | JSON body | a class with `fromJson`, `List<T>`, `Set<T>`, `Map<String, T>`, JSON primitives, `dynamic` |

- The name defaults to the parameter name: `@Query() int page` reads `?page=`.
- A nullable type makes the value optional; otherwise it is required.
- A default value also makes it optional: `@Query() int limit = 20`.
- `DateTime` is parsed as ISO 8601, `bool` accepts `true` and `false`, and an
  `enum` is bound by the name of its constant.
- An empty body counts as absent, so `@Body() Dto? body` receives `null`.

Binding failures (a missing value, a malformed number, invalid JSON, a
`fromJson` that throws) raise a `BindingException` naming the parameter, its
source and the reason, which responds with `400 Bad Request`.

## Results

| Return type | Response |
| --- | --- |
| `void`, `Future<void>` | empty, `204` unless `@Status` says otherwise |
| a class with `toJson`, `List`/`Set`/`Map<String, T>` of it, JSON primitives, `DateTime`, enums | JSON with `Content-Type: application/json; charset=utf-8` |
| `Response`, `Future<Response>` | passed through unchanged; document it with `@ApiResponse` |

Returning a shelf `Response` and taking a `Request` parameter is the escape
hatch for anything the binding does not cover, such as multipart uploads,
file downloads or streaming.

## Wiring it up

The application creates the controller; the library has no dependency
injection. The generated router takes the instance and uses it for all
requests, so the controller is a singleton per isolate and must not keep
request state in fields.

```dart
final projects = ProjectsControllerRouter(
  ProjectsController(projectService),
  middleware: [authorize()],
  interceptors: [ValidationInterceptor()],
);

final app = Router()
  ..mount('/', projects.handler)
  ..mount('/', usersRouter.handler);

await shelf_io.serve(app.call, 'localhost', 8080);
```

Paths are complete in `@Controller`, so routers are mounted at `/`. Mounted
routers fall through to each other when a path does not match.

When the controller needs something from the current request, for example the
user put into the context by an authentication middleware, create it per
request:

```dart
MeControllerRouter.perRequest(
  (request) => MeController(currentUser: userOf(request)),
  middleware: [authenticate()],
)
```

The factory runs for every request, after the route middleware and right
before binding, so it sees whatever the middleware stored in the context.

Every generated router also exposes the metadata of its operations as
`static const routes`.

## Errors

The generated router catches exceptions from route middleware, binding,
interceptors and the controller method and passes them to an
`ExceptionMapper`:

```dart
typedef ExceptionMapper = FutureOr<Response> Function(
    Object error, StackTrace stackTrace, Request request);
```

The default `problemDetailsMapper` responds with
[RFC 9457](https://www.rfc-editor.org/rfc/rfc9457) Problem Details
(`Content-Type: application/problem+json`):

- `HttpProblem(status, title:, detail:, type:)` responds with its status.
  Throw it directly or extend it:

  ```dart
  class ProjectNotFound extends HttpProblem {
    ProjectNotFound(String id) : super(404, detail: 'Project $id does not exist');
  }
  ```

- `BindingException` is an `HttpProblem` with status `400`.
- Anything else responds with `500` without revealing the exception, which is
  logged to the `shelf_controller` logger of `package:logging`.

A custom mapper replaces the default and can delegate what it does not handle:

```dart
ProjectsControllerRouter(
  controller,
  exceptionMapper: (error, stack, request) => switch (error) {
    DatabaseUnavailable() => Response(503),
    _ => problemDetailsMapper(error, stack, request),
  },
)
```

## Extension points

Authorization, validation, auditing and similar concerns belong to the
application. It adds them through two hooks, both of which see the metadata
of the operation, including annotations the library knows nothing about.

### RouteInfo

Annotations are `const` expressions, so the generator copies them into a
`RouteInfo` constant of each operation. `RouteInfo.of(request)` returns it:

```dart
class RouteInfo {
  final String operationId, method, path;
  final Type controller;
  final String handler;            // method name
  final List<Object> annotations;  // controller annotations, then method annotations
  final List<ParamInfo> params;    // name, key, source, type and annotations

  static RouteInfo? of(Request request);
  Iterable<T> annotationsOf<T>();
}
```

A custom annotation only needs a `const` constructor:

```dart
class Secured {
  final List<String> roles;
  const Secured(this.roles);
}
```

### Middleware

Middleware passed to the router are ordinary shelf `Middleware`. They run
after the operation is matched and before binding, so they see the
`RouteInfo` and headers but not the typed arguments. The first one is the
outermost. They are the place for authorization:

```dart
Middleware authorize() => (inner) => (request) {
  final required = RouteInfo.of(request)!
      .annotationsOf<Secured>()
      .expand((s) => s.roles)
      .toSet();
  if (required.isNotEmpty && !userOf(request).roles.any(required.contains)) {
    throw HttpProblem(403);
  }
  return inner(request);
};
```

Global middleware applied in front of the routers (logging, CORS) does not
see `RouteInfo`, because the operation is not known yet.

### Interceptors

Interceptors run after binding, right around the controller method, with the
parsed arguments in declaration order. They are the place for validation.
An interceptor may throw, wrap the call (timing, auditing) or transform the
result, but it cannot replace the arguments. The first one is the outermost.

```dart
class ValidationInterceptor implements OperationInterceptor {
  @override
  Future<Object?> intercept(
    RouteInfo route,
    List<Object?> args,
    Future<Object?> Function() proceed,
  ) {
    for (final arg in args) {
      if (arg is Validatable) arg.validate(); // throws HttpProblem(422)
    }
    return proceed();
  }
}
```

The order of one request is: routing, `RouteInfo` in the context, route
middleware, per-request factory, binding, interceptors, controller method,
serialization.

## OpenAPI annotations

These annotations only affect the generated spec; see
[shelf_controller_generator](https://github.com/fnx-io/shelf_controller/tree/master/packages/shelf_controller_generator) for the spec
itself.

| Annotation | Target | Meaning |
| --- | --- | --- |
| `@ApiResponse(code, type:, description:, contentType:)` | method, class | An additional documented response, typically an error; a method annotation overrides a class one with the same code |
| `@ApiSecurity(scheme, scopes:)`, `@ApiSecurity.none()` | method, class | Security requirement; several annotations are alternatives, `none()` makes the operation public |
| `@ApiHidden()` | method, class | Keep the operation out of the spec; it is still routed |
| `@Deprecated` | method | `deprecated: true` |
| `@ApiSchema(name:, schema:)` | class, enum, field | Rename a schema or describe JSON the generator cannot infer |
| `@ApiDiscriminator(property, mapping:)` | sealed class | Describe a sealed hierarchy as `oneOf` with a discriminator |
| `@ApiField(minLength:, maxLength:, pattern:, minimum:, maximum:, example:)` | field, parameter | Constraints and an example; purely documentary |

The binding annotations take an optional description too:
`@Query('q', 'Full-text query')`, `@Body('The new project')`.

## What is out of scope

The library deliberately leaves these to the application:

- runtime validation of inputs (use an interceptor),
- authentication and authorization (use middleware and `RouteInfo`),
- dependency injection and construction of controllers,
- serialization of DTOs, which json_serializable does,
- binding several query parameters into one object,
- multipart, uploads and downloads (use `Request` and `Response`),
- generating clients; use [OpenAPI Generator](https://openapi-generator.tech)
  with the generated spec.

## Example

A complete application with authentication, authorization by a custom
annotation, validation, a discriminated union, a per-request controller and
Scalar API docs lives in [`example/`](https://github.com/fnx-io/shelf_controller/tree/master/example).
