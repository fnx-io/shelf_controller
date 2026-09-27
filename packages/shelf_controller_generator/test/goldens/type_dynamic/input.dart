import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

/// `dynamic` and `Object?` accept any JSON value.
@JsonSerializable()
class Dto {
  final dynamic anything;
  final Object? value;
  final Map<String, dynamic> extra;

  Dto({required this.anything, required this.value, required this.extra});

  factory Dto.fromJson(Map<String, dynamic> json) => throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

@Controller('/type-dynamic')
class TypeController {
  @Post('/')
  Object? echo(@Body() Map<String, Object?> body) => body['value'];

  @Get('/dto')
  Dto dto() => throw UnimplementedError();
}
