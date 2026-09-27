import 'package:shelf_controller/shelf_controller.dart';
import 'package:shelf_controller_example/app.dart';
import 'package:test/test.dart';

import 'support/binding_controller.dart';
import 'support/http.dart';

/// Records its position in the pipeline.
Middleware recordingMiddleware(List<String> trace, String name) =>
    (inner) => (request) async {
      trace.add('$name before');
      final response = await inner(request);
      trace.add('$name after');
      return response;
    };

class RecordingInterceptor implements OperationInterceptor {
  final List<String> trace;
  final String name;

  RecordingInterceptor(this.trace, this.name);

  @override
  Future<Object?> intercept(
    RouteInfo route,
    List<Object?> args,
    Future<Object?> Function() proceed,
  ) async {
    trace.add('$name before $args');
    final result = await proceed();
    trace.add('$name after $result');
    return result;
  }
}

class UpperCaseInterceptor implements OperationInterceptor {
  @override
  Future<Object?> intercept(route, args, proceed) async =>
      (await proceed() as String).toUpperCase();
}

void main() {
  late List<String> trace;

  setUp(() => trace = []);

  test(
    'runs middleware, factory, binding, interceptors and the method in order',
    () async {
      final router = BindingControllerRouter.perRequest(
        (request) {
          trace.add('factory');
          return BindingController(trace);
        },
        middleware: [
          recordingMiddleware(trace, 'm1'),
          recordingMiddleware(trace, 'm2'),
        ],
        interceptors: [
          RecordingInterceptor(trace, 'i1'),
          RecordingInterceptor(trace, 'i2'),
        ],
      );

      final response = await send(router.handler, 'GET', '/bind/traced/x');

      expect(await response.json(), 'x');
      expect(trace, [
        'm1 before',
        'm2 before',
        'factory',
        'i1 before [x]',
        'i2 before [x]',
        'controller x',
        'i2 after x',
        'i1 after x',
        'm2 after',
        'm1 after',
      ]);
    },
  );

  test('calls the per-request factory once per request', () async {
    var created = 0;
    final router = BindingControllerRouter.perRequest((request) {
      created++;
      return BindingController();
    });
    await send(router.handler, 'GET', '/bind/traced/a');
    await send(router.handler, 'GET', '/bind/traced/b');
    expect(created, 2);
  });

  test(
    'route middleware sees RouteInfo with all annotations and parameters',
    () async {
      RouteInfo? seen;
      final router = BindingControllerRouter(
        BindingController(),
        middleware: [
          (inner) => (request) {
            seen = RouteInfo.of(request);
            return inner(request);
          },
        ],
      );

      await send(router.handler, 'GET', '/bind/traced/x');

      final route = seen!;
      expect(route.operationId, 'traced');
      expect(route.method, 'GET');
      expect(route.path, '/bind/traced/<id>');
      expect(route.controller, BindingController);
      expect(route.handler, 'traced');
      expect(route.annotations, [
        isA<Controller>().having((c) => c.tag, 'tag', 'Binding'),
        isA<Get>().having((g) => g.path, 'path', '/traced/<id>'),
        isA<Secured>().having((s) => s.roles, 'roles', ['tracing']),
      ]);
      expect(route.annotationsOf<Secured>().single.roles, ['tracing']);
      final param = route.params.single;
      expect(param.name, 'id');
      expect(param.key, 'id');
      expect(param.source, ParamSource.path);
      expect(param.type, 'String');
      expect(param.annotationsOf<Path>(), hasLength(1));
    },
  );

  test('exposes route metadata statically', () {
    final routes = BindingControllerRouter.routes;
    expect(routes.map((r) => r.operationId), contains('scalars'));
    final optional = routes.firstWhere((r) => r.handler == 'optional');
    expect(optional.params.map((p) => (p.name, p.key, p.source, p.type)), [
      ('page', 'page', ParamSource.query, 'int?'),
      ('size', 'page-size', ParamSource.query, 'int'),
      ('tags', 'tag', ParamSource.query, 'List<String>?'),
      ('ids', 'id', ParamSource.query, 'List<int>'),
    ]);
  });

  test('middleware can short-circuit before binding', () async {
    final router = BindingControllerRouter(
      BindingController(trace),
      middleware: [
        (inner) =>
            (request) => Response.forbidden('no'),
      ],
    );
    final response = await send(router.handler, 'GET', '/bind/scalars');
    expect(response.statusCode, 403);
  });

  test('interceptors can transform the result', () async {
    final router = BindingControllerRouter(
      BindingController(),
      interceptors: [UpperCaseInterceptor()],
    );
    final response = await send(router.handler, 'GET', '/bind/traced/abc');
    expect(await response.json(), 'ABC');
  });

  test('interceptors cannot change the arguments', () async {
    final router = BindingControllerRouter(
      BindingController(),
      interceptors: [_ArgumentChanger()],
    );
    final response = await send(router.handler, 'GET', '/bind/traced/abc');
    expect(response.statusCode, 500);
  });

  group('exception mapping', () {
    test('a custom mapper replaces the default one', () async {
      final router = BindingControllerRouter(
        BindingController(),
        exceptionMapper: (error, stack, request) => Response(
          599,
          body: '${error.runtimeType} in ${RouteInfo.of(request)!.operationId}',
        ),
      );
      final response = await send(router.handler, 'GET', '/bind/failure');
      expect(response.statusCode, 599);
      expect(await response.readAsString(), 'StateError in failure');
    });

    test('a custom mapper can delegate to problemDetailsMapper', () async {
      final router = BindingControllerRouter(
        BindingController(),
        exceptionMapper: (error, stack, request) => error is StateError
            ? Response(503)
            : problemDetailsMapper(error, stack, request),
      );
      expect(
        (await send(router.handler, 'GET', '/bind/failure')).statusCode,
        503,
      );
      final binding = await send(router.handler, 'GET', '/bind/scalars');
      expect(binding.statusCode, 400);
    });

    test('catches exceptions thrown by route middleware', () async {
      final router = BindingControllerRouter(
        BindingController(),
        middleware: [
          (inner) =>
              (request) => throw HttpProblem(401, detail: 'who?'),
        ],
      );
      final response = await send(router.handler, 'GET', '/bind/traced/x');
      expect(response.statusCode, 401);
      expect(await response.json(), {
        'type': 'about:blank',
        'title': 'Unauthorized',
        'status': 401,
        'detail': 'who?',
      });
    });
  });
}

class _ArgumentChanger implements OperationInterceptor {
  @override
  Future<Object?> intercept(route, args, proceed) {
    args[0] = 'changed';
    return proceed();
  }
}
