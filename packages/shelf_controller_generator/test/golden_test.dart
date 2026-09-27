/// Golden tests: every directory in `test/goldens` holds an input library
/// with the expected generated router part and `openapi.yaml`.
///
/// Run with `UPDATE_GOLDENS=1 dart test test/golden_test.dart` to rewrite
/// the expected files after an intended change, then review the diff.
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'support/generate.dart';

final _update = Platform.environment['UPDATE_GOLDENS'] == '1';

void main() {
  final cases =
      Directory('test/goldens').listSync().whereType<Directory>().toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final directory in cases) {
    test(p.basename(directory.path), () async {
      final sources = {
        for (final file in directory.listSync().whereType<File>())
          if (file.path.endsWith('.dart') && !file.path.endsWith('.g.dart'))
            'lib/${p.basename(file.path)}': file.readAsStringSync(),
      };
      final buildYaml = File(p.join(directory.path, 'build.yaml'));

      final generated = await generate(
        sources,
        buildYaml: buildYaml.existsSync() ? buildYaml.readAsStringSync() : null,
      );

      expect(generated.errors, isEmpty);
      _compare(
        File(p.join(directory.path, 'input.g.dart')),
        generated.parts['lib/input.g.dart'],
      );
      _compare(File(p.join(directory.path, 'openapi.yaml')), generated.openApi);
    });
  }
}

void _compare(File golden, String? actual) {
  if (_update) {
    if (actual == null) {
      if (golden.existsSync()) golden.deleteSync();
    } else {
      golden.writeAsStringSync(actual);
    }
    return;
  }
  expect(
    actual,
    golden.existsSync() ? golden.readAsStringSync() : isNull,
    reason:
        'Output differs from ${golden.path}; rerun with UPDATE_GOLDENS=1 '
        'if the change is intended.',
  );
}
