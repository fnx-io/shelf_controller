import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shelf_controller/shelf_controller.dart';
import 'package:test/test.dart';

void main() {
  final request = Request('GET', Uri.parse('http://localhost/x'));

  Future<Map<String, Object?>> problemOf(Response response) async {
    expect(
      response.headers['content-type'],
      'application/problem+json; charset=utf-8',
    );
    return jsonDecode(await response.readAsString()) as Map<String, Object?>;
  }

  group('HttpProblem', () {
    test('defaults the title to the reason phrase', () {
      expect(HttpProblem(404).toProblemDetails(), {
        'type': 'about:blank',
        'title': 'Not Found',
        'status': 404,
      });
    });

    test('includes type, title and detail when given', () {
      final problem = HttpProblem(
        409,
        type: Uri.parse('https://example.com/problems/conflict'),
        title: 'Duplicate',
        detail: 'Exists',
      );
      expect(problem.toProblemDetails(), {
        'type': 'https://example.com/problems/conflict',
        'title': 'Duplicate',
        'status': 409,
        'detail': 'Exists',
      });
    });
  });

  group('BindingException', () {
    test('describes the parameter in the detail', () {
      expect(
        BindingException(ParamSource.query, 'page', 'is required').detail,
        "Invalid query parameter 'page': is required",
      );
      expect(
        BindingException(ParamSource.body, 'body', 'malformed JSON').detail,
        'Invalid request body: malformed JSON',
      );
    });
  });

  group('problemDetailsMapper', () {
    test('maps HttpProblem to its status', () async {
      final response = problemDetailsMapper(
        HttpProblem(403, detail: 'No'),
        StackTrace.current,
        request,
      );
      expect(response.statusCode, 403);
      expect(await problemOf(response), {
        'type': 'about:blank',
        'title': 'Forbidden',
        'status': 403,
        'detail': 'No',
      });
    });

    test('maps BindingException to 400', () async {
      final response = problemDetailsMapper(
        BindingException(ParamSource.header, 'X-Id', 'is required'),
        StackTrace.current,
        request,
      );
      expect(response.statusCode, 400);
      expect(
        (await problemOf(response))['detail'],
        "Invalid header parameter 'X-Id': is required",
      );
    });

    test('hides and logs other exceptions', () async {
      final records = <LogRecord>[];
      final subscription = Logger(
        'shelf_controller',
      ).onRecord.listen(records.add);
      addTearDown(subscription.cancel);

      final response = problemDetailsMapper(
        StateError('secret'),
        StackTrace.current,
        request,
      );

      expect(response.statusCode, 500);
      final body = await problemOf(response);
      expect(body, {
        'type': 'about:blank',
        'title': 'Internal Server Error',
        'status': 500,
      });
      expect(jsonEncode(body), isNot(contains('secret')));
      expect(records.single.level, Level.SEVERE);
      expect(records.single.error, isA<StateError>());
    });
  });

  test('reasonPhrase falls back for unknown codes', () {
    expect(reasonPhrase(201), 'Created');
    expect(reasonPhrase(299), 'HTTP 299');
  });
}
