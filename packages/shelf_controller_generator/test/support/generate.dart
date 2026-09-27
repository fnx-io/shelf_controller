import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:logging/logging.dart';
import 'package:shelf_controller_generator/shelf_controller_generator.dart';
import 'package:shelf_controller_generator/src/openapi/fragment_builder.dart';
import 'package:shelf_controller_generator/src/openapi/json_serializable_config.dart';
import 'package:shelf_controller_generator/src/openapi/openapi_builder.dart';
import 'package:shelf_controller_generator/src/openapi/openapi_options.dart';
import 'package:source_gen/builder.dart';
import 'package:yaml/yaml.dart';

/// The package the test sources belong to.
const testPackage = 'app';

/// The outputs of running all builders over a set of sources.
class Generated {
  /// Generated parts by library path, for example `lib/input.g.dart`.
  final Map<String, String> parts;

  /// The generated `openapi.yaml`, if any.
  final String? openApi;

  /// Severe log messages, which fail a real build.
  final List<String> errors;

  const Generated(this.parts, this.openApi, this.errors);

  bool get succeeded => errors.isEmpty;
}

/// Runs the router, fragment and OpenAPI builders like `build_runner` would.
///
/// [sources] map paths relative to the package root (`lib/input.dart`) to
/// their content. [buildYaml] is the application `build.yaml`, providing
/// both generator options and json_serializable defaults.
Future<Generated> generate(
  Map<String, String> sources, {
  String? buildYaml,
}) async {
  final (options, jsonDefaults) = _readBuildYaml(buildYaml);
  final errors = <String>[];
  final combining = combiningBuilder();
  final OpenApiBuilder openApi;
  try {
    openApi = OpenApiBuilder(OpenApiOptions.fromConfig(options));
  } on ArgumentError catch (e) {
    return Generated(const {}, null, ['${e.message}']);
  }
  final readerWriter = TestReaderWriter(rootPackage: testPackage);
  await readerWriter.testing.loadIsolateSources();
  final result = await testBuilders(
    [
      routerBuilder(BuilderOptions.empty),
      combining,
      OpenApiFragmentBuilder(jsonDefaults),
      openApi,
    ],
    {
      for (final MapEntry(:key, :value) in sources.entries)
        '$testPackage|$key': value,
    },
    rootPackage: testPackage,
    readerWriter: readerWriter,
    visibleOutputBuilders: {combining, openApi},
    onLog: (record) {
      if (record.level >= Level.SEVERE) {
        errors.add('${record.message}${record.error ?? ''}');
      }
    },
  );
  final written = result.readerWriter.testing;
  String? read(String path) {
    final id = AssetId(testPackage, path);
    return written.exists(id) ? written.readString(id) : null;
  }

  final partPaths = [
    for (final path in sources.keys)
      path.replaceFirst(RegExp(r'\.dart$'), '.g.dart'),
  ];
  return Generated(
    {for (final path in partPaths) path: ?read(path)},
    read(options['output'] as String? ?? 'openapi.yaml'),
    [...errors, ...result.errors],
  );
}

(Map<String, Object?>, JsonSerializableDefaults) _readBuildYaml(
  String? content,
) {
  if (content == null) return (const {}, const JsonSerializableDefaults());
  final yaml = loadYaml(content) as YamlMap;
  final builders =
      (yaml['targets'] as YamlMap)[r'$default']['builders'] as YamlMap;
  final options =
      (builders['shelf_controller_generator'] as YamlMap?)?['options'];
  return (
    options == null ? const {} : Map<String, Object?>.from(options as YamlMap),
    JsonSerializableDefaults.fromBuildYaml(content),
  );
}
