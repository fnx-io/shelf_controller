import 'dart:convert';

import 'package:shelf_controller/shelf_controller.dart';
import 'package:test/test.dart';

enum Size { small, large }

Request request({
  String query = '',
  Map<String, String> pathParams = const {},
  Map<String, String> headers = const {},
  String? body,
}) => Request(
  'GET',
  Uri.parse('http://localhost/x$query'),
  headers: headers,
  body: body,
  context: {'shelf_router/params': pathParams},
);

Matcher bindingError(ParamSource source, String parameter, Object reason) =>
    isA<BindingException>()
        .having((e) => e.source, 'source', source)
        .having((e) => e.parameter, 'parameter', parameter)
        .having((e) => e.reason, 'reason', reason)
        .having((e) => e.status, 'status', 400);

void main() {
  group('ParamParser', () {
    test('parses valid values', () {
      expect(ParamParser.string.parse('a b', ParamSource.query, 'p'), 'a b');
      expect(ParamParser.integer.parse('-12', ParamSource.query, 'p'), -12);
      expect(ParamParser.float.parse('1.5', ParamSource.query, 'p'), 1.5);
      expect(ParamParser.number.parse('3', ParamSource.query, 'p'), 3);
      expect(
        ParamParser.boolean.parse('false', ParamSource.query, 'p'),
        isFalse,
      );
      expect(
        ParamParser.dateTime.parse('2026-09-27', ParamSource.query, 'p'),
        DateTime(2026, 9, 27),
      );
      expect(
        ParamParser.uri.parse('https://a.b/c', ParamSource.query, 'p'),
        Uri.parse('https://a.b/c'),
      );
      expect(
        ParamParser.enumeration(
          Size.values,
        ).parse('large', ParamSource.query, 'p'),
        Size.large,
      );
    });

    test('reports invalid values as BindingException', () {
      expect(
        () => ParamParser.boolean.parse('TRUE', ParamSource.header, 'X-Flag'),
        throwsA(
          bindingError(
            ParamSource.header,
            'X-Flag',
            "expected `true` or `false`, got 'TRUE'",
          ),
        ),
      );
      expect(
        () => ParamParser.enumeration(
          Size.values,
        ).parse('huge', ParamSource.query, 's'),
        throwsA(
          bindingError(
            ParamSource.query,
            's',
            "expected one of small, large, got 'huge'",
          ),
        ),
      );
    });
  });

  group('single values', () {
    test('reads path, query and header values', () {
      final r = request(
        query: '?q=1',
        pathParams: {'id': 'a%2Fb'},
        headers: {'X-Id': '7'},
      );
      expect(
        requireParam(r, ParamSource.path, 'id', ParamParser.string),
        'a/b',
      );
      expect(requireParam(r, ParamSource.query, 'q', ParamParser.integer), 1);
      expect(
        requireParam(r, ParamSource.header, 'x-id', ParamParser.integer),
        7,
      );
    });

    test('distinguishes required and optional values', () {
      final r = request();
      expect(
        optionalParam(r, ParamSource.query, 'q', ParamParser.integer),
        isNull,
      );
      expect(
        () => requireParam(r, ParamSource.query, 'q', ParamParser.integer),
        throwsA(bindingError(ParamSource.query, 'q', 'is required')),
      );
    });

    test('rejects malformed percent-encoding in the path', () {
      expect(
        () => requireParam(
          request(pathParams: {'id': '%E0%A4%A'}),
          ParamSource.path,
          'id',
          ParamParser.string,
        ),
        throwsA(
          bindingError(ParamSource.path, 'id', 'invalid percent-encoding'),
        ),
      );
    });

    test('refuses sources without a single value', () {
      expect(
        () =>
            requireParam(request(), ParamSource.body, 'b', ParamParser.string),
        throwsArgumentError,
      );
    });
  });

  group('query lists', () {
    test('reads repeated values', () {
      final r = request(query: '?n=1&n=2');
      expect(requireQueryList(r, 'n', ParamParser.integer), [1, 2]);
      expect(optionalQueryList(r, 'n', ParamParser.integer), [1, 2]);
    });

    test('handles absent lists', () {
      expect(optionalQueryList(request(), 'n', ParamParser.integer), isNull);
      expect(
        () => requireQueryList(request(), 'n', ParamParser.integer),
        throwsA(bindingError(ParamSource.query, 'n', 'is required')),
      );
    });
  });

  group('body', () {
    Map<String, Object?> asMap(Object? json) => json! as Map<String, Object?>;

    test('decodes JSON', () async {
      final r = request(body: jsonEncode({'a': 1}));
      expect(await requireBody(r, 'data', asMap), {'a': 1});
    });

    test('treats a blank body as absent', () async {
      expect(await optionalBody(request(body: '  '), 'data', asMap), isNull);
      await expectLater(
        requireBody(request(), 'data', asMap),
        throwsA(bindingError(ParamSource.body, 'data', 'is required')),
      );
    });

    test('reports malformed JSON', () async {
      await expectLater(
        requireBody(request(body: '{'), 'data', asMap),
        throwsA(
          bindingError(ParamSource.body, 'data', startsWith('malformed JSON')),
        ),
      );
    });

    test('reports decoding failures', () async {
      for (final decode in <Object? Function(Object?)>[
        (json) => json! as List<Object?>,
        (json) => throw ArgumentError('bad value'),
        (json) => throw const FormatException('bad format'),
      ]) {
        await expectLater(
          requireBody(request(body: '{}'), 'data', decode),
          throwsA(isA<BindingException>()),
        );
      }
    });

    test('keeps HttpProblems thrown while decoding', () async {
      await expectLater(
        requireBody(request(body: '{}'), 'data', (_) => throw HttpProblem(422)),
        throwsA(isA<HttpProblem>().having((p) => p.status, 'status', 422)),
      );
    });

    test('does not hide programming errors', () async {
      await expectLater(
        requireBody(
          request(body: '{}'),
          'data',
          (_) => throw StateError('bug'),
        ),
        throwsStateError,
      );
    });
  });
}
