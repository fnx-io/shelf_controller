import 'package:shelf_controller/shelf_controller.dart';

import 'dto.dart';

part 'me_controller.g.dart';

/// The signed-in user.
///
/// The controller is created per request, so it can hold the user resolved
/// by middleware.
@Controller('/api/v1/me', tag: 'Me')
class MeController {
  final UserDto? _user;

  MeController(this._user);

  /// Returns the signed-in user.
  @Get('/')
  UserDto whoAmI() => _user ?? (throw HttpProblem(401));

  /// Checks that the service is running.
  @Get('/ping')
  @ApiSecurity.none()
  Map<String, String> ping() => {'status': 'ok'};

  /// Echoes request details; for debugging only.
  @Get('/debug')
  @ApiHidden()
  Map<String, Object?> debug(Request request) => {
    'route': RouteInfo.of(request)?.operationId,
    'user': _user?.login,
  };
}
