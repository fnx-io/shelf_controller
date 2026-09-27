/// Builders generating shelf routers and an OpenAPI 3.1 spec from typed
/// controllers.
///
/// Applications do not import this library; `build_runner` finds the builders
/// through `build.yaml`.
library;

import 'dart:io';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/openapi/fragment_builder.dart';
import 'src/openapi/json_serializable_config.dart';
import 'src/openapi/openapi_builder.dart';
import 'src/openapi/openapi_options.dart';
import 'src/router/router_generator.dart';

/// Generates `<Controller>Router` classes into the shared `.g.dart` part.
Builder routerBuilder(BuilderOptions options) =>
    SharedPartBuilder([const RouterGenerator()], 'shelf_controller');

/// Writes the OpenAPI fragment of each library with controllers.
///
/// Global json_serializable options (such as `field_rename`) are read from
/// the `build.yaml` of the package being built, because builder options of
/// other builders are not visible here. Changing `build.yaml` invalidates the
/// whole build, so the fragments never go stale.
Builder openApiFragmentBuilder(BuilderOptions options) {
  final buildYaml = File('build.yaml');
  return OpenApiFragmentBuilder(
    JsonSerializableDefaults.fromBuildYaml(
      buildYaml.existsSync() ? buildYaml.readAsStringSync() : null,
    ),
  );
}

/// Combines the fragments into the `openapi.yaml` of the package.
Builder openApiBuilder(BuilderOptions options) =>
    OpenApiBuilder(OpenApiOptions.fromBuilderOptions(options));
