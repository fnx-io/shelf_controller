import 'package:shelf_controller_generator/src/doc_text.dart';
import 'package:shelf_controller_generator/src/model/route_path.dart';
import 'package:shelf_controller_generator/src/openapi/json_serializable_config.dart';
import 'package:shelf_controller_generator/src/openapi/openapi_options.dart';
import 'package:test/test.dart';

void main() {
  group('RoutePath', () {
    test('joins the controller prefix and the operation path', () {
      expect(RoutePath.join('/api/projects', '/').shelfPath, '/api/projects');
      expect(
        RoutePath.join('/api/projects/', '/<id>').shelfPath,
        '/api/projects/<id>',
      );
      expect(RoutePath.join('', 'health').shelfPath, '/health');
      expect(RoutePath.join('/', '/').shelfPath, '/');
    });

    test('extracts parameters with optional patterns', () {
      final path = RoutePath('/a/<id|[0-9]+>/b/<name>');
      expect(path.params.map((p) => (p.name, p.pattern)), [
        ('id', '[0-9]+'),
        ('name', null),
      ]);
      expect(path.openApiPath, '/a/{id}/b/{name}');
    });
  });

  group('DocText', () {
    test('splits the first paragraph from the rest', () {
      final doc = DocText.parse(
        '/// Creates a project\n/// quickly.\n///\n/// Details\n/// - item',
      );
      expect(doc.summary, 'Creates a project quickly.');
      expect(doc.description, 'Details\n- item');
      expect(doc.fullText, 'Creates a project quickly.\n\nDetails\n- item');
    });

    test('handles block comments and missing comments', () {
      expect(DocText.parse('/**\n * Summary.\n */').summary, 'Summary.');
      expect(DocText.parse(null).fullText, isNull);
    });
  });

  group('FieldRename', () {
    test('renames like json_serializable', () {
      expect(FieldRename.none.apply('createdAt'), 'createdAt');
      expect(FieldRename.snake.apply('createdAtUtc'), 'created_at_utc');
      expect(FieldRename.kebab.apply('createdAt'), 'created-at');
      expect(FieldRename.pascal.apply('createdAt'), 'CreatedAt');
      expect(FieldRename.screamingSnake.apply('createdAt'), 'CREATED_AT');
    });

    test('parses build.yaml names', () {
      expect(FieldRename.parse('screaming_snake'), FieldRename.screamingSnake);
      expect(() => FieldRename.parse('camel'), throwsArgumentError);
    });
  });

  group('JsonSerializableDefaults', () {
    test('reads field_rename from any json_serializable builder key', () {
      for (final key in [
        'json_serializable',
        'json_serializable:json_serializable',
      ]) {
        final defaults = JsonSerializableDefaults.fromBuildYaml('''
targets:
  \$default:
    builders:
      $key:
        options:
          field_rename: kebab
''');
        expect(defaults.fieldRename, FieldRename.kebab, reason: key);
      }
    });

    test('defaults to no renaming', () {
      expect(
        JsonSerializableDefaults.fromBuildYaml(null).fieldRename,
        FieldRename.none,
      );
      expect(
        JsonSerializableDefaults.fromBuildYaml('targets: {}').fieldRename,
        FieldRename.none,
      );
    });
  });

  group('OpenApiOptions', () {
    test('uses Problem Details by default', () {
      final options = OpenApiOptions.fromConfig({});
      expect(options.output, 'openapi.yaml');
      expect(options.errorSchema?.name, 'ProblemDetails');
    });

    test('can disable or replace the error schema', () {
      expect(
        OpenApiOptions.fromConfig({'problemDetails': false}).errorSchema,
        isNull,
      );
      final custom = OpenApiOptions.fromConfig({
        'errorSchema': {
          'name': 'Err',
          'schema': {'type': 'object'},
        },
      }).errorSchema!;
      expect(custom.name, 'Err');
      expect(custom.contentType, 'application/json');
      expect(custom.schema, {'type': 'object'});
    });

    test('rejects unknown options', () {
      expect(
        () => OpenApiOptions.fromConfig({'infos': {}}),
        throwsArgumentError,
      );
    });
  });
}
