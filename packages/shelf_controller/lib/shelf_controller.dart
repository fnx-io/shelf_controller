/// Typed controllers for shelf.
///
/// Annotate a class with [Controller] and its methods with [Get], [Post],
/// [Put], [Patch] or [Delete]; `shelf_controller_generator` then generates a
/// router binding requests to the method parameters and an OpenAPI 3.1 spec
/// describing the same operations.
///
/// The library also exports the shelf types referenced by generated code, so
/// a controller library only needs this import.
library;

export 'package:shelf/shelf.dart' show Handler, Middleware, Request, Response;
export 'package:shelf_router/shelf_router.dart' show Router;

export 'src/annotations.dart';
export 'src/api_annotations.dart';
export 'src/binding.dart';
export 'src/operation.dart';
export 'src/problem.dart';
export 'src/route_info.dart';
