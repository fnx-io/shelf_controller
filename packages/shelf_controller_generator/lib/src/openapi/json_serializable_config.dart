import 'package:analyzer/dart/constant/value.dart';
import 'package:yaml/yaml.dart';

/// `FieldRename` of json_annotation, reimplemented to match json_serializable.
enum FieldRename {
  none,
  kebab,
  snake,
  pascal,
  screamingSnake;

  /// Returns the renaming named [name], as used in `build.yaml` or by the
  /// enum constant name.
  static FieldRename parse(String name) => switch (name) {
    'none' => none,
    'kebab' => kebab,
    'snake' => snake,
    'pascal' => pascal,
    'screamingSnake' || 'screaming_snake' => screamingSnake,
    _ => throw ArgumentError.value(name, 'field_rename', 'Unknown renaming'),
  };

  /// Returns the renaming referenced by an annotation field, or `null`.
  static FieldRename? fromConstant(DartObject? value) {
    if (value == null || value.isNull) return null;
    final index = value.getField('index')?.toIntValue();
    return index == null ? null : FieldRename.values[index];
  }

  /// Applies the renaming to a Dart member [name].
  String apply(String name) => switch (this) {
    none => name,
    kebab => _separated(name, '-'),
    snake => _separated(name, '_'),
    pascal => name.isEmpty ? name : name[0].toUpperCase() + name.substring(1),
    screamingSnake => _separated(name, '_').toUpperCase(),
  };

  static final _upperCase = RegExp('[A-Z]');

  static String _separated(String name, String separator) =>
      name.replaceAllMapped(_upperCase, (match) {
        final lower = match[0]!.toLowerCase();
        return match.start > 0 ? '$separator$lower' : lower;
      });
}

/// Global json_serializable options of the application, read from the
/// `json_serializable` builder options in its `build.yaml`.
class JsonSerializableDefaults {
  final FieldRename fieldRename;

  const JsonSerializableDefaults({this.fieldRename = FieldRename.none});

  /// Parses the content of a `build.yaml`; `null` yields the defaults.
  factory JsonSerializableDefaults.fromBuildYaml(String? content) {
    if (content == null) return const JsonSerializableDefaults();
    final options = _findOptions(loadYaml(content));
    final fieldRename = options?['field_rename'];
    return JsonSerializableDefaults(
      fieldRename: fieldRename is String
          ? FieldRename.parse(fieldRename)
          : FieldRename.none,
    );
  }

  static const _builderKeys = [
    'json_serializable',
    'json_serializable:json_serializable',
    'json_serializable|json_serializable',
  ];

  static Map<Object?, Object?>? _findOptions(Object? yaml) {
    if (yaml is! Map) return null;
    final targets = yaml['targets'];
    if (targets is! Map) return null;
    for (final target in targets.values) {
      final builders = target is Map ? target['builders'] : null;
      if (builders is! Map) continue;
      for (final key in _builderKeys) {
        final builder = builders[key];
        final options = builder is Map ? builder['options'] : null;
        if (options is Map) return options;
      }
    }
    return null;
  }
}
