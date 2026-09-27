---
name: shelf-controller
description: Builds typed Dart shelf HTTP APIs with the shelf_controller library and its build_runner generator shelf_controller_generator, which produce a router and an OpenAPI 3.1 openapi.yaml from annotated controller classes. ALWAYS use this skill when a Dart project depends on shelf_controller or shelf_controller_generator, or when the user wants to add or change a shelf endpoint, controller, route, DTO, request binding (@Path, @Query, @Header, @Body), status code, error response, middleware, interceptor, authorization annotation, RouteInfo, Problem Details, openapi.yaml or Swagger/OpenAPI docs of such a project — even if they only say "add an endpoint" or "the spec is out of date". Also use it to fix build_runner errors mentioning shelf_controller, RouterGenerator or OpenApiFragmentBuilder. Do NOT use for plain shelf_router code without shelf_controller, for Flutter, for HTTP clients, or for generating API clients from a spec.
metadata:
  library-version: 0.1.0
---

# shelf_controller

A controller is a plain class with annotated methods. `build_runner` generates
from the method signatures both a `<Controller>Router` (binding + JSON
serialization) and one `openapi.yaml`. Never hand-edit either output: change
the controller, DTO or `build.yaml` and rebuild, otherwise the next build
overwrites the edit and the spec drifts from behavior.

Requires Dart ≥ 3.11. Detailed signatures: `references/annotations.md`.
Spec generation, type mapping, DTO rules and all build errors:
`references/openapi.md`.

## Setup

```yaml
dependencies:
  shelf_controller:            # git until published on pub.dev
    git: {url: https://github.com/fnx-io/shelf_controller.git, path: packages/shelf_controller, ref: master}
  json_annotation: ^4.12.0
dev_dependencies:
  build_runner: ^2.16.0
  json_serializable: ^6.14.0
  shelf_controller_generator:
    git: {url: https://github.com/fnx-io/shelf_controller.git, path: packages/shelf_controller_generator, ref: master}
```

The builders apply automatically; no `build.yaml` entry is needed except for
spec options. Run `dart run build_runner build` after every change to a
controller, DTO or `build.yaml`.

## Writing a controller

```dart
import 'package:shelf_controller/shelf_controller.dart'; // every annotation and runtime type, plus Request, Response, Handler, Middleware, Router

import 'dto.dart';

part 'orders_controller.g.dart'; // required; shared with json_serializable

/// Orders.                      // doc comment = tag description in the spec
@Controller('/api/orders', tag: 'Orders')
class OrdersController {
  OrdersController(this._orders);
  final OrderService _orders;

  /// Creates an order.          // first paragraph = summary, rest = description
  @Post('/')                     // path argument is mandatory; '/' = the controller path itself
  @Status(201)
  @ApiResponse(409, description: 'Duplicate order')
  Future<OrderDto> create(@Body() CreateOrderDto body) => _orders.create(body);

  @Get('/<id>')
  @ApiResponse(404)
  OrderDto detail(@Path() String id) => _orders.detail(id);

  @Get('/')
  List<OrderDto> list({
    @Query() OrderStatus? status,   // nullable = optional
    @Query() int limit = 20,        // default = optional
    @Query('tag') List<String>? tags, // repeated ?tag=a&tag=b
  }) => _orders.list(status: status, limit: limit, tags: tags);

  @Put('/<id>/ship')
  Future<void> ship(@Path() String id, Request request) => _orders.ship(id); // void → 204
}
```

Rules the generator enforces (the build fails otherwise):

- Every parameter has exactly one of `@Path`, `@Query`, `@Header(name)`,
  `@Body()`; only a parameter of type `Request` may be unannotated (it gets the
  shelf request).
- Every `<name>` in the route has a matching `@Path`, and vice versa. Path
  params are non-nullable. `<id|[0-9]+>` restricts the segment by regex.
- `@Path`/`@Query`/`@Header` accept `String int double num bool DateTime Uri`
  and enums (bound by the Dart constant **name**, not `@JsonValue`). Only
  `@Query` accepts `List<T>`; a non-nullable `List<T>` without default
  requires at least one value.
- One `@Body` per operation; its type needs a `fromJson` factory (or is a
  List/Set/`Map<String, T>`/primitive). An empty body counts as absent.
- The result type needs `toJson()` (or is a collection/primitive/`DateTime`/
  enum). `void` → 204 (or `@Status`), `Response` → passed through unchanged.
- Operation names: `operationId` defaults to the method name and must be
  unique across **all** controllers in the package; set
  `@Get('/', operationId: 'listOrders')` on clashes (e.g. two `list` methods).
- Full path = controller path + operation path without trailing slash:
  `@Controller('/api/orders')` + `@Post('/')` → `POST /api/orders`.

Binding failures respond `400` automatically; never re-validate types in the
controller.

## Wiring

```dart
final orders = OrdersControllerRouter(
  OrdersController(service),        // one instance for all requests → no request state in fields
  middleware: [requireRoles()],      // after routing, before binding; first = outermost
  interceptors: [ValidationInterceptor()], // around the method, sees typed args
  exceptionMapper: problemDetailsMapper,   // the default
);
final app = Router()
  ..mount('/', orders.handler)      // always mount at '/': paths are complete in @Controller
  ..mount('/', users.handler);      // routers fall through to each other on no match
await shelf_io.serve(const Pipeline().addMiddleware(logRequests()).addHandler(app.call), 'localhost', 8080);
```

When the controller needs per-request data (the current user put into
`request.context` by middleware), use the factory constructor; it runs after
the router's middleware and before binding:

```dart
MeControllerRouter.perRequest(
  (request) => MeController(userOf(request)),
  middleware: [authenticate()], // same named parameters as the default constructor
)
```

Request pipeline order: routing → `RouteInfo` into context → router
middleware → per-request factory → binding → interceptors → method →
serialization. Exceptions from any of these go to the `exceptionMapper`.

## Errors

Throw `HttpProblem(status, title:, detail:, type:)` or subclass it; the
default `problemDetailsMapper` turns it into RFC 9457
`application/problem+json`. `BindingException` is an `HttpProblem(400)`. Any
other exception → `500` without details, logged to `Logger('shelf_controller')`.

```dart
class OrderNotFound extends HttpProblem {
  OrderNotFound(String id) : super(404, detail: 'Order $id does not exist');
}
```

Custom mapper: `(error, stack, request) => ...`; delegate unknown errors to
`problemDetailsMapper(error, stack, request)`. Document each error status the
operation can return with `@ApiResponse(code)` (on the method, or on the class
for all operations).

## Authorization and validation (the canonical pattern)

Keep cross-cutting checks out of controller methods. Define a const
annotation; the generator copies every annotation into the operation's
`RouteInfo`, so middleware can read it:

```dart
class RequiresRole {
  final String role;
  const RequiresRole(this.role);    // must be const-constructible
}

Middleware requireRoles() => (inner) => (request) {
  final required = RouteInfo.of(request)!.annotationsOf<RequiresRole>().map((r) => r.role);
  final roles = (request.headers['x-roles'] ?? '').split(',').map((r) => r.trim()).toSet();
  if (required.isNotEmpty && !required.any(roles.contains)) throw HttpProblem(403);
  return inner(request);
};
```

Pass it in the router's `middleware:` list, not as global `Pipeline`
middleware: global middleware runs before routing, where `RouteInfo.of`
returns `null`. It also runs before binding, so a caller without the role gets
`403` even for a nonexistent id.

Application annotations never reach the spec. Document the status they cause
next to them: `@RequiresRole('admin') @ApiResponse(403)` on the method, or
`@ApiResponse(403)` on the controller class.

Validation of typed arguments belongs in an interceptor. Arguments arrive in
parameter order as an unmodifiable list; throw, or return `proceed()`:

```dart
class ValidationInterceptor implements OperationInterceptor {
  @override
  Future<Object?> intercept(RouteInfo route, List<Object?> args, Future<Object?> Function() proceed) {
    for (final arg in args) {
      if (arg is CreateOrderDto && arg.items.any((i) => i.quantity <= 0)) {
        throw HttpProblem(422, detail: 'Quantity must be positive');
      }
    }
    return proceed();
  }
}
```

`RouteInfo` also offers `operationId`, `method`, `path`, `controller`,
`handler` and `params` (`ParamInfo`: `name`, `key`, `source`, `type`,
`annotations`). Each generated router exposes them as `static const routes`.

## DTOs and the spec

DTOs are ordinary `@JsonSerializable` classes; the schema mirrors what
json_serializable really writes (`@JsonKey(name:)`, `fieldRename`,
`includeFromJson/ToJson`, `defaultValue`, constructor defaults, `required`).
Global json_serializable options such as `field_rename: snake` in the app's
`build.yaml` are honored in the spec too.

The build **fails instead of guessing** for classes with a hand-written
`toJson` (no `@JsonSerializable`), `JsonConverter` fields,
`@JsonKey(fromJson:/toJson:)`, generic DTOs and types like `Duration`. Fix by
describing the JSON shape, not by removing the check:

```dart
@ApiSchema(schema: {'type': 'string', 'pattern': r'^\d+\.\d{2} [A-Z]{3}$', 'example': '12.50 CZK'})
class Money {
  factory Money.fromJson(String json) => ...;
  String toJson() => ...;
}
```

`@ApiSchema(schema:)` also works on a single field; `@ApiSchema(name:)`
resolves two classes with the same name.

Spec options live in the app's `build.yaml` under the builder key
`shelf_controller_generator` (unknown keys fail the build):

```yaml
targets:
  $default:
    builders:
      json_serializable:
        options:
          field_rename: snake
      shelf_controller_generator:
        options:
          info: {title: Orders API, version: 1.0.0}
          servers: [{url: https://api.example.com}]
          securitySchemes: {bearer: {type: http, scheme: bearer}}
          security: [{bearer: []}]      # every scheme used must be defined above
```

Documentation-only annotations: `@ApiResponse(code, type:, description:,
contentType:)`, `@ApiSecurity(scheme, scopes:)` / `@ApiSecurity.none()`,
`@ApiHidden()` (routed, not in spec), `@Deprecated`, `@ApiField(minLength:,
maxLength:, pattern:, minimum:, maximum:, example:)`, `@ApiDiscriminator` for
sealed classes. None of them validates anything at runtime.

Every operation with bound parameters or a body automatically documents a
`400` Problem Details response; document other statuses with `@ApiResponse`.

Commit `openapi.yaml`; in CI run `dart run build_runner build` then
`git diff --exit-code openapi.yaml`.

## Testing

Test through the generated handler in memory, no server needed:

```dart
final handler = OrdersControllerRouter(OrdersController(FakeService()), middleware: [requireRoles()]).handler;

// Handler returns FutureOr<Response>, so a helper needs `async`.
Future<Response> send(String method, String path, {Object? json, Map<String, String> headers = const {}}) async =>
    handler(Request(method, Uri.parse('http://localhost$path'),
        body: json == null ? null : jsonEncode(json), headers: headers));

final response = await send('POST', '/api/orders', json: {'customer': 'c', 'items': []});
expect(response.statusCode, 201);
```

The `Uri` must be absolute (`http://localhost/...`). A `Response` body can be
read only once. Controllers declared under `test/` get routers but are not
added to `openapi.yaml` (the spec covers `lib/` and `bin/`).

## Troubleshooting

| Symptom | Cause and fix |
| --- | --- |
| `XControllerRouter` isn't defined | Missing `part 'x.g.dart';` in the controller library, or the build was not run |
| `Parameter \`x\` needs @Path, @Query, @Header or @Body.` | Annotate it, or type it `Request` |
| `Path parameters of ... do not match the method` | Route `<name>` and `@Path` names differ (`@Path('name')` renames) |
| `cannot be bound from the query/path/header` | Unsupported type there; use a scalar/enum, or a `@Body` |
| `Cannot infer the JSON schema of \`X\`` | Add `@JsonSerializable`, or `@ApiSchema(schema: {...})` |
| `\`X\` has no \`fromJson\` constructor` / `no \`toJson()\` method` | Add it; body types need `fromJson`, results need `toJson()` |
| `operationId \`x\` is used by both A.x and B.x` | Set `operationId:` on one of them |
| `Security scheme \`x\` is not defined` | Add it to `securitySchemes` in `build.yaml` |
| `RouteInfo.of(request)` is `null` | Middleware registered globally instead of in the router's `middleware:` |
| Enum query value rejected | Send the Dart constant name, not the `@JsonValue` |

More messages and the full type mapping: `references/openapi.md`.
