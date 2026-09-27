import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

/// Classes with `fromJson`/`toJson` become `$ref` components.
@JsonSerializable()
class Dto {
  final Child child;
  final List<Child> children;

  Dto({required this.child, required this.children});

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

@Controller('/type-class-ref')
class TypeController {
  @Post('/')
  Dto echo(@Body() Dto body) => body;

  @Get('/dto')
  Dto dto() => throw UnimplementedError();
}
