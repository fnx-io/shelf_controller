/// Validates every generated `openapi.yaml` with Redocly CLI.
///
/// Requires `npx` (Node.js); the test is skipped when it is missing.
@Tags(['validator'])
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final hasNpx = _hasNpx();

  test(
    'generated specs are valid OpenAPI 3.1',
    () async {
      final specs = [
        for (final directory in Directory(
          'test/goldens',
        ).listSync().whereType<Directory>())
          if (File(p.join(directory.path, 'openapi.yaml')) case final file
              when file.existsSync())
            file.path,
        if (File('../../example/openapi.yaml') case final file
            when file.existsSync())
          file.path,
      ]..sort();
      expect(specs, isNotEmpty);

      final result = await Process.run('npx', [
        '--yes',
        '@redocly/cli@2',
        'lint',
        '--config',
        'test/redocly.yaml',
        '--format',
        'stylish',
        ...specs,
      ]);

      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    },
    skip: hasNpx ? false : 'npx is not available',
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

bool _hasNpx() {
  try {
    return Process.runSync('npx', ['--version']).exitCode == 0;
  } on ProcessException {
    return false;
  }
}
