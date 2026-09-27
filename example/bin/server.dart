import 'dart:io';

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_controller_example/app.dart';

Future<void> main() async {
  Logger.root.onRecord.listen((record) {
    stderr.writeln(
      '${record.level.name} ${record.message} ${record.error ?? ''}',
    );
  });
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(createApp());
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, InternetAddress.loopbackIPv4, port);
  print('Listening on http://${server.address.host}:${server.port}');
  print('API docs:     http://${server.address.host}:${server.port}/docs');
}
