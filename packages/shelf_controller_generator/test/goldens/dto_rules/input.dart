import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

enum Level { low, high }

/// Fields shared through inheritance come first.
abstract class Base {
  /// Identifier from the base class.
  final String id;

  Base(this.id);
}

/// Rules of json_serializable reflected in the schema.
///
/// The global `field_rename: snake` from build.yaml applies.
@JsonSerializable()
class RulesDto extends Base {
  /// Renamed globally to `display_name`.
  final String displayName;

  /// Renamed explicitly.
  @JsonKey(name: 'x-custom')
  final int custom;

  /// Required although nullable.
  @JsonKey(required: true)
  final String? mandatory;

  /// Not required thanks to the default value.
  @JsonKey(defaultValue: 5)
  final int withDefault;

  /// Not required thanks to the constructor default.
  final Level level;

  /// Only read from JSON.
  @JsonKey(includeToJson: false)
  final String password;

  /// Only written to JSON.
  @JsonKey(includeFromJson: false, includeToJson: true)
  final DateTime? updatedAt;

  /// Getters are serialized only when asked to.
  @JsonKey(includeToJson: true)
  String get summary => '$displayName ($custom)';

  /// Ignored entirely.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String secret = '';

  /// Not settable, so json_serializable skips it.
  final String computed = 'x';

  final String _private;

  /// Constraints from @ApiField.
  @ApiField(minLength: 3, maxLength: 20, pattern: r'^[a-z]+$', example: 'abc')
  final String constrained;

  RulesDto(
    super.id,
    this.displayName,
    this.custom,
    this.mandatory,
    this.password,
    this.constrained, {
    this.updatedAt,
    this.withDefault = 5,
    this.level = Level.high,
  }) : _private = '';

  factory RulesDto.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

/// Class-level fieldRename overrides the global option.
@JsonSerializable(fieldRename: FieldRename.pascal, createFactory: false)
class ResponseOnlyDto {
  final String firstName;

  ResponseOnlyDto(this.firstName);

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

@Controller('/rules')
class RulesController {
  @Post('/')
  ResponseOnlyDto create(@Body() RulesDto body) => throw UnimplementedError();
}
