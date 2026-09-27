import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

@Controller('/errors')
class ErrorsController {
  @Get('/<id>')
  @ApiResponse(404)
  String find(@Path() String id) => id;
}
