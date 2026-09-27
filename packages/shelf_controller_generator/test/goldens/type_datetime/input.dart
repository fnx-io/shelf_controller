import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

/// `DateTime` maps to `format: date-time`.
@JsonSerializable()
class Dto {
  final DateTime at;

  Dto({required this.at});

  factory Dto.fromJson(Map<String, dynamic> json) => throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

@Controller('/type-datetime')
class TypeController {
  @Post('/')
  DateTime echo(@Query() DateTime since, @Body() DateTime body) => body;

  @Get('/dto')
  Dto dto() => throw UnimplementedError();
}
