# Example

A controller with typed parameters, a JSON body and documented errors:

```dart
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_controller/shelf_controller.dart';

import 'dto.dart';
import 'project_service.dart';

part 'main.g.dart';

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

  /// Lists projects.
  @Get('/')
  List<ProjectDto> list({
    @Query('state') List<ProjectState>? states,
    @Query() int limit = 20,
  }) => _projects.list(states: states, limit: limit);

  /// Returns a project.
  @Get('/<code>')
  @ApiResponse(404)
  ProjectDto detail(@Path() String code) => _projects.detail(code);
}

Future<void> main() async {
  final router = ProjectsControllerRouter(ProjectsController(ProjectService()));
  await shelf_io.serve(router.handler, 'localhost', 8080);
}
```

`dart run build_runner build` generates `ProjectsControllerRouter` into
`main.g.dart` and the spec into `openapi.yaml`.

The complete application, including authentication, authorization with a
custom annotation, validation in an interceptor, a discriminated union and
Scalar API docs, is in the
[example directory](https://github.com/fnx-io/shelf_controller/tree/master/example)
of the repository.
