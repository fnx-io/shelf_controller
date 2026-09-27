import 'package:shelf_controller/shelf_controller.dart';

import 'dto.dart';

/// Restricts an operation to users with one of [roles].
///
/// The generator knows nothing about this annotation; it only copies it into
/// [RouteInfo.annotations], where [authorize] finds it.
class Secured {
  final List<String> roles;

  const Secured(this.roles);
}

const _userKey = 'example/user';

/// Resolves the user from the `Authorization: Bearer <login>` header.
///
/// A real application would verify a token; the example trusts the login
/// and makes `admin` an administrator.
Middleware authenticate() =>
    (inner) => (request) {
      final header = request.headers['authorization'];
      final login = header != null && header.startsWith('Bearer ')
          ? header.substring('Bearer '.length)
          : null;
      if (login == null) return inner(request);
      final user = UserDto(
        login: login,
        roles: {'user', if (login == 'admin') 'admin'},
      );
      return inner(request.change(context: {_userKey: user}));
    };

/// Returns the user resolved by [authenticate], if any.
UserDto? userOf(Request request) => request.context[_userKey] as UserDto?;

/// Rejects requests to operations annotated with [Secured] unless the user
/// has one of the required roles.
///
/// It runs as route middleware, so the [RouteInfo] of the operation is
/// already known.
Middleware authorize() =>
    (inner) => (request) {
      final required = RouteInfo.of(
        request,
      )!.annotationsOf<Secured>().expand((secured) => secured.roles).toSet();
      if (required.isEmpty) return inner(request);
      final user = userOf(request);
      if (user == null) throw HttpProblem(401);
      if (!user.roles.any(required.contains)) throw HttpProblem(403);
      return inner(request);
    };
