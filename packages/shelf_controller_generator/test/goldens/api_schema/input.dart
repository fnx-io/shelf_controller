import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

/// Custom serialization described by a literal schema.
@ApiSchema(
  schema: {
    'type': 'string',
    'pattern': r'^\d+ [A-Z]{3}$',
    'example': '100 CZK',
  },
)
class Money {
  final int amount;
  final String currency;

  Money(this.amount, this.currency);

  factory Money.fromJson(String json) => throw UnimplementedError();

  String toJson() => '$amount $currency';
}

class Point {
  final int x;
  final int y;

  Point(this.x, this.y);
}

class PointConverter implements JsonConverter<Point, List<int>> {
  const PointConverter();

  @override
  Point fromJson(List<int> json) => Point(json[0], json[1]);

  @override
  List<int> toJson(Point object) => [object.x, object.y];
}

/// Renamed in the spec.
@ApiSchema(name: 'Order')
@JsonSerializable()
class OrderDto {
  final Money price;

  /// A converted field needs an explicit schema.
  @PointConverter()
  @ApiSchema(
    schema: {
      'type': 'array',
      'items': {'type': 'integer'},
      'minItems': 2,
      'maxItems': 2,
    },
  )
  final Point location;

  OrderDto(this.price, this.location);

  factory OrderDto.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

@Controller('/orders')
class OrdersController {
  @Post('/')
  OrderDto create(@Body() OrderDto order) => order;

  @Get('/price')
  Money price() => Money(1, 'CZK');
}
