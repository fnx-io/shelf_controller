/// Invalid controllers and DTOs must fail the build with a helpful message.
library;

import 'package:test/test.dart';

import 'support/generate.dart';

const _imports = '''
import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';
''';

/// A DTO with `fromJson` and `toJson` but no `@JsonSerializable`.
const _handWritten = '''
class HandWritten {
  factory HandWritten.fromJson(Map<String, dynamic> json) => throw 0;
  Map<String, dynamic> toJson() => {};
}
''';

Future<void> expectError(
  String declarations,
  Object message, {
  Map<String, String> otherSources = const {},
  String? buildYaml,
}) async {
  final generated = await generate({
    'lib/input.dart': '$_imports\n$declarations',
    ...otherSources,
  }, buildYaml: buildYaml);
  expect(
    generated.errors,
    contains(message is Matcher ? message : contains(message)),
  );
}

String controller(String methods) =>
    '''
@Controller('/x')
class XController {
$methods
}
''';

void main() {
  group('signatures', () {
    test('a parameter without a binding annotation', () async {
      await expectError(
        controller("@Get('/') String get(String name) => name;"),
        'Parameter `name` needs @Path, @Query, @Header or @Body.',
      );
    });

    test('a parameter with two binding annotations', () async {
      await expectError(
        controller(
          "@Get('/') String get(@Query() @Header('X') String name) => name;",
        ),
        'Parameter `name` has more than one binding annotation.',
      );
    });

    test('two bodies', () async {
      await expectError(
        controller(
          "@Post('/') String post(@Body() String a, @Body() String b) => a;",
        ),
        'An operation can have only one @Body parameter.',
      );
    });

    test('a route segment without @Path', () async {
      await expectError(
        controller("@Get('/<id>') String get() => '';"),
        'missing @Path for id',
      );
    });

    test('@Path without a route segment', () async {
      await expectError(
        controller("@Get('/') String get(@Path() String id) => id;"),
        'no segment for id',
      );
    });

    test('a nullable path parameter', () async {
      await expectError(
        controller("@Get('/<id>') String get(@Path() String? id) => '';"),
        'cannot be bound from the path',
      );
    });

    test('a list in a header', () async {
      await expectError(
        controller("@Get('/') String get(@Header('X') List<String> x) => '';"),
        'cannot be bound from the header',
      );
    });

    test('an object in the query', () async {
      await expectError(
        '$_handWritten\n${controller("@Get('/') String get(@Query() HandWritten h) => '';")}',
        'cannot be bound from the query',
      );
    });

    test('the same route twice', () async {
      await expectError(
        controller("""
          @Get('/a') String a() => '';
          @Get('/a/') String b() => '';
        """),
        'Route `GET /x/a` is declared more than once.',
      );
    });

    test('a static operation', () async {
      await expectError(
        controller("@Get('/') static String get() => '';"),
        'Operations must be public instance methods.',
      );
    });

    test('a record result', () async {
      await expectError(
        controller("@Get('/') (int, int) get() => (1, 2);"),
        'has no JSON representation',
      );
    });

    test('a map with non-String keys', () async {
      await expectError(
        controller("@Get('/') Map<int, String> get() => {};"),
        'only `String` map keys are supported',
      );
    });
  });

  group('serialization', () {
    test('a body type without fromJson', () async {
      await expectError('''
        @JsonSerializable(createFactory: false)
        class Out { Map<String, dynamic> toJson() => {}; }
        ${controller("@Post('/') void post(@Body() Out body) {}")}
        ''', '`Out` has no `fromJson` constructor');
    });

    test('a result type without toJson', () async {
      await expectError('''
        @JsonSerializable(createToJson: false)
        class In { In(); factory In.fromJson(Map<String, dynamic> json) => In(); }
        ${controller("@Get('/') In get() => In();")}
        ''', '`In` has no `toJson()` method');
    });
  });

  group('schemas', () {
    test('a DTO without @JsonSerializable', () async {
      await expectError(
        '$_handWritten\n${controller("@Get('/') HandWritten get() => throw 0;")}',
        'Cannot infer the JSON schema of `HandWritten`: it is not annotated with @JsonSerializable.',
      );
    });

    test('a generic DTO', () async {
      await expectError(
        '''
        @JsonSerializable(genericArgumentFactories: true)
        class Page<T> {
          final List<T> items;
          Page(this.items);
          Map<String, dynamic> toJson() => {};
        }
        ${controller("@Get('/') Page<String> get() => throw 0;")}
        ''',
        'Cannot infer the JSON schema of `Page`: only non-generic classes are supported.',
      );
    });

    test('a field with a JsonConverter', () async {
      await expectError(
        '''
        class Epoch implements JsonConverter<DateTime, int> {
          const Epoch();
          @override DateTime fromJson(int json) => DateTime(0);
          @override int toJson(DateTime value) => 0;
        }
        @JsonSerializable()
        class Dto {
          @Epoch() final DateTime at;
          Dto(this.at);
          factory Dto.fromJson(Map<String, dynamic> json) => throw 0;
          Map<String, dynamic> toJson() => {};
        }
        ${controller("@Get('/') Dto get() => throw 0;")}
        ''',
        'Cannot infer the JSON schema of `Dto.at`: it uses a JsonConverter.',
      );
    });

    test('a class-level converter applying to a field', () async {
      await expectError('''
        class Epoch implements JsonConverter<DateTime, int> {
          const Epoch();
          @override DateTime fromJson(int json) => DateTime(0);
          @override int toJson(DateTime value) => 0;
        }
        @JsonSerializable(converters: [Epoch()])
        class Dto {
          final DateTime at;
          Dto(this.at);
          factory Dto.fromJson(Map<String, dynamic> json) => throw 0;
          Map<String, dynamic> toJson() => {};
        }
        ${controller("@Get('/') Dto get() => throw 0;")}
        ''', 'a JsonConverter of the class applies to it');
    });

    test('a field with JsonKey toJson', () async {
      await expectError('''
        String _enc(DateTime v) => '';
        @JsonSerializable()
        class Dto {
          @JsonKey(toJson: _enc) final DateTime at;
          Dto(this.at);
          factory Dto.fromJson(Map<String, dynamic> json) => throw 0;
          Map<String, dynamic> toJson() => {};
        }
        ${controller("@Get('/') Dto get() => throw 0;")}
        ''', 'it uses JsonKey fromJson/toJson functions');
    });

    test('a field type without JSON mapping', () async {
      await expectError('''
        @JsonSerializable()
        class Dto {
          final Duration timeout;
          Dto(this.timeout);
          factory Dto.fromJson(Map<String, dynamic> json) => throw 0;
          Map<String, dynamic> toJson() => {};
        }
        ${controller("@Get('/') Dto get() => throw 0;")}
        ''', 'Field `Dto.timeout`');
    });

    test('two classes with the same schema name in one library', () async {
      await expectError('''
        @ApiSchema(name: 'Same') @JsonSerializable()
        class A { A(); factory A.fromJson(Map<String, dynamic> j) => A(); Map<String, dynamic> toJson() => {}; }
        @ApiSchema(name: 'Same') @JsonSerializable()
        class B { B(); factory B.fromJson(Map<String, dynamic> j) => B(); Map<String, dynamic> toJson() => {}; }
        ${controller("""
          @Get('/a') A a() => A();
          @Get('/b') B b() => B();
        """)}
        ''', 'Two classes map to the schema `Same`');
    });

    test('two classes with the same name in different libraries', () async {
      const dto = '''
        import 'package:json_annotation/json_annotation.dart';
        @JsonSerializable()
        class Item { Item(); factory Item.fromJson(Map<String, dynamic> j) => Item(); Map<String, dynamic> toJson() => {}; }
      ''';
      const otherController = '''
        import 'package:shelf_controller/shelf_controller.dart';
        import 'b.dart';
        part 'other.g.dart';
        @Controller('/b')
        class BController { @Get('/', operationId: 'b') Item get() => Item(); }
      ''';
      const inputController = '''
        import 'package:shelf_controller/shelf_controller.dart';
        import 'a.dart';
        part 'input.g.dart';
        @Controller('/a')
        class AController { @Get('/', operationId: 'a') Item get() => Item(); }
      ''';
      await expectError(
        '',
        allOf(
          contains('Two classes map to the schema `Item`'),
          contains('@ApiSchema(name: ...)'),
        ),
        otherSources: {
          'lib/input.dart': inputController,
          'lib/a.dart': dto,
          'lib/b.dart': dto,
          'lib/other.dart': otherController,
        },
      );
    });

    test('@ApiDiscriminator without subtypes', () async {
      await expectError('''
        @ApiDiscriminator('type')
        sealed class Shape { factory Shape.fromJson(Map<String, dynamic> j) => throw 0; Map<String, dynamic> toJson(); }
        ${controller("@Post('/') void post(@Body() Shape s) {}")}
        ''', '`Shape` has @ApiDiscriminator but no subtypes in its library.');
    });
  });

  group('assembly', () {
    test('duplicate operationIds across controllers', () async {
      await expectError(
        '''
        @Controller('/a') class AController { @Get('/') String list() => ''; }
        @Controller('/b') class BController { @Get('/') String list() => ''; }
        ''',
        'operationId `list` is used by both AController.list and BController.list',
      );
    });

    test('the same route in two controllers', () async {
      await expectError(
        '''
        @Controller('/a') class AController { @Get('/', operationId: 'a') String a() => ''; }
        @Controller('/a') class BController { @Get('/', operationId: 'b') String b() => ''; }
        ''',
        'Route GET /a is declared by both AController.a and BController.b.',
      );
    });

    test('an undefined security scheme', () async {
      await expectError(
        controller("@Get('/') @ApiSecurity('oauth') String get() => '';"),
        'Security scheme `oauth` is not defined',
      );
    });

    test('an unknown option', () async {
      await expectError(
        controller("@Get('/') String get() => '';"),
        'Unknown shelf_controller_generator options: title',
        buildYaml: '''
targets:
  \$default:
    builders:
      shelf_controller_generator:
        options:
          title: Oops
''',
      );
    });
  });
}
