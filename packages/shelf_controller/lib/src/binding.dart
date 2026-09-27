/// Functions used by generated routers to bind request values to typed
/// method arguments.
///
/// Every failure is reported as a [BindingException].
library;

import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'problem.dart';
import 'route_info.dart';

/// Converts the raw text of a path, query or header value to [T].
class ParamParser<T> {
  /// The human readable name of the expected format used in error messages.
  final String expected;

  final T Function(String raw) _parse;

  /// Creates a parser that throws a [FormatException] or an [ArgumentError]
  /// on invalid input.
  const ParamParser(this.expected, this._parse);

  /// Accepts any text.
  static const ParamParser<String> string = ParamParser('a string', _identity);

  /// Parses a decimal integer.
  static const ParamParser<int> integer = ParamParser('an integer', int.parse);

  /// Parses a floating point number.
  static const ParamParser<double> float = ParamParser(
    'a number',
    double.parse,
  );

  /// Parses an integer or a floating point number.
  static const ParamParser<num> number = ParamParser('a number', num.parse);

  /// Parses `true` or `false`.
  static const ParamParser<bool> boolean = ParamParser(
    '`true` or `false`',
    _parseBool,
  );

  /// Parses an ISO 8601 date and time.
  static const ParamParser<DateTime> dateTime = ParamParser(
    'an ISO 8601 date-time',
    DateTime.parse,
  );

  /// Parses a URI.
  static const ParamParser<Uri> uri = ParamParser('a URI', Uri.parse);

  /// Creates a parser accepting the names of enum [values].
  static ParamParser<T> enumeration<T extends Enum>(List<T> values) =>
      ParamParser(
        'one of ${values.map((v) => v.name).join(', ')}',
        values.byName,
      );

  /// Parses [raw], throwing a [BindingException] of [parameter] from
  /// [source] when it is invalid.
  T parse(String raw, ParamSource source, String parameter) {
    try {
      return _parse(raw);
    } on FormatException {
      throw BindingException(source, parameter, _invalid(raw));
    } on ArgumentError {
      throw BindingException(source, parameter, _invalid(raw));
    }
  }

  String _invalid(String raw) => "expected $expected, got '$raw'";

  static String _identity(String raw) => raw;

  static bool _parseBool(String raw) => switch (raw) {
    'true' => true,
    'false' => false,
    _ => throw FormatException('Not a boolean', raw),
  };
}

/// Binds a required path, query or header value named [name].
T requireParam<T>(
  Request request,
  ParamSource source,
  String name,
  ParamParser<T> parser,
) {
  final raw = _readSingle(request, source, name);
  if (raw == null) throw BindingException(source, name, 'is required');
  return parser.parse(raw, source, name);
}

/// Binds an optional path, query or header value named [name], returning
/// `null` when it is absent.
T? optionalParam<T>(
  Request request,
  ParamSource source,
  String name,
  ParamParser<T> parser,
) {
  final raw = _readSingle(request, source, name);
  return raw == null ? null : parser.parse(raw, source, name);
}

/// Binds a required repeated query parameter; at least one value must be
/// present.
List<T> requireQueryList<T>(
  Request request,
  String name,
  ParamParser<T> parser,
) {
  final values = optionalQueryList(request, name, parser);
  if (values == null) {
    throw BindingException(ParamSource.query, name, 'is required');
  }
  return values;
}

/// Binds an optional repeated query parameter, returning `null` when it is
/// absent.
List<T>? optionalQueryList<T>(
  Request request,
  String name,
  ParamParser<T> parser,
) {
  final raw = request.url.queryParametersAll[name];
  if (raw == null || raw.isEmpty) return null;
  return [
    for (final value in raw) parser.parse(value, ParamSource.query, name),
  ];
}

String? _readSingle(Request request, ParamSource source, String name) =>
    switch (source) {
      ParamSource.path => _decodePathSegment(request, name),
      ParamSource.query => request.url.queryParameters[name],
      ParamSource.header => request.headers[name],
      ParamSource.body || ParamSource.request => throw ArgumentError.value(
        source,
        'source',
        'Not a single-value source',
      ),
    };

String? _decodePathSegment(Request request, String name) {
  final raw = request.params[name];
  if (raw == null) return null;
  try {
    return Uri.decodeComponent(raw);
  } on ArgumentError {
    throw BindingException(ParamSource.path, name, 'invalid percent-encoding');
  }
}

/// Reads the JSON request body and converts it with [decode].
///
/// An empty body fails unless the body is optional, in which case `null` is
/// returned. Errors thrown by [decode], such as a failed cast or a missing
/// required key in `fromJson`, are reported as a [BindingException].
Future<T> requireBody<T>(
  Request request,
  String name,
  T Function(Object? json) decode,
) async {
  final json = await _readJson(request, name);
  if (json == null) {
    throw BindingException(ParamSource.body, name, 'is required');
  }
  return _decode(json, name, decode);
}

/// Reads an optional JSON request body; see [requireBody].
Future<T?> optionalBody<T>(
  Request request,
  String name,
  T Function(Object? json) decode,
) async {
  final json = await _readJson(request, name);
  return json == null ? null : _decode(json, name, decode);
}

Future<Object?> _readJson(Request request, String name) async {
  final text = await request.readAsString();
  if (text.trim().isEmpty) return null;
  try {
    return jsonDecode(text);
  } on FormatException catch (e) {
    throw BindingException(
      ParamSource.body,
      name,
      'malformed JSON: ${e.message}',
    );
  }
}

T _decode<T>(Object json, String name, T Function(Object? json) decode) {
  try {
    return decode(json);
  } on TypeError catch (e) {
    throw BindingException(ParamSource.body, name, 'unexpected JSON shape: $e');
  } on ArgumentError catch (e) {
    throw BindingException(ParamSource.body, name, '${e.message}');
  } on HttpProblem {
    rethrow;
  } on Exception catch (e) {
    throw BindingException(ParamSource.body, name, '$e');
  }
}

/// Decodes a JSON value that may be `null` with [decode].
T? decodeNullable<T>(Object? json, T Function(Object json) decode) =>
    json == null ? null : decode(json);
