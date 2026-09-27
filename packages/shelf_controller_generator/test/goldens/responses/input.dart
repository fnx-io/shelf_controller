import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

@JsonSerializable()
class ErrorDto {
  final String code;

  ErrorDto(this.code);

  factory ErrorDto.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}

@Controller('/responses')
@ApiResponse(401)
@ApiResponse(503, description: 'Maintenance')
class ResponsesController {
  /// `void` responds with 204 and no content.
  @Delete('/')
  void remove() {}

  /// `Future<void>` with an explicit status.
  @Post('/accept')
  @Status(202)
  Future<void> accept() async {}

  /// A method annotation overrides the class one with the same code.
  @Get('/typed-error')
  @ApiResponse(503, type: ErrorDto, description: 'Down for maintenance')
  @ApiResponse(422, type: List<ErrorDto>)
  String typedError() => '';

  /// A raw Response documented with @ApiResponse.
  @Get('/file')
  @ApiResponse(
    200,
    type: String,
    contentType: 'text/plain',
    description: 'The file',
  )
  Response file() => Response.ok('');

  /// A raw Response without documentation keeps a bare success response.
  @Get('/raw')
  @Status(302)
  Future<Response> redirect() async => Response.found('/');

  /// `FutureOr` results are awaited too.
  @Get('/future-or')
  Future<int> count() async => 1;
}
