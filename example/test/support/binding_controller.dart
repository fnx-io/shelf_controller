import 'package:shelf_controller/shelf_controller.dart';
import 'package:shelf_controller_example/app.dart';

part 'binding_controller.g.dart';

enum Color { red, green }

/// Echoes bound arguments back, covering every supported binding.
@Controller('/bind', tag: 'Binding')
class BindingController {
  /// Records calls, for assertions on the order of the pipeline.
  final List<String> trace;

  BindingController([List<String>? trace]) : trace = trace ?? [];

  @Get('/path/<id|[0-9]+>/<name>')
  Map<String, Object?> path(@Path() int id, @Path() String name) => {
    'id': id,
    'name': name,
  };

  @Get('/scalars')
  Map<String, Object?> scalars(
    @Query() String text,
    @Query() int count,
    @Query() double ratio,
    @Query() num amount,
    @Query() bool flag,
    @Query() DateTime at,
    @Query() Uri link,
    @Query() Color color,
  ) => {
    'text': text,
    'count': count,
    'ratio': ratio,
    'amount': amount,
    'flag': flag,
    'at': at.toIso8601String(),
    'link': '$link',
    'color': color.name,
  };

  @Get('/optional')
  Map<String, Object?> optional({
    @Query() int? page,
    @Query('page-size') int size = 10,
    @Query('tag') List<String>? tags,
    @Query('id') List<int> ids = const [1],
  }) => {'page': page, 'size': size, 'tags': tags, 'ids': ids};

  @Get('/required-list')
  List<Color> requiredList(@Query('c') List<Color> colors) => colors;

  @Get('/header')
  Map<String, Object?> header(
    @Header('X-Count') int count,
    @Header('X-Name') String? name,
  ) => {'count': count, 'name': name};

  @Post('/body/object')
  ProjectDto objectBody(@Body() ProjectDto project) => project;

  @Post('/body/list')
  List<CreateProjectDto> listBody(@Body() List<CreateProjectDto> items) =>
      items.reversed.toList();

  @Post('/body/map')
  Map<String, int> mapBody(@Body() Map<String, int> counts) => {
    for (final MapEntry(:key, :value) in counts.entries) key: value * 2,
  };

  @Post('/body/optional')
  String optionalBody(@Body() CreateProjectDto? project) =>
      project?.code ?? 'none';

  @Post('/body/primitive')
  int primitiveBody(@Body() int value) => value + 1;

  @Get('/result/set')
  Set<Color> setResult() => {Color.green, Color.red};

  @Get('/result/date')
  DateTime dateResult() => DateTime.utc(2026, 9, 27, 12);

  @Get('/result/nullable')
  CreateProjectDto? nullableResult() => null;

  @Get('/result/map')
  Map<String, List<CreateProjectDto>> mapResult() => {
    'a': [const CreateProjectDto(code: 'A', name: 'a')],
  };

  @Post('/void')
  Future<void> voidResult() async => trace.add('void called');

  @Get('/response')
  Response rawResponse(Request request) =>
      Response(418, body: 'teapot ${request.url.path}');

  @Get('/failure')
  String failure() => throw StateError('boom');

  @Get('/traced/<id>')
  @Secured(['tracing'])
  String traced(@Path() String id) {
    trace.add('controller $id');
    return id;
  }
}
