# shelf_controller example

A small projects API showing every part of
[shelf_controller](../packages/shelf_controller):

| File | Shows |
| --- | --- |
| [`lib/src/projects_controller.dart`](lib/src/projects_controller.dart) | CRUD operations, query lists and defaults, headers, `@Status`, `@ApiResponse`, `@Deprecated`, a raw `Response` |
| [`lib/src/me_controller.dart`](lib/src/me_controller.dart) | A per-request controller, `@ApiSecurity.none()`, `@ApiHidden()` |
| [`lib/src/dto.dart`](lib/src/dto.dart) | DTOs, `@ApiField`, a sealed hierarchy with `@ApiDiscriminator` |
| [`lib/src/security.dart`](lib/src/security.dart) | Authentication middleware and authorization by a custom `@Secured` annotation read from `RouteInfo` |
| [`lib/src/validation.dart`](lib/src/validation.dart) | Validation in an `OperationInterceptor` |
| [`lib/src/project_service.dart`](lib/src/project_service.dart) | Application exceptions extending `HttpProblem` |
| [`lib/app.dart`](lib/app.dart) | Wiring routers together and serving the spec with Scalar |
| [`build.yaml`](build.yaml) | Generator options and the global json_serializable `field_rename` |
| [`openapi.yaml`](openapi.yaml) | The generated spec |
| [`test/`](test) | Runtime tests of binding, the request pipeline and the API, without a network |

Run it:

```sh
dart run build_runner build
dart run bin/server.dart
```

Then open http://localhost:8080/docs (set `PORT` to use another port). Requests authenticate with
`Authorization: Bearer <login>`; the login `admin` is an administrator.

```sh
curl -X POST localhost:8080/api/v1/projects \
  -H 'Authorization: Bearer admin' \
  -d '{"code": "WEB", "name": "Website"}'
curl 'localhost:8080/api/v1/projects?state=active&limit=10'
```
