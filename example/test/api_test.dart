import 'package:shelf/shelf.dart';
import 'package:shelf_controller_example/app.dart';
import 'package:test/test.dart';

import 'support/http.dart';

void main() {
  late Handler app;
  const admin = {'authorization': 'Bearer admin'};
  const user = {'authorization': 'Bearer anna'};

  setUp(() {
    app = createApp(
      projects: ProjectService(now: () => DateTime.utc(2026, 9, 27, 10)),
    );
  });

  Future<Response> createProject(
    String code, {
    Map<String, String> headers = admin,
  }) => send(
    app,
    'POST',
    '/api/v1/projects',
    json: {'code': code, 'name': 'Project $code'},
    headers: headers,
  );

  test('creates and reads a project', () async {
    final created = await createProject('WEB');
    expect(created.statusCode, 201);
    expect(await created.json(), {
      'code': 'WEB',
      'name': 'Project WEB',
      'state': 'active',
      'members': <String>[],
      'created_at': '2026-09-27T10:00:00.000Z',
      'attachments': <Object?>[],
    });

    final detail = await send(app, 'GET', '/api/v1/projects/WEB');
    expect(((await detail.json())! as Map)['code'], 'WEB');
  });

  test(
    'authorizes by the custom @Secured annotation in route middleware',
    () async {
      expect((await createProject('WEB', headers: const {})).statusCode, 401);
      expect((await createProject('WEB', headers: user)).statusCode, 403);
      expect((await createProject('WEB')).statusCode, 201);
    },
  );

  test('validates arguments in an interceptor', () async {
    final response = await createProject('lower');
    expect(response.statusCode, 422);
    expect(await response.problemDetail(), contains('upper-case'));
  });

  test('maps application HttpProblems to Problem Details', () async {
    await createProject('WEB');
    final conflict = await createProject('WEB');
    expect(conflict.statusCode, 409);
    expect(
      conflict.headers['content-type'],
      startsWith('application/problem+json'),
    );
    expect(await conflict.json(), {
      'type': 'about:blank',
      'title': 'Conflict',
      'status': 409,
      'detail': 'Project WEB already exists',
    });
    expect((await send(app, 'GET', '/api/v1/projects/NOPE')).statusCode, 404);
  });

  test('filters and limits the list by query parameters', () async {
    for (final code in ['A1', 'B2', 'C3']) {
      await createProject(code);
    }
    await send(app, 'PUT', '/api/v1/projects/B2/archive', headers: admin);

    Future<List<Object?>> codes(String query) async {
      final response = await send(app, 'GET', '/api/v1/projects$query');
      return [
        for (final p in (await response.json())! as List) (p as Map)['code'],
      ];
    }

    expect(await codes(''), ['A1', 'B2', 'C3']);
    expect(await codes('?state=archived'), ['B2']);
    expect(await codes('?state=active&state=archived&limit=2'), ['A1', 'B2']);
    expect(
      (await send(app, 'GET', '/api/v1/projects?limit=many')).statusCode,
      400,
    );
  });

  test('accepts a discriminated body', () async {
    await createProject('WEB');
    final response = await send(
      app,
      'POST',
      '/api/v1/projects/WEB/attachments',
      json: {'type': 'link', 'url': 'https://example.com'},
    );
    expect(((await response.json())! as Map)['attachments'], [
      {'type': 'link', 'url': 'https://example.com'},
    ]);
  });

  test('deletes with 204', () async {
    await createProject('WEB');
    final response = await send(
      app,
      'DELETE',
      '/api/v1/projects/WEB',
      headers: admin,
    );
    expect(response.statusCode, 204);
    expect((await send(app, 'GET', '/api/v1/projects/WEB')).statusCode, 404);
  });

  test('passes a raw Response through', () async {
    await createProject('WEB');
    final response = await send(
      app,
      'GET',
      '/api/v1/projects/WEB/export',
      headers: {'x-separator': ';'},
    );
    expect(response.headers['content-type'], 'text/csv');
    expect(
      await response.readAsString(),
      'code;name;state\nWEB;Project WEB;active\n',
    );
  });

  test('creates the per-request controller from middleware context', () async {
    final me = await send(app, 'GET', '/api/v1/me', headers: user);
    expect(await me.json(), {
      'login': 'anna',
      'roles': ['user'],
    });
    expect((await send(app, 'GET', '/api/v1/me')).statusCode, 401);
    expect(await (await send(app, 'GET', '/api/v1/me/ping')).json(), {
      'status': 'ok',
    });
  });

  test('routes operations hidden from the spec', () async {
    final response = await send(app, 'GET', '/api/v1/me/debug', headers: user);
    expect(await response.json(), {'route': 'debug', 'user': 'anna'});
  });

  test('falls through mounted routers to 404', () async {
    expect((await send(app, 'GET', '/api/v1/unknown')).statusCode, 404);
  });
}
