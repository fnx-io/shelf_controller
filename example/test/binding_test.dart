import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import 'support/binding_controller.dart';
import 'support/http.dart';

void main() {
  late Handler handler;

  setUp(() {
    handler = BindingControllerRouter(BindingController()).handler;
  });

  Future<Object?> getJson(
    String path, {
    Map<String, String> headers = const {},
  }) async {
    final response = await send(handler, 'GET', path, headers: headers);
    final body = await response.readAsString();
    expect(response.statusCode, 200, reason: body);
    expect(response.headers['content-type'], 'application/json; charset=utf-8');
    return jsonDecode(body);
  }

  Future<void> expectBindingError(
    String method,
    String path,
    String detail, {
    Object? json,
    String? body,
    Map<String, String> headers = const {},
  }) async {
    final response = await send(
      handler,
      method,
      path,
      json: json,
      body: body,
      headers: headers,
    );
    expect(response.statusCode, 400);
    expect(
      response.headers['content-type'],
      'application/problem+json; charset=utf-8',
    );
    expect(await response.problemDetail(), detail);
  }

  group('path', () {
    test('binds typed and percent-decoded segments', () async {
      expect(await getJson('/bind/path/42/J%C3%A1n%20Nov%C3%A1k'), {
        'id': 42,
        'name': 'Ján Novák',
      });
    });

    test('does not match segments rejected by the route pattern', () async {
      final response = await send(handler, 'GET', '/bind/path/abc/x');
      expect(response.statusCode, 404);
    });
  });

  group('scalar query parameters', () {
    const valid = {
      'text': 'hi there',
      'count': '3',
      'ratio': '0.5',
      'amount': '7',
      'flag': 'true',
      'at': '2026-09-27T10:00:00Z',
      'link': 'https://example.com/a?b=c',
      'color': 'green',
    };

    String query(Map<String, String> params) =>
        '/bind/scalars?${Uri(queryParameters: params).query}';

    test('binds every scalar type', () async {
      expect(await getJson(query(valid)), {
        'text': 'hi there',
        'count': 3,
        'ratio': 0.5,
        'amount': 7,
        'flag': true,
        'at': '2026-09-27T10:00:00.000Z',
        'link': 'https://example.com/a?b=c',
        'color': 'green',
      });
    });

    for (final (name, value, expected) in [
      ('count', 'three', "expected an integer, got 'three'"),
      ('ratio', 'half', "expected a number, got 'half'"),
      ('amount', '1e', "expected a number, got '1e'"),
      ('flag', 'yes', "expected `true` or `false`, got 'yes'"),
      ('at', 'yesterday', "expected an ISO 8601 date-time, got 'yesterday'"),
      ('link', 'http://[::1', "expected a URI, got 'http://[::1'"),
      ('color', 'blue', "expected one of red, green, got 'blue'"),
    ]) {
      test('rejects an invalid $name', () async {
        await expectBindingError(
          'GET',
          query({...valid, name: value}),
          "Invalid query parameter '$name': $expected",
        );
      });
    }

    test('rejects a missing required parameter', () async {
      await expectBindingError(
        'GET',
        query({...valid}..remove('count')),
        "Invalid query parameter 'count': is required",
      );
    });
  });

  group('optional and repeated query parameters', () {
    test('uses null and declared defaults when absent', () async {
      expect(await getJson('/bind/optional'), {
        'page': null,
        'size': 10,
        'tags': null,
        'ids': [1],
      });
    });

    test('binds renamed and repeated parameters', () async {
      expect(
        await getJson(
          '/bind/optional?page=2&page-size=5&tag=a&tag=b&id=3&id=4',
        ),
        {
          'page': 2,
          'size': 5,
          'tags': ['a', 'b'],
          'ids': [3, 4],
        },
      );
    });

    test('rejects an invalid item of a list', () async {
      await expectBindingError(
        'GET',
        '/bind/optional?id=1&id=x',
        "Invalid query parameter 'id': expected an integer, got 'x'",
      );
    });

    test('requires at least one value of a non-nullable list', () async {
      expect(await getJson('/bind/required-list?c=red&c=green'), [
        'red',
        'green',
      ]);
      await expectBindingError(
        'GET',
        '/bind/required-list',
        "Invalid query parameter 'c': is required",
      );
    });
  });

  group('headers', () {
    test('binds headers case-insensitively', () async {
      expect(
        await getJson('/bind/header', headers: {'x-count': '2', 'X-NAME': 'n'}),
        {'count': 2, 'name': 'n'},
      );
    });

    test('rejects a missing or invalid header', () async {
      await expectBindingError(
        'GET',
        '/bind/header',
        "Invalid header parameter 'X-Count': is required",
      );
      await expectBindingError(
        'GET',
        '/bind/header',
        "Invalid header parameter 'X-Count': expected an integer, got 'x'",
        headers: {'X-Count': 'x'},
      );
    });
  });

  group('JSON body', () {
    test('decodes and encodes a DTO', () async {
      final project = {
        'code': 'WEB',
        'name': 'Web',
        'state': 'archived',
        'members': ['anna'],
        'created_at': '2026-09-27T10:00:00.000Z',
        'attachments': [
          {'type': 'note', 'text': 'hello'},
        ],
      };
      final response = await send(
        handler,
        'POST',
        '/bind/body/object',
        json: project,
      );
      expect(await response.json(), project);
    });

    test('decodes lists and maps of values', () async {
      final list = await send(
        handler,
        'POST',
        '/bind/body/list',
        json: [
          {'code': 'A', 'name': 'a'},
          {'code': 'B', 'name': 'b'},
        ],
      );
      expect(await list.json(), [
        {'code': 'B', 'name': 'b'},
        {'code': 'A', 'name': 'a'},
      ]);
      final map = await send(
        handler,
        'POST',
        '/bind/body/map',
        json: {'x': 1, 'y': 2},
      );
      expect(await map.json(), {'x': 2, 'y': 4});
    });

    test('decodes a primitive body', () async {
      final response = await send(
        handler,
        'POST',
        '/bind/body/primitive',
        body: '41',
      );
      expect(await response.json(), 42);
    });

    test('treats an empty optional body as null', () async {
      final empty = await send(handler, 'POST', '/bind/body/optional');
      expect(await empty.json(), 'none');
      final given = await send(
        handler,
        'POST',
        '/bind/body/optional',
        json: {'code': 'X', 'name': 'x'},
      );
      expect(await given.json(), 'X');
    });

    test('rejects a missing body', () async {
      await expectBindingError(
        'POST',
        '/bind/body/list',
        'Invalid request body: is required',
      );
    });

    test('rejects malformed JSON', () async {
      final response = await send(
        handler,
        'POST',
        '/bind/body/list',
        body: '[{',
      );
      expect(response.statusCode, 400);
      expect(
        await response.problemDetail(),
        startsWith('Invalid request body: malformed JSON'),
      );
    });

    test('rejects JSON of a wrong shape', () async {
      for (final json in [
        {'code': 'A'},
        [
          {'code': 1, 'name': 'a'},
        ],
        'text',
      ]) {
        final response = await send(
          handler,
          'POST',
          '/bind/body/list',
          json: json,
        );
        expect(response.statusCode, 400, reason: '$json');
        expect(
          await response.problemDetail(),
          startsWith('Invalid request body:'),
        );
      }
    });

    test('rejects an unknown discriminator value thrown by fromJson', () async {
      final response = await send(
        handler,
        'POST',
        '/bind/body/object',
        json: {
          'code': 'A',
          'name': 'a',
          'created_at': '2026-09-27T10:00:00.000Z',
          'attachments': [
            {'type': 'video'},
          ],
        },
      );
      expect(response.statusCode, 400);
      expect(
        await response.problemDetail(),
        contains('Unknown attachment type: video'),
      );
    });
  });

  group('results', () {
    test('serializes sets, dates, null and nested maps as JSON', () async {
      expect(await getJson('/bind/result/set'), ['green', 'red']);
      expect(await getJson('/bind/result/date'), '2026-09-27T12:00:00.000Z');
      expect(await getJson('/bind/result/nullable'), isNull);
      expect(await getJson('/bind/result/map'), {
        'a': [
          {'code': 'A', 'name': 'a'},
        ],
      });
    });

    test('responds 204 without a body for void', () async {
      final trace = <String>[];
      handler = BindingControllerRouter(BindingController(trace)).handler;
      final response = await send(handler, 'POST', '/bind/void');
      expect(response.statusCode, 204);
      expect(await response.readAsString(), isEmpty);
      expect(trace, ['void called']);
    });

    test('passes a shelf Response through unchanged', () async {
      final response = await send(handler, 'GET', '/bind/response');
      expect(response.statusCode, 418);
      expect(await response.readAsString(), 'teapot bind/response');
    });

    test('maps an unexpected exception to 500 without details', () async {
      final response = await send(handler, 'GET', '/bind/failure');
      expect(response.statusCode, 500);
      expect(await response.json(), {
        'type': 'about:blank',
        'title': 'Internal Server Error',
        'status': 500,
      });
    });
  });
}
