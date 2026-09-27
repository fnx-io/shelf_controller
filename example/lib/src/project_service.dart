import 'package:shelf_controller/shelf_controller.dart';

import 'dto.dart';

/// Thrown when a project does not exist; maps to `404`.
class ProjectNotFound extends HttpProblem {
  ProjectNotFound(String code)
    : super(404, detail: 'Project $code does not exist');
}

/// Thrown when a project code is taken; maps to `409`.
class ProjectExists extends HttpProblem {
  ProjectExists(String code)
    : super(409, detail: 'Project $code already exists');
}

/// Keeps projects in memory.
class ProjectService {
  final _projects = <String, ProjectDto>{};
  final DateTime Function() _now;

  ProjectService({DateTime Function()? now}) : _now = now ?? DateTime.now;

  ProjectDto create(CreateProjectDto data) {
    if (_projects.containsKey(data.code)) throw ProjectExists(data.code);
    return _projects[data.code] = ProjectDto(
      code: data.code,
      name: data.name,
      createdAt: _now().toUtc(),
    );
  }

  ProjectDto detail(String code) =>
      _projects[code] ?? (throw ProjectNotFound(code));

  List<ProjectDto> list({Set<ProjectState>? states, int limit = 20}) =>
      _projects.values
          .where((p) => states == null || states.contains(p.state))
          .take(limit)
          .toList();

  ProjectDto addAttachment(String code, Attachment attachment) {
    final project = detail(code);
    return _projects[code] = ProjectDto(
      code: project.code,
      name: project.name,
      createdAt: project.createdAt,
      state: project.state,
      members: project.members,
      attachments: [...project.attachments, attachment],
    );
  }

  void archive(String code) {
    final project = detail(code);
    _projects[code] = ProjectDto(
      code: project.code,
      name: project.name,
      createdAt: project.createdAt,
      state: ProjectState.archived,
      members: project.members,
      attachments: project.attachments,
    );
  }

  void delete(String code) {
    if (_projects.remove(code) == null) throw ProjectNotFound(code);
  }
}
