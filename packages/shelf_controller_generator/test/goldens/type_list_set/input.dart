import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

/// `List<T>` and `Set<T>` map to arrays, sets with `uniqueItems`.
@JsonSerializable()
class Dto {
  final List<String> names;
  final Set<int> ids;
  final List<List<double>> matrix;

  Dto({required this.names, required this.ids, required this.matrix});

  factory Dto.fromJson(Map<String, dynamic> json) => throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

@Controller('/type-list-set')
class TypeController {
  @Post('/')
  Set<Dto> echo(@Query() List<int> id, @Body() List<Dto> body) => body.toSet();

  @Get('/dto')
  Dto dto() => throw UnimplementedError();
}
