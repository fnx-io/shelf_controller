import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

/// Operations with users.
///
/// The controller doc comment becomes the tag description.
@Controller('/api/v2/users', tag: 'Users')
class UsersController {
  @Get('/')
  List<String> list() => [];

  @Get('/<id>', operationId: 'getUser')
  String detail(@Path() String id) => id;
}

@Controller('/api/v1/users', tag: 'Users')
class LegacyUsersController {
  @Get('/', operationId: 'listUsersV1')
  List<String> list() => [];
}

/// Controllers without a tag produce untagged operations.
@Controller('/')
class RootController {
  @Get('/health')
  String health() => 'ok';

  @Put('/api/v2/users/<id>')
  void replace(@Path() String id) {}
}
