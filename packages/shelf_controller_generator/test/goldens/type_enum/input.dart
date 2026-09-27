import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

/// Plain enum: JSON values are the Dart names.
enum Plain { first, second }

/// `@JsonValue` sets the JSON value of each constant.
enum Explicit {
  @JsonValue('one')
  first,
  @JsonValue('two')
  second,
}

/// Integer JSON values make an integer enum.
enum Numeric {
  @JsonValue(1)
  low,
  @JsonValue(5)
  high,
}

/// `@JsonEnum(fieldRename:)` renames all constants.
@JsonEnum(fieldRename: FieldRename.kebab)
enum Renamed { firstValue, secondValue }

/// `@JsonEnum(valueField:)` uses a field of the constant.
@JsonEnum(valueField: 'code')
enum Coded {
  alpha('A'),
  beta('B');

  const Coded(this.code);

  final String code;
}

/// `enum` maps to `type: string` with `enum` values as json_serializable
/// writes them.
@JsonSerializable()
class Dto {
  final Plain plain;
  final Explicit explicit;
  final Numeric numeric;
  final Renamed renamed;
  final Coded coded;
  final Explicit? optional;

  Dto({
    required this.plain,
    required this.explicit,
    required this.numeric,
    required this.renamed,
    required this.coded,
    this.optional,
  });

  factory Dto.fromJson(Map<String, dynamic> json) => throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

@Controller('/type-enum')
class TypeController {
  /// Outside of DTOs, enums are bound and serialized by their Dart name.
  @Post('/<kind>')
  Explicit echo(
    @Path() Explicit kind,
    @Query() List<Renamed>? renamed,
    @Body() Numeric body,
  ) => kind;

  @Get('/dto')
  Dto dto() => throw UnimplementedError();
}
