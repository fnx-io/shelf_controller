import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

/// A geometric shape.
@ApiDiscriminator('kind', mapping: {'round': Circle})
sealed class Shape {
  const Shape();

  factory Shape.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();

  Map<String, dynamic> toJson();
}

/// Mapped explicitly to `round`.
@JsonSerializable()
class Circle extends Shape {
  final double radius;

  const Circle(this.radius);

  @override
  Map<String, dynamic> toJson() => throw UnimplementedError();
}

/// Uses its schema name as the discriminator value.
@JsonSerializable()
class Square extends Shape {
  /// A class that declares the discriminator itself keeps its schema.
  final String kind;
  final double side;

  const Square(this.kind, this.side);

  @override
  Map<String, dynamic> toJson() => throw UnimplementedError();
}

@Controller('/shapes')
class ShapesController {
  @Post('/')
  List<Shape> add(@Body() Shape shape) => [shape];
}
