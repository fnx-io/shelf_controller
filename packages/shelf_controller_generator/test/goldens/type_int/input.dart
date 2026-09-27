import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

/// `int` maps to `type: integer, format: int64`.
@JsonSerializable()
class Dto {
  final int value;
  final int? optional;

  Dto({required this.value, required this.optional});

  factory Dto.fromJson(Map<String, dynamic> json) => throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

@Controller('/type-int')
class TypeController {
  @Post('/<id>')
  int echo(@Path() int id, @Query() int q, @Body() int body) => body;

  @Get('/dto')
  Dto dto() => throw UnimplementedError();
}
