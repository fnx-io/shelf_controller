import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

/// `Map<String, T>` maps to `additionalProperties`.
@JsonSerializable()
class Dto {
  final Map<String, int> counts;
  final Map<String, List<String>> groups;

  Dto({required this.counts, required this.groups});

  factory Dto.fromJson(Map<String, dynamic> json) => throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

@Controller('/type-map')
class TypeController {
  @Post('/')
  Map<String, Dto> echo(@Body() Map<String, Dto> body) => body;

  @Get('/dto')
  Dto dto() => throw UnimplementedError();
}
