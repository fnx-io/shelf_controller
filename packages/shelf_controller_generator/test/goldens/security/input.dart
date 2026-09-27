import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

@Controller('/global')
class GlobalController {
  /// Inherits the global security.
  @Get('/')
  String inherited() => '';

  /// Public operation.
  @Get('/public')
  @ApiSecurity.none()
  String public() => '';

  /// Authentication is optional.
  @Get('/optional')
  @ApiSecurity.none()
  @ApiSecurity('bearer')
  String optional() => '';
}

@Controller('/oauth')
@ApiSecurity('oauth', scopes: ['read'])
class OAuthController {
  /// Inherits the controller requirement.
  @Get('/')
  String read() => '';

  /// Overrides it with alternatives.
  @Post('/')
  @ApiSecurity('oauth', scopes: ['read', 'write'])
  @ApiSecurity('bearer')
  String write() => '';
}
