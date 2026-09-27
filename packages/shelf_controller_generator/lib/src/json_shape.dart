import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

/// Thrown when a Dart type has no JSON representation the generator
/// understands.
class UnsupportedTypeException implements Exception {
  final DartType type;
  final String reason;

  UnsupportedTypeException(this.type, this.reason);

  @override
  String toString() => 'Unsupported type `${type.getDisplayString()}`: $reason';
}

/// JSON scalar kinds a Dart type can map to.
enum ScalarKind { string, integer, float, number, boolean, dateTime, uri }

/// The JSON representation of a Dart type.
///
/// Both the router (encoding and decoding) and the OpenAPI schema are derived
/// from the same classification, so they cannot disagree.
sealed class JsonShape {
  /// The classified Dart type.
  final DartType type;

  const JsonShape(this.type);

  bool get isNullable => isNullableType(type);
}

/// Whether [type] admits `null`, including `dynamic`.
bool isNullableType(DartType type) =>
    type is DynamicType || type.nullabilitySuffix == NullabilitySuffix.question;

/// `String`, `int`, `double`, `num`, `bool`, `DateTime` or `Uri`.
class ScalarShape extends JsonShape {
  final ScalarKind kind;

  const ScalarShape(super.type, this.kind);
}

/// A Dart `enum`.
class EnumShape extends JsonShape {
  final EnumElement element;

  const EnumShape(super.type, this.element);
}

/// `List<T>` or `Set<T>`.
class ArrayShape extends JsonShape {
  final JsonShape items;
  final bool isSet;

  const ArrayShape(super.type, this.items, {required this.isSet});
}

/// `Map<String, T>`.
class MapShape extends JsonShape {
  final JsonShape values;

  const MapShape(super.type, this.values);
}

/// A class serialized through `fromJson` and `toJson`.
class ObjectShape extends JsonShape {
  const ObjectShape(InterfaceType super.type);

  InterfaceType get interfaceType => type as InterfaceType;

  InterfaceElement get element => interfaceType.element;
}

/// `dynamic`, `Object` or `Object?`: any JSON value.
class AnyShape extends JsonShape {
  const AnyShape(super.type);
}

/// Classifies [type], throwing [UnsupportedTypeException] for types without
/// a JSON representation.
JsonShape classifyJsonType(DartType type) {
  if (type is DynamicType || type.isDartCoreObject) return AnyShape(type);
  if (type is! InterfaceType) {
    throw UnsupportedTypeException(type, 'it has no JSON representation');
  }
  final scalar = _scalarKindOf(type);
  if (scalar != null) return ScalarShape(type, scalar);
  final element = type.element;
  if (element is EnumElement) return EnumShape(type, element);
  if (type.isDartCoreList || type.isDartCoreSet) {
    return ArrayShape(
      type,
      classifyJsonType(type.typeArguments.single),
      isSet: type.isDartCoreSet,
    );
  }
  if (type.isDartCoreMap) {
    if (!type.typeArguments.first.isDartCoreString) {
      throw UnsupportedTypeException(
        type,
        'only `String` map keys are supported',
      );
    }
    return MapShape(type, classifyJsonType(type.typeArguments.last));
  }
  if (element.library.isInSdk) {
    throw UnsupportedTypeException(type, 'it has no JSON representation');
  }
  return ObjectShape(type);
}

ScalarKind? _scalarKindOf(InterfaceType type) {
  if (type.isDartCoreString) return ScalarKind.string;
  if (type.isDartCoreInt) return ScalarKind.integer;
  if (type.isDartCoreDouble) return ScalarKind.float;
  if (type.isDartCoreNum) return ScalarKind.number;
  if (type.isDartCoreBool) return ScalarKind.boolean;
  if (!type.element.library.isDartCore) return null;
  return switch (type.element.name) {
    'DateTime' => ScalarKind.dateTime,
    'Uri' => ScalarKind.uri,
    _ => null,
  };
}
