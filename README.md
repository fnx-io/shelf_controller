# shelf_controller

Typed controllers for [shelf](https://pub.dev/packages/shelf) with a router and
an [OpenAPI 3.1](https://spec.openapis.org/oas/v3.1.0) spec generated from the
same method signatures, at build time and without reflection.

```dart
@Controller('/api/projects', tag: 'Projects')
class ProjectsController {
  /// Returns a project.
  @Get('/<id>')
  @ApiResponse(404)
  Future<ProjectDto> detail(@Path() String id, @Query() bool? withMembers) =>
      _projects.detail(id, withMembers: withMembers ?? false);
}
```

`dart run build_runner build` turns this into a `ProjectsControllerRouter` that
binds and validates the path and query parameters and serializes the result,
and into an `openapi.yaml` describing exactly that. The spec cannot drift from
the code, and a CI check on the committed spec makes every contract change
visible in review.

| Package | Purpose |
| --- | --- |
| [`shelf_controller`](packages/shelf_controller) | Annotations, `RouteInfo`, interceptors, Problem Details and the runtime used by generated code. A regular dependency. |
| [`shelf_controller_generator`](packages/shelf_controller_generator) | The `build_runner` builders generating routers and `openapi.yaml`. A dev dependency. |
| [`example`](example) | A complete application with tests. |

Start with the [shelf_controller README](packages/shelf_controller/README.md);
the [generator README](packages/shelf_controller_generator/README.md) covers the
spec, its configuration and the type mapping.

## Development

The repository is a [pub workspace](https://dart.dev/tools/pub/workspaces);
it requires Dart 3.11 or newer.

```sh
dart pub get
dart analyze packages example
(cd packages/shelf_controller && dart test)
(cd example && dart run build_runner build && dart test)
(cd packages/shelf_controller_generator && dart test)
```

Generator golden files are refreshed with
`UPDATE_GOLDENS=1 dart test test/golden_test.dart` in
`packages/shelf_controller_generator`; the validation of generated specs uses
[Redocly CLI](https://redocly.com/docs/cli/) through `npx` when Node.js is
installed.

## License

[MIT](LICENSE)
