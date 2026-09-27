import 'package:shelf_controller/shelf_controller.dart';

import 'dto.dart';
import 'project_service.dart';
import 'security.dart';

part 'projects_controller.g.dart';

/// Projects and their attachments.
@Controller('/api/v1/projects', tag: 'Projects')
@ApiResponse(401, description: 'Missing or invalid credentials')
class ProjectsController {
  final ProjectService _projects;

  ProjectsController(this._projects);

  /// Creates a project.
  ///
  /// Only administrators may create projects.
  @Post('/')
  @Status(201)
  @ApiResponse(403)
  @ApiResponse(409, description: 'A project with this code already exists')
  @ApiResponse(422, description: 'The project code is invalid')
  @Secured(['admin'])
  Future<ProjectDto> create(@Body() CreateProjectDto body) async =>
      _projects.create(body);

  /// Lists projects.
  @Get('/')
  List<ProjectDto> list({
    @Query('state', 'Only projects in one of these states')
    List<ProjectState>? states,
    @Query() @ApiField(minimum: 1, maximum: 100) int limit = 20,
  }) => _projects.list(states: states?.toSet(), limit: limit);

  /// Returns a project.
  @Get('/<code>')
  @ApiResponse(404)
  ProjectDto detail(@Path() String code) => _projects.detail(code);

  /// Adds an attachment to a project.
  @Post('/<code>/attachments')
  @ApiResponse(404)
  ProjectDto attach(@Path() String code, @Body() Attachment attachment) =>
      _projects.addAttachment(code, attachment);

  /// Archives a project.
  @Put('/<code>/archive')
  @ApiResponse(404)
  @Secured(['admin'])
  Future<void> archive(@Path() String code) async => _projects.archive(code);

  /// Deletes a project.
  @Delete('/<code>')
  @ApiResponse(404)
  @Secured(['admin'])
  @Deprecated('Archive projects instead')
  void delete(@Path() String code) => _projects.delete(code);

  /// Exports a project as CSV.
  ///
  /// Returns a plain shelf `Response`, so its content is documented by
  /// `@ApiResponse`.
  @Get('/<code>/export')
  @ApiResponse(
    200,
    type: String,
    contentType: 'text/csv',
    description: 'The project as CSV',
  )
  @ApiResponse(404)
  Response export(
    @Path() String code,
    @Header('X-Separator') String? separator,
  ) {
    final project = _projects.detail(code);
    final sep = separator ?? ',';
    return Response.ok(
      'code${sep}name${sep}state\n${project.code}$sep${project.name}$sep${project.state.name}\n',
      headers: {'content-type': 'text/csv'},
    );
  }
}
