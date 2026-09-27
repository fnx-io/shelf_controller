import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

/// Nullable types add `null` to `type`, or wrap a `$ref` in `oneOf`.
@JsonSerializable()
class Dto {
  final String? text;
  final List<int?>? items;
  final Child? child;

  Dto({required this.text, required this.items, required this.child});

  factory Dto.fromJson(Map<String, dynamic> json) => throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

/// A nested object.
@JsonSerializable()
class Child {
  final String name;

  Child({required this.name});

  factory Child.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

@Controller('/type-nullable')
class TypeController {
  @Post('/')
  Dto? echo(@Body() Dto? body, @Query() int? page) => body;

  @Get('/children')
  List<Child?> children() => [];

  @Get('/dto')
  Dto dto() => throw UnimplementedError();
}
