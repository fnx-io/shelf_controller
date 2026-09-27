import 'dart:convert';

import 'package:shelf/shelf.dart';

/// Sends a request to [handler] in memory, without a network.
Future<Response> send(
  Handler handler,
  String method,
  String path, {
  Object? json,
  String? body,
  Map<String, String> headers = const {},
}) async => handler(
  Request(
    method,
    Uri.parse('http://localhost$path'),
    body: json == null ? body : jsonEncode(json),
    headers: headers,
  ),
);

extension ResponseJson on Response {
  /// Decodes the JSON body.
  Future<Object?> json() async => jsonDecode(await readAsString());

  /// The `detail` of a Problem Details body.
  Future<String?> problemDetail() async =>
      ((await json())! as Map<String, Object?>)['detail'] as String?;
}
