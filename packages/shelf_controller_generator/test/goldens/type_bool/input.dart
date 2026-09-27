import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

/// `bool` maps to `type: boolean`.
@JsonSerializable()
class Dto {
  final bool flag;

  Dto({required this.flag});

  factory Dto.fromJson(Map<String, dynamic> json) => throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

@Controller('/type-bool')
class TypeController {
  @Post('/')
  bool echo(
    @Query() bool flag,
    @Header('X-Flag') bool? header,
    @Body() bool body,
  ) => body;

  @Get('/dto')
  Dto dto() => throw UnimplementedError();
}
