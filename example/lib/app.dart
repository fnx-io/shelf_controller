/// An example API built with shelf_controller.
library;

import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'src/me_controller.dart';
import 'src/project_service.dart';
import 'src/projects_controller.dart';
import 'src/security.dart';
import 'src/validation.dart';

export 'src/dto.dart';
export 'src/me_controller.dart';
export 'src/project_service.dart';
export 'src/projects_controller.dart';
export 'src/security.dart';
export 'src/validation.dart';

/// Creates the application handler.
///
/// Controllers are created here, the library has no dependency injection.
Handler createApp({ProjectService? projects}) {
  final projectsRouter = ProjectsControllerRouter(
    ProjectsController(projects ?? ProjectService()),
    middleware: [authorize()],
    interceptors: [ValidationInterceptor()],
  );
  final meRouter = MeControllerRouter.perRequest(
    (request) => MeController(userOf(request)),
  );

  final api = Router()
    ..get('/openapi.yaml', _serveSpec)
    ..get('/docs', _serveDocs)
    ..mount('/', projectsRouter.handler)
    ..mount('/', meRouter.handler);

  return const Pipeline().addMiddleware(authenticate()).addHandler(api.call);
}

Response _serveSpec(Request request) => Response.ok(
  File('openapi.yaml').readAsStringSync(),
  headers: {'content-type': 'application/yaml'},
);

Response _serveDocs(Request request) => Response.ok(
  '''
<!doctype html>
<html>
  <head><title>Projects API</title><meta charset="utf-8"></head>
  <body>
    <script id="api-reference" data-url="/openapi.yaml"></script>
    <script src="https://cdn.jsdelivr.net/npm/@scalar/api-reference"></script>
  </body>
</html>
''',
  headers: {'content-type': 'text/html'},
);
