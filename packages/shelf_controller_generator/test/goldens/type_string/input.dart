import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

/// `String` maps to `type: string`.
@JsonSerializable()
class Dto {
  final String value;

  /// Nullable variant.
  final String? optional;

  Dto({required this.value, required this.optional});

  factory Dto.fromJson(Map<String, dynamic> json) => throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

@Controller('/type-string')
class TypeController {
  @Post('/<id>')
  String echo(@Path() String id, @Query() String q, @Body() String body) =>
      body;

  @Get('/dto')
  Dto dto() => throw UnimplementedError();
}
