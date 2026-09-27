import 'package:shelf_controller/shelf_controller.dart';

import 'dto.dart';

/// Validates bound arguments before the controller method runs.
///
/// Interceptors see typed arguments, which makes them the natural place for
/// validation; the library itself does not validate anything.
class ValidationInterceptor implements OperationInterceptor {
  static final _code = RegExp(r'^[A-Z0-9]{2,10}$');

  @override
  Future<Object?> intercept(
    RouteInfo route,
    List<Object?> args,
    Future<Object?> Function() proceed,
  ) {
    for (final arg in args) {
      if (arg is CreateProjectDto && !_code.hasMatch(arg.code)) {
        throw HttpProblem(
          422,
          detail: 'Project code must be 2-10 upper-case letters or digits',
        );
      }
    }
    return proceed();
  }
}
