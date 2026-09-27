import 'package:shelf_controller/shelf_controller.dart';

part 'input.g.dart';

enum Sort { name, created }

@Controller('/items')
class ParametersController {
  /// Parameters of every source.
  ///
  /// Path segments can be restricted by a regular expression, which becomes
  /// the `pattern` of a string schema.
  @Get('/<id|[0-9]+>/children/<childName|[a-z]+>')
  List<String> search(
    @Path() int id,
    @Path('childName', 'Name of the child') String child,
    @Query('q', 'Full-text query') String? query,
    @Query() @ApiField(minimum: 1, maximum: 100) int limit,
    @Header('X-Request-Id') String requestId,
    @Header('X-Trace', 'Tracing flag') bool? trace,
    Request request, {
    @Query() Sort sort = Sort.name,
    @Query('tag') List<String> tags = const ['a', 'b'],
    @Query() DateTime? since,
  }) => [];

  /// No parameters at all, so no automatic 400.
  @Get('/')
  List<String> all() => [];

  /// Only the raw request, so no automatic 400 either.
  @Get('/raw')
  String raw(Request request) => '';
}
