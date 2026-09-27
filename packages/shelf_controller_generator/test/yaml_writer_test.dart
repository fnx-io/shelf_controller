import 'dart:convert';

import 'package:shelf_controller_generator/src/openapi/yaml_writer.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

/// Converts parsed YAML to plain Dart collections for comparison.
Object? plain(Object? yaml) => jsonDecode(jsonEncode(yaml));

void main() {
  group('toYaml', () {
    test('writes nested maps and lists in block style', () {
      expect(
        toYaml({
          'a': {
            'b': [
              1,
              {'c': true, 'd': null},
              [2.5, 'x'],
            ],
          },
          'e': <String, Object?>{},
          'f': <Object?>[],
        }),
        '''
a:
  b:
    - 1
    - c: true
      d: null
    - - 2.5
      - x
e: {}
f: []
''',
      );
    });

    test('quotes only strings that would otherwise change meaning', () {
      expect(
        toYaml({'plain': 'Založí nový projekt.'}),
        'plain: Založí nový projekt.\n',
      );
      expect(
        toYaml({'ref': r'#/components/schemas/X'}),
        'ref: "#/components/schemas/X"\n',
      );
      expect(toYaml({'status': '200'}), 'status: "200"\n');
      expect(toYaml({'bool': 'true'}), 'bool: "true"\n');
      expect(toYaml({'null': 'null'}), '"null": "null"\n');
      expect(toYaml({'/a/{id}': 1}), '"/a/{id}": 1\n');
    });

    test('writes multi-line text as a literal block', () {
      expect(
        toYaml({'description': 'First.\n\n- item\n  indented'}),
        'description: |-\n  First.\n\n  - item\n    indented\n',
      );
    });

    test('writes whole doubles with a fraction', () {
      expect(toYaml({'x': 5.0, 'z': 1e21}), 'x: 5.0\nz: 1e+21\n');
    });

    test('rejects values that are not JSON', () {
      expect(() => toYaml({'x': DateTime(2000)}), throwsArgumentError);
      expect(() => toYaml({'x': double.nan}), throwsArgumentError);
    });

    const tricky = [
      '',
      ' ',
      'a: b',
      'a #b',
      '#comment',
      '- item',
      '? key',
      '*alias',
      '&anchor',
      '!tag',
      '%directive',
      '@at',
      '`tick`',
      '|',
      '>',
      "'single'",
      '"double"',
      '{flow}',
      '[flow]',
      'trailing ',
      ' leading',
      'yes',
      'No',
      'on',
      '~',
      '0x10',
      '1e3',
      '.5',
      '-1',
      '+1',
      '.inf',
      '.NaN',
      '1.0.0',
      '2026-09-27',
      '12:30',
      'tab\there',
      'line\nbreak',
      'ends with newline\n',
      'two\n\nparagraphs\n\n',
      '\nstarts with newline',
      'trailing space \nline',
      'carriage\rreturn',
      'unicode ✓ 😀 ž',
      'line separator',
      'back\\slash',
      'nul\u0000byte',
      'a,b;c!d?e&f*g=h<i>j%k@l',
    ];

    for (final value in tricky) {
      test('round-trips ${jsonEncode(value)}', () {
        final document = {
          value: value,
          'list': [value],
          'nested': {'key': value},
        };
        expect(plain(loadYaml(toYaml(document))), document);
      });
    }
  });
}
