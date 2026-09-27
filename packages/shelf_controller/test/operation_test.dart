import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_controller/shelf_controller.dart';
import 'package:test/test.dart';

const route = RouteInfo(
  operationId: 'op',
  method: 'GET',
  path: '/x',
  controller: Object,
  handler: 'op',
  annotations: [Get('/x'), Status(200)],
);

class Recorder implements OperationInterceptor {
  final List<String> log;
  final String name;

  Recorder(this.log, this.name);

  @override
  Future<Object?> intercept(
    RouteInfo route,
    List<Object?> args,
    Future<Object?> Function() proceed,
  ) async {
    log.add('$name>');
    final result = await proceed();
    log.add('<$name');
    return result;
  }
}

class Replacer implements OperationInterceptor {
  @override
  Future<Object?> intercept(route, args, proceed) async => 'replaced';
}

void main() {
  final request = Request('GET', Uri.parse('http://localhost/x'));

  group('invokeOperation', () {
    test('calls the operation directly without interceptors', () async {
      expect(await invokeOperation(route, [], [], () => 42), 42);
    });

    test('runs interceptors from the outermost to the innermost', () async {
      final log = <String>[];
      final result = await invokeOperation(
        route,
        ['a'],
        [Recorder(log, 'a'), Recorder(log, 'b')],
        () {
          log.add('call');
          return 'done';
        },
      );
      expect(result, 'done');
      expect(log, ['a>', 'b>', 'call', '<b', '<a']);
    });

    test('lets an interceptor skip the call', () async {
      var called = false;
      final result = await invokeOperation(route, [], [
        Replacer(),
      ], () => called = true);
      expect(result, 'replaced');
      expect(called, isFalse);
    });

    test('passes unmodifiable arguments', () async {
      late List<Object?> seen;
      await invokeOperation(
        route,
        [1],
        [_ArgsSpy((args) => seen = args)],
        () => null,
      );
      expect(seen, [1]);
      expect(() => seen[0] = 2, throwsUnsupportedError);
    });
  });

  group('operationHandler', () {
    test('stores the RouteInfo in the request context', () async {
      final handler = operationHandler(route, (request) {
        expect(RouteInfo.of(request), same(route));
        return Response.ok('ok');
      });
      expect((await handler(request)).statusCode, 200);
    });

    test('RouteInfo.of returns null outside a generated router', () {
      expect(RouteInfo.of(request), isNull);
    });

    test('runs middleware with the first one outermost', () async {
      final log = <String>[];
      Middleware named(String name) =>
          (inner) => (request) {
            log.add(name);
            return inner(request);
          };
      final handler = operationHandler(
        route,
        (_) => Response.ok(log.join()),
        middleware: [named('1'), named('2'), named('3')],
      );
      expect(await (await handler(request)).readAsString(), '123');
    });

    test('maps exceptions with the given mapper', () async {
      final handler = operationHandler(
        route,
        (_) => throw StateError('x'),
        exceptionMapper: (error, stack, request) => Response(
          503,
          body: '${RouteInfo.of(request)!.operationId}: $error',
        ),
      );
      final response = await handler(request);
      expect(response.statusCode, 503);
      expect(await response.readAsString(), 'op: Bad state: x');
    });

    test('uses Problem Details by default', () async {
      final handler = operationHandler(route, (_) => throw HttpProblem(410));
      final response = await handler(request);
      expect(response.statusCode, 410);
      expect(
        response.headers['content-type'],
        startsWith('application/problem+json'),
      );
    });

    test('lets hijacking through', () async {
      final handler = operationHandler(
        route,
        (_) => throw const HijackException(),
      );
      await expectLater(handler(request), throwsA(isA<HijackException>()));
    });
  });

  group('responses', () {
    test('jsonResponse encodes the body as UTF-8 JSON', () async {
      final response = jsonResponse(201, {'name': 'Žluťoučký kůň'});
      expect(response.statusCode, 201);
      expect(response.headers['content-type'], jsonContentType);
      expect(jsonDecode(await response.readAsString()), {
        'name': 'Žluťoučký kůň',
      });
    });

    test('emptyResponse has no body', () async {
      final response = emptyResponse(204);
      expect(response.statusCode, 204);
      expect(await response.readAsString(), isEmpty);
    });
  });

  test('RouteInfo.annotationsOf filters by type', () {
    expect(route.annotationsOf<Status>().single.code, 200);
    expect(route.annotationsOf<Post>(), isEmpty);
  });
}

class _ArgsSpy implements OperationInterceptor {
  final void Function(List<Object?>) _spy;

  _ArgsSpy(this._spy);

  @override
  Future<Object?> intercept(route, args, proceed) {
    _spy(args);
    return proceed();
  }
}
