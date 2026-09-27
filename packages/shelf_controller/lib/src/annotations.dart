/// Annotations that describe controllers, their operations and the binding
/// of method parameters.
library;

/// Marks a class as a controller whose annotated methods become HTTP
/// operations.
///
/// The [path] is the prefix of every operation path in the controller and
/// [tag] is the default OpenAPI tag of those operations.
///
/// ```dart
/// @Controller('/api/projects', tag: 'Projects')
/// class ProjectsController { ... }
/// ```
class Controller {
  /// The path prefix shared by all operations of the controller.
  final String path;

  /// The OpenAPI tag assigned to every operation of the controller.
  final String? tag;

  /// Creates a controller annotation with the given path prefix.
  const Controller(this.path, {this.tag});
}

/// Base class of the HTTP method annotations [Get], [Post], [Put], [Patch]
/// and [Delete].
abstract class Operation {
  /// The HTTP method, for example `GET`.
  final String method;

  /// The path relative to the controller in `shelf_router` syntax, for
  /// example `/<id>`.
  final String path;

  /// The OpenAPI `operationId`; defaults to the name of the method.
  final String? operationId;

  /// Creates an operation annotation.
  const Operation(this.method, this.path, {this.operationId});
}

/// Maps a controller method to an HTTP `GET` operation.
class Get extends Operation {
  /// Creates a `GET` operation on [path].
  const Get(String path, {String? operationId})
    : super('GET', path, operationId: operationId);
}

/// Maps a controller method to an HTTP `POST` operation.
class Post extends Operation {
  /// Creates a `POST` operation on [path].
  const Post(String path, {String? operationId})
    : super('POST', path, operationId: operationId);
}

/// Maps a controller method to an HTTP `PUT` operation.
class Put extends Operation {
  /// Creates a `PUT` operation on [path].
  const Put(String path, {String? operationId})
    : super('PUT', path, operationId: operationId);
}

/// Maps a controller method to an HTTP `PATCH` operation.
class Patch extends Operation {
  /// Creates a `PATCH` operation on [path].
  const Patch(String path, {String? operationId})
    : super('PATCH', path, operationId: operationId);
}

/// Maps a controller method to an HTTP `DELETE` operation.
class Delete extends Operation {
  /// Creates a `DELETE` operation on [path].
  const Delete(String path, {String? operationId})
    : super('DELETE', path, operationId: operationId);
}

/// Binds a method parameter to a segment of the request path.
class Path {
  /// The name of the path segment; defaults to the parameter name.
  final String? name;

  /// The description of the parameter in the OpenAPI spec.
  final String? description;

  /// Creates a path parameter binding.
  const Path([this.name, this.description]);
}

/// Binds a method parameter to a query parameter.
///
/// A nullable parameter type makes the query parameter optional and a
/// `List<T>` type accepts a repeated parameter (`?tag=a&tag=b`).
class Query {
  /// The name of the query parameter; defaults to the parameter name.
  final String? name;

  /// The description of the parameter in the OpenAPI spec.
  final String? description;

  /// Creates a query parameter binding.
  const Query([this.name, this.description]);
}

/// Binds a method parameter to a request header.
class Header {
  /// The name of the header, for example `X-Request-Id`.
  final String name;

  /// The description of the parameter in the OpenAPI spec.
  final String? description;

  /// Creates a header binding.
  const Header(this.name, [this.description]);
}

/// Binds a method parameter to the JSON request body.
///
/// The parameter type must provide a `fromJson` factory, or be a `List`,
/// `Map<String, T>` or a primitive JSON type.
class Body {
  /// The description of the request body in the OpenAPI spec.
  final String? description;

  /// Creates a request body binding.
  const Body([this.description]);
}

/// Sets the status code of a successful response.
///
/// Without it, operations respond with `200`, or `204` when the method
/// returns `void`.
class Status {
  /// The HTTP status code of a successful response.
  final int code;

  /// Creates a status annotation.
  const Status(this.code);
}
