import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

/// `double` maps to `format: double`, `num` to a plain number.
@JsonSerializable()
class Dto {
  final double ratio;
  final num amount;

  Dto({required this.ratio, required this.amount});

  factory Dto.fromJson(Map<String, dynamic> json) => throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

@Controller('/type-double-num')
class TypeController {
  @Post('/')
  double echo(@Query() num amount, @Body() double body) => body;

  @Get('/num')
  num number() => 1;

  @Get('/dto')
  Dto dto() => throw UnimplementedError();
}
