import 'dart:convert';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../json_shape.dart';
import '../model/controller_model.dart';
import '../model/controller_reader.dart';
import '../router/router_generator.dart';
import 'fragment.dart';
import 'json_serializable_config.dart';
import 'operation_describer.dart';
import 'schema_builder.dart';

/// Writes the OpenAPI content of the controllers of each library into a
/// `.openapi.json` fragment in the build cache.
class OpenApiFragmentBuilder implements Builder {
  static const extension = '.openapi.json';

  final JsonSerializableDefaults _jsonDefaults;

  OpenApiFragmentBuilder(this._jsonDefaults);

  @override
  Map<String, List<String>> get buildExtensions => const {
    '.dart': [extension],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) return;
    final library = LibraryReader(await buildStep.inputLibrary);
    final controllers = controllerClasses(library);
    if (controllers.isEmpty) return;
    final fragment = describeControllers(
      controllers.map(const ControllerReader().read),
      _jsonDefaults,
    );
    await buildStep.writeAsString(
      buildStep.inputId.changeExtension(extension),
      const JsonEncoder.withIndent('  ').convert(fragment.toJson()),
    );
  }
}

/// Describes the visible operations of [controllers] as an [ApiFragment].
ApiFragment describeControllers(
  Iterable<ControllerModel> controllers,
  JsonSerializableDefaults jsonDefaults,
) {
  final schemas = SchemaBuilder(jsonDefaults);
  final describer = OperationDescriber(schemas);
  final operations = <FragmentOperation>[];
  final tags = <String, String?>{};
  for (final controller in controllers) {
    final visible = controller.operations.where((o) => !o.isHidden).toList();
    if (visible.isEmpty) continue;
    if (controller.tag case final tag?) tags[tag] = controller.doc.fullText;
    for (final operation in visible) {
      try {
        operations.add(describer.describe(controller, operation));
      } on UnsupportedTypeException catch (e) {
        throw InvalidGenerationSource('$e', element: operation.method);
      }
    }
  }
  return ApiFragment(
    operations: operations,
    schemas: schemas.components,
    tags: tags,
  );
}
