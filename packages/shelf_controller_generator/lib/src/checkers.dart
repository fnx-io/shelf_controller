/// Type checkers of the annotations and types the generator recognizes.
///
/// All of them are resolved by URL, so the generator depends neither on
/// `shelf_controller` nor on `json_annotation`.
library;

import 'package:source_gen/source_gen.dart';

const _annotations = 'package:shelf_controller/src/annotations.dart';
const _apiAnnotations = 'package:shelf_controller/src/api_annotations.dart';
const _jsonAnnotation = 'package:json_annotation/src';

const controllerChecker = TypeChecker.fromUrl('$_annotations#Controller');
const operationChecker = TypeChecker.fromUrl('$_annotations#Operation');
const pathChecker = TypeChecker.fromUrl('$_annotations#Path');
const queryChecker = TypeChecker.fromUrl('$_annotations#Query');
const headerChecker = TypeChecker.fromUrl('$_annotations#Header');
const bodyChecker = TypeChecker.fromUrl('$_annotations#Body');
const statusChecker = TypeChecker.fromUrl('$_annotations#Status');

const apiResponseChecker = TypeChecker.fromUrl('$_apiAnnotations#ApiResponse');
const apiSecurityChecker = TypeChecker.fromUrl('$_apiAnnotations#ApiSecurity');
const apiHiddenChecker = TypeChecker.fromUrl('$_apiAnnotations#ApiHidden');
const apiSchemaChecker = TypeChecker.fromUrl('$_apiAnnotations#ApiSchema');
const apiDiscriminatorChecker = TypeChecker.fromUrl(
  '$_apiAnnotations#ApiDiscriminator',
);
const apiFieldChecker = TypeChecker.fromUrl('$_apiAnnotations#ApiField');

const requestChecker = TypeChecker.fromUrl(
  'package:shelf/src/request.dart#Request',
);
const responseChecker = TypeChecker.fromUrl(
  'package:shelf/src/response.dart#Response',
);

const jsonSerializableChecker = TypeChecker.fromUrl(
  '$_jsonAnnotation/json_serializable.dart#JsonSerializable',
);
const jsonKeyChecker = TypeChecker.fromUrl(
  '$_jsonAnnotation/json_key.dart#JsonKey',
);
const jsonValueChecker = TypeChecker.fromUrl(
  '$_jsonAnnotation/json_value.dart#JsonValue',
);
const jsonEnumChecker = TypeChecker.fromUrl(
  '$_jsonAnnotation/json_enum.dart#JsonEnum',
);
const jsonConverterChecker = TypeChecker.fromUrl(
  '$_jsonAnnotation/json_converter.dart#JsonConverter',
);
