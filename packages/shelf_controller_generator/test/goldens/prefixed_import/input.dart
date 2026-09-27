import 'package:shelf_controller/shelf_controller.dart';

import 'dto.dart' as dto;

part 'input.g.dart';

/// DTOs imported with a prefix are referenced with it in generated code.
@Controller('/tickets')
class TicketsController {
  @Post('/<status>')
  List<dto.TicketDto> create(
    @Path() dto.Status status,
    @Body() List<dto.TicketDto> tickets,
  ) => tickets;
}
