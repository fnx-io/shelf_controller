import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

@Controller('/visible')
class VisibleController {
  @Get('/')
  String shown() => '';

  /// Routed but missing from the spec.
  @Get('/hidden')
  @ApiHidden()
  String hidden() => '';

  @Get('/old')
  @Deprecated('Use shown')
  String old() => '';

  @Get('/older')
  @deprecated
  String older() => '';
}

/// A controller hidden as a whole; its tag is not listed either.
@Controller('/internal', tag: 'Internal')
@ApiHidden()
class InternalController {
  @Get('/')
  String status() => '';
}
