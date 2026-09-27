import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

/// Application annotation carried into RouteInfo.
class Secured {
  final List<String> roles;

  const Secured(this.roles);
}

@JsonSerializable()
class ProjectDto {
  final String id;
  final String code;

  ProjectDto(this.id, this.code);

  factory ProjectDto.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

@JsonSerializable()
class CreateProjectDto {
  final String code;

  CreateProjectDto(this.code);

  factory CreateProjectDto.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

abstract interface class ProjectService {
  Future<ProjectDto> create(CreateProjectDto body);
  Future<ProjectDto> detail(String id, {required bool withMembers});
}

/// The example from the specification.
@Controller('/api/projects', tag: 'Projects')
class ProjectsController {
  ProjectsController(this._projects);
  final ProjectService _projects;

  /// Založí nový projekt.
  @Post('/')
  @Status(201)
  @ApiResponse(409, description: 'Projekt s tímto kódem už existuje')
  @Secured(['admin'])
  Future<ProjectDto> create(@Body() CreateProjectDto body) =>
      _projects.create(body);

  /// Detail projektu.
  @Get('/<id>')
  @ApiResponse(404)
  Future<ProjectDto> detail(@Path() String id, @Query() bool? withMembers) =>
      _projects.detail(id, withMembers: withMembers ?? false);
}
