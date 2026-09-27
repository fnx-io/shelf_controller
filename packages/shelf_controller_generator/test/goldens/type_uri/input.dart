import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

/// `Uri` maps to `format: uri`.
@JsonSerializable()
class Dto {
  final Uri link;

  Dto({required this.link});

  factory Dto.fromJson(Map<String, dynamic> json) => throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

@Controller('/type-uri')
class TypeController {
  @Post('/')
  Uri echo(@Query() Uri target, @Body() Uri body) => body;

  @Get('/dto')
  Dto dto() => throw UnimplementedError();
}
