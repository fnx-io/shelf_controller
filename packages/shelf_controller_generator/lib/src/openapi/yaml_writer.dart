import 'dart:convert';

/// Serializes JSON-like values (maps, lists, strings, numbers, booleans and
/// `null`) to block-style YAML, preserving map key order.
///
/// Strings are written plain when that is unambiguous, as literal blocks
/// when they span several lines, and double-quoted otherwise.
String toYaml(Object? value) {
  final buffer = StringBuffer();
  _writeValue(buffer, value, 0);
  return buffer.toString();
}

const _indentStep = '  ';

void _writeValue(StringBuffer buffer, Object? value, int indent) {
  switch (value) {
    case Map<Object?, Object?>() when value.isNotEmpty:
      _writeMap(buffer, value, indent);
    case List<Object?>() when value.isNotEmpty:
      _writeList(buffer, value, indent);
    default:
      buffer.writeln(_scalar(value, indent));
  }
}

void _writeMap(StringBuffer buffer, Map<Object?, Object?> map, int indent) {
  final prefix = _indentStep * indent;
  for (final MapEntry(:key, :value) in map.entries) {
    buffer.write('$prefix${_key('$key')}:');
    _writeNested(buffer, value, indent + 1);
  }
}

void _writeList(StringBuffer buffer, List<Object?> list, int indent) {
  final prefix = _indentStep * indent;
  for (final item in list) {
    if (_isCollection(item)) {
      // Start a nested collection on the line of its `-` indicator.
      final nested = StringBuffer();
      _writeValue(nested, item, indent + 1);
      buffer.write(
        '$prefix- ${nested.toString().substring(prefix.length + 2)}',
      );
    } else {
      buffer.writeln('$prefix- ${_scalar(item, indent + 1)}');
    }
  }
}

/// Writes [value] after a `key:` or `-` indicator.
void _writeNested(StringBuffer buffer, Object? value, int indent) {
  if (_isCollection(value)) {
    buffer.writeln();
    _writeValue(buffer, value, indent);
  } else {
    buffer.writeln(' ${_scalar(value, indent)}');
  }
}

bool _isCollection(Object? value) =>
    (value is Map && value.isNotEmpty) || (value is List && value.isNotEmpty);

String _scalar(Object? value, int indent) => switch (value) {
  null => 'null',
  bool() || int() => '$value',
  double() => _double(value),
  String() => _string(value, indent),
  Map() => '{}',
  List() => '[]',
  _ => throw ArgumentError.value(value, 'value', 'Not a JSON value'),
};

String _double(double value) {
  if (value.isNaN || value.isInfinite) {
    throw ArgumentError.value(value, 'value', 'Not a JSON number');
  }
  return value == value.truncateToDouble() && value.abs() < 1e15
      ? value.toStringAsFixed(1)
      : '$value';
}

String _key(String key) => _isPlainSafe(key) ? key : jsonEncode(key);

String _string(String value, int indent) {
  if (_isPlainSafe(value)) return value;
  if (_isLiteralBlockSafe(value)) {
    final chomping = value.endsWith('\n') ? '' : '-';
    final prefix = _indentStep * indent;
    final body = value
        .replaceFirst(RegExp(r'\n$'), '')
        .split('\n')
        .map((line) => line.isEmpty ? '' : '$prefix$line')
        .join('\n');
    return '|$chomping\n$body';
  }
  return jsonEncode(value);
}

// Characters that may start a plain scalar and characters allowed inside it.
// `:` and `#` are excluded entirely to avoid `: ` and ` #` sequences.
final _plain = RegExp(
  r"^[\p{L}\p{N}_$/.(][\p{L}\p{N}_$/.()\-+ ,;!?'&*=<>%@]*$",
  unicode: true,
);
final _numberLike = RegExp(r'^[-+]?(\.?[0-9]|\.(inf|Inf|INF|nan|NaN|NAN))');
const _reserved = {
  'null',
  'Null',
  'NULL',
  '~',
  'true',
  'True',
  'TRUE',
  'false',
  'False',
  'FALSE',
  'yes',
  'Yes',
  'YES',
  'no',
  'No',
  'NO',
  'on',
  'On',
  'ON',
  'off',
  'Off',
  'OFF',
  'y',
  'Y',
  'n',
  'N',
};

bool _isPlainSafe(String value) =>
    value.isNotEmpty &&
    value.trim() == value &&
    _plain.hasMatch(value) &&
    !_numberLike.hasMatch(value) &&
    !_reserved.contains(value);

/// Whether [value] can be written as a `|` block: several lines, no
/// leading whitespace on the first line, no trailing spaces and no control
/// characters other than line feeds.
bool _isLiteralBlockSafe(String value) {
  final content = value.endsWith('\n')
      ? value.substring(0, value.length - 1)
      : value;
  if (!content.contains('\n') || content.endsWith('\n')) return false;
  if (content.startsWith(' ') || content.startsWith('\t')) return false;
  if (RegExp(r'[\x00-\x09\x0b-\x1f\x7f\u2028\u2029\ufeff]').hasMatch(content)) {
    return false;
  }
  return !content.split('\n').any((line) => line.endsWith(' '));
}
