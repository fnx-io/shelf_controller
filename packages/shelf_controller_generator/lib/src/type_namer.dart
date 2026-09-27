import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

/// Writes Dart types as source code valid inside a part of [library],
/// including import prefixes.
class TypeNamer {
  final LibraryElement library;

  TypeNamer(this.library);

  /// Returns the source code of [type].
  String nameOf(DartType type) {
    final suffix = type.nullabilitySuffix == NullabilitySuffix.question
        ? '?'
        : '';
    if (type is DynamicType) return 'dynamic';
    if (type is VoidType) return 'void';
    final alias = type.alias;
    if (alias != null) {
      return '${qualifiedName(alias.element)}${_arguments(alias.typeArguments)}$suffix';
    }
    if (type is InterfaceType) {
      return '${qualifiedName(type.element)}${_arguments(type.typeArguments)}$suffix';
    }
    throw InvalidGenerationSource(
      'Type `${type.getDisplayString()}` cannot be referenced from generated code.',
    );
  }

  /// Returns the source code of [type] without a nullability suffix, for
  /// static member access such as `Status.values`.
  String nonNullNameOf(DartType type) {
    final name = nameOf(type);
    return name.endsWith('?') ? name.substring(0, name.length - 1) : name;
  }

  /// Returns the name of [element] with the import prefix it is visible
  /// under in [library].
  String qualifiedName(Element element) {
    final name = element.name!;
    final unit = library.firstFragment;
    if (unit.scope.lookup(name).getter == element) return name;
    for (final prefix in unit.prefixes) {
      if (prefix.scope.lookup(name).getter == element) {
        return '${prefix.name}.$name';
      }
    }
    throw InvalidGenerationSource(
      '`$name` is not visible in ${library.uri}.',
      todo: 'Import the library declaring `$name`.',
    );
  }

  String _arguments(List<DartType> arguments) =>
      arguments.isEmpty ? '' : '<${arguments.map(nameOf).join(', ')}>';
}
