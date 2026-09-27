import 'package:analyzer/dart/element/element.dart';

import '../json_shape.dart';
import '../type_namer.dart';

/// Writes Dart expressions converting between JSON values and typed values.
class JsonCodecWriter {
  final TypeNamer _namer;

  JsonCodecWriter(this._namer);

  /// Returns an expression converting the decoded JSON value [json] (of
  /// static type `Object?`) to the type of [shape].
  String decode(JsonShape shape, String json, [int depth = 0]) {
    final value = _decodeNonNull(shape, json, depth);
    return shape.isNullable && shape is! AnyShape
        ? '($json == null ? null : $value)'
        : value;
  }

  String _decodeNonNull(JsonShape shape, String json, int depth) {
    final item = '\$v${depth + 1}';
    return switch (shape) {
      AnyShape() => json,
      ScalarShape(kind: ScalarKind.string) => '$json as String',
      ScalarShape(kind: ScalarKind.integer) => '($json as num).toInt()',
      ScalarShape(kind: ScalarKind.float) => '($json as num).toDouble()',
      ScalarShape(kind: ScalarKind.number) => '$json as num',
      ScalarShape(kind: ScalarKind.boolean) => '$json as bool',
      ScalarShape(kind: ScalarKind.dateTime) =>
        'DateTime.parse($json as String)',
      ScalarShape(kind: ScalarKind.uri) => 'Uri.parse($json as String)',
      EnumShape() =>
        '${_namer.nonNullNameOf(shape.type)}.values.byName($json as String)',
      ArrayShape(:final items, :final isSet) =>
        '${isSet ? '{' : '['}for (final $item in $json as List<Object?>) '
            '${decode(items, item, depth + 1)}${isSet ? '}' : ']'}',
      MapShape(:final values) =>
        '{for (final MapEntry(key: \$k${depth + 1}, value: $item) in '
            '($json as Map<String, Object?>).entries) '
            '\$k${depth + 1}: ${decode(values, item, depth + 1)}}',
      ObjectShape() => _decodeObject(shape, json),
    };
  }

  String _decodeObject(ObjectShape shape, String json) {
    final element = shape.element;
    final fromJson =
        element.getNamedConstructor('fromJson') ?? _staticFromJson(element);
    final input = fromJson?.formalParameters.firstOrNull;
    if (input == null) {
      throw UnsupportedTypeException(
        shape.type,
        '`${element.name}` has no `fromJson` constructor',
      );
    }
    return '${_namer.nonNullNameOf(shape.type)}.fromJson($json as ${_namer.nameOf(input.type)})';
  }

  ExecutableElement? _staticFromJson(InterfaceElement element) {
    final method = element.getMethod('fromJson');
    return method != null && method.isStatic ? method : null;
  }

  /// Returns an expression converting [value] of the type of [shape] to a
  /// JSON-encodable value.
  String encode(JsonShape shape, String value, [int depth = 0]) {
    final member = _encodingMember(shape, depth);
    if (member == null) return value;
    return '$value${shape.isNullable ? '?' : ''}$member';
  }

  /// The member access converting a value to JSON, or `null` when the value
  /// is already JSON-encodable.
  String? _encodingMember(JsonShape shape, int depth) {
    final item = '\$v${depth + 1}';
    return switch (shape) {
      AnyShape() ||
      ScalarShape(
        kind: ScalarKind.string ||
            ScalarKind.integer ||
            ScalarKind.float ||
            ScalarKind.number ||
            ScalarKind.boolean,
      ) => null,
      ScalarShape(kind: ScalarKind.dateTime) => '.toIso8601String()',
      ScalarShape(kind: ScalarKind.uri) => '.toString()',
      EnumShape() => '.name',
      ArrayShape(:final items, :final isSet) => switch (_encodingMember(
        items,
        depth + 1,
      )) {
        null => isSet ? '.toList()' : null,
        _ => '.map(($item) => ${encode(items, item, depth + 1)}).toList()',
      },
      MapShape(:final values) => switch (_encodingMember(values, depth + 1)) {
        null => null,
        _ =>
          '.map((\$k${depth + 1}, $item) => MapEntry(\$k${depth + 1}, ${encode(values, item, depth + 1)}))',
      },
      ObjectShape() => _encodeObject(shape),
    };
  }

  String _encodeObject(ObjectShape shape) {
    final toJson = shape.interfaceType.lookUpMethod(
      'toJson',
      shape.element.library,
    );
    if (toJson == null || toJson.formalParameters.any((p) => p.isRequired)) {
      throw UnsupportedTypeException(
        shape.type,
        '`${shape.element.name}` has no `toJson()` method',
      );
    }
    return '.toJson()';
  }
}
