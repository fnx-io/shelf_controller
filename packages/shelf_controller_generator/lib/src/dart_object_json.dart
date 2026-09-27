import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

/// Converts a constant value to a JSON-compatible value.
///
/// Enum constants are converted with [enumValue], which defaults to the name
/// of the constant.
Object? dartObjectToJson(
  DartObject object, {
  Object? Function(FieldElement constant)? enumValue,
}) {
  Object? convert(DartObject value) =>
      dartObjectToJson(value, enumValue: enumValue);

  if (object.isNull) return null;
  final type = object.type;
  if (type != null && type.element is EnumElement) {
    final constant = enumConstantOf(object);
    return enumValue == null ? constant.name : enumValue(constant);
  }
  return object.toBoolValue() ??
      object.toIntValue() ??
      object.toDoubleValue() ??
      object.toStringValue() ??
      object.toListValue()?.map(convert).toList() ??
      object.toSetValue()?.map(convert).toList() ??
      object.toMapValue()?.map(
        (key, value) => MapEntry(
          key?.toStringValue() ??
              _unsupported(object, 'map keys must be strings'),
          value == null ? null : convert(value),
        ),
      ) ??
      _unsupported(object, 'it is not a JSON value');
}

/// Returns the enum constant [object] refers to.
FieldElement enumConstantOf(DartObject object) {
  final element = object.type!.element as EnumElement;
  final index = object.getField('index')?.toIntValue();
  return element.constants.firstWhere(
    (constant) =>
        constant.computeConstantValue()?.getField('index')?.toIntValue() ==
        index,
  );
}

Never _unsupported(DartObject object, String reason) =>
    throw InvalidGenerationSource(
      'Cannot convert constant `$object` to JSON: $reason.',
    );
