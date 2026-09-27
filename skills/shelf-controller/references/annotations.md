# shelf_controller API reference

Contents: routing annotations · binding annotations · documentation
annotations · runtime types (RouteInfo, interceptors, errors) · generated
router · helpers used by generated code.

All symbols come from `package:shelf_controller/shelf_controller.dart`.

## Routing annotations

| Signature | Target |
| --- | --- |
| `const Controller(String path, {String? tag})` | class |
| `const Get(String path, {String? operationId})` | method |
| `const Post(String path, {String? operationId})` | method |
| `const Put(String path, {String? operationId})` | method |
| `const Patch(String path, {String? operationId})` | method |
| `const Delete(String path, {String? operationId})` | method |
| `const Status(int code)` | method |

- `path` of the HTTP annotations is positional and required; use `'/'` for the
  controller path itself. There is no `@Head`/`@Options`.
- All five extend `Operation` (`method`, `path`, `operationId`), so
  `RouteInfo.annotationsOf<Operation>()` finds the HTTP annotation.
- Default status: `200`, or `204` when the method returns `void`/`Future<void>`.

## Binding annotations

| Signature | Source | `name` default |
| --- | --- | --- |
| `const Path([String? name, String? description])` | path segment, percent-decoded | parameter name |
| `const Query([String? name, String? description])` | query parameter | parameter name |
| `const Header(String name, [String? description])` | header, case-insensitive | — (required) |
| `const Body([String? description])` | JSON body | — |

Both `name` and `description` are positional: `@Query('q', 'Full-text query')`.
Parameters may be positional or named; named ones may have defaults
(`{@Query() int limit = 20}`), which the generator copies into the router and
the spec.

Scalar parsing: `bool` accepts exactly `true`/`false`; `DateTime` uses
`DateTime.parse` (ISO 8601); `int`/`double`/`num` their `parse`; enums
`values.byName`. Invalid values → `400` with a detail such as
`Invalid query parameter 'limit': expected an integer, got 'x'`.

Body decoding: `Class.fromJson(json as <type of the fromJson parameter>)`,
lists/sets/maps element-wise, `int` from any JSON number. A `TypeError`,
`FormatException`, `ArgumentError` or other `Exception` thrown while decoding
becomes `400 Invalid request body: ...`; an `HttpProblem` thrown by `fromJson`
is kept; `Error`s other than `TypeError`/`ArgumentError` propagate (→ 500).

Result encoding: `toJson()` on classes, `.name` on enums,
`toIso8601String()` on `DateTime`, `toString()` on `Uri`, sets become lists.
`jsonEncode` then calls `toJson()` on nested objects, so
`explicitToJson` is not needed. A `null` result is sent as JSON `null` with
the success status.

## Documentation annotations (no runtime effect)

| Signature | Target |
| --- | --- |
| `const ApiResponse(int code, {Type? type, String? description, String? contentType})` | method, class |
| `const ApiSecurity(String scheme, {List<String> scopes = const []})` | method, class |
| `const ApiSecurity.none()` | method, class |
| `const ApiHidden()` | method, class |
| `const ApiSchema({String? name, Map<String, Object?>? schema})` | class, enum, field |
| `const ApiDiscriminator(String propertyName, {Map<String, Type> mapping = const {}})` | sealed class |
| `const ApiField({int? minLength, int? maxLength, String? pattern, num? minimum, num? maximum, Object? example})` | DTO field, parameter |
| `@Deprecated('...')` / `@deprecated` | method |

- `@ApiResponse` without `type` uses the error schema (Problem Details by
  default). `type` may be a generic type literal: `type: List<ErrorDto>`.
  `contentType` defaults to `application/json`.
- Class-level `@ApiResponse`s apply to every operation; a method-level one with
  the same code wins. `@ApiResponse` with the success code replaces the
  generated success response (use it for methods returning `Response`).
- Several `@ApiSecurity` on one element are alternatives. Method-level ones
  replace class-level ones, which replace the global `security` option.
  `none()` alone → `security: []` (public); together with others → optional
  authentication.

## Runtime types

```dart
class RouteInfo {
  static const contextKey = 'shelf_controller/route';
  final String operationId, method, path; // path in shelf_router syntax
  final Type controller;
  final String handler;                   // method name
  final List<Object> annotations;         // class annotations, then method annotations
  final List<ParamInfo> params;           // declaration order
  static RouteInfo? of(Request request);
  Iterable<T> annotationsOf<T>();
}

class ParamInfo {
  final String name;        // Dart parameter name
  final String? key;        // name in the request; null for body/request
  final ParamSource source; // path, query, header, body, request
  final String type;        // e.g. 'int?', 'List<String>'
  final List<Object> annotations;
  Iterable<T> annotationsOf<T>();
}

abstract interface class OperationInterceptor {
  Future<Object?> intercept(RouteInfo route, List<Object?> args, Future<Object?> Function() proceed);
}

typedef ExceptionMapper = FutureOr<Response> Function(Object error, StackTrace stackTrace, Request request);

class HttpProblem implements Exception {
  HttpProblem(int status, {String? title, String? detail, Uri? type});
  Map<String, Object> toProblemDetails(); // type (default about:blank), title (default reason phrase), status, detail
}

class BindingException extends HttpProblem { // status 400
  final ParamSource source; final String parameter; final String reason;
}

Response problemDetailsMapper(Object error, StackTrace stackTrace, Request request);
Response problemResponse(HttpProblem problem); // application/problem+json; charset=utf-8
```

`RouteInfo.annotations` holds every annotation of the controller class and
the method, including `@Controller`, the HTTP annotation, `@Deprecated` and
application annotations. An application annotation needs a `const`
constructor and must be visible in the controller library (the generated part
shares its imports).

`args` in an interceptor is unmodifiable (writing throws → 500). Returning a
different value from `intercept` replaces the result, which is then cast to
the declared return type.

## Generated router

For `class FooController` the generated part contains `FooControllerRouter`:

```dart
FooControllerRouter(FooController controller, {
  List<Middleware> middleware = const [],
  List<OperationInterceptor> interceptors = const [],
  ExceptionMapper exceptionMapper = problemDetailsMapper,
});
FooControllerRouter.perRequest(FooController Function(Request request) controllerFor, {...same named parameters});
static const List<RouteInfo> routes;
late final Handler handler;
```

Each operation is registered with `shelf_router` as `Router()..add(METHOD,
fullPath, ...)`; `shelf_router` also answers `HEAD` for `GET` routes. An
unmatched request returns `Router.routeNotFound`, so mounting several routers
at `/` falls through.

## Helpers called by generated code

Not meant for hand-written code, listed so errors mentioning them make sense:
`requireParam`, `optionalParam`, `requireQueryList`, `optionalQueryList`,
`requireBody`, `optionalBody`, `ParamParser` (`string`, `integer`, `float`,
`number`, `boolean`, `dateTime`, `uri`, `enumeration(values)`),
`invokeOperation`, `operationHandler`, `jsonResponse`, `emptyResponse`.
