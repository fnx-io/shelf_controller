import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../checkers.dart';
import '../json_shape.dart';
import '../model/controller_reader.dart';
import '../type_namer.dart';
import 'router_writer.dart';

/// Generates a `<Controller>Router` for every `@Controller` class of a
/// library.
class RouterGenerator extends Generator {
  const RouterGenerator();

  @override
  String? generate(LibraryReader library, BuildStep buildStep) {
    final controllers = controllerClasses(library);
    if (controllers.isEmpty) return null;
    final writer = RouterWriter(TypeNamer(library.element));
    return controllers.map((element) => _write(writer, element)).join('\n\n');
  }

  String _write(RouterWriter writer, ClassElement element) {
    final controller = const ControllerReader().read(element);
    try {
      return writer.write(controller);
    } on UnsupportedTypeException catch (e) {
      throw InvalidGenerationSource('$e', element: element);
    }
  }
}

/// Returns the `@Controller` classes of [library].
List<ClassElement> controllerClasses(LibraryReader library) => [
  for (final annotated in library.annotatedWith(controllerChecker))
    if (annotated.element case final ClassElement element) element,
];
