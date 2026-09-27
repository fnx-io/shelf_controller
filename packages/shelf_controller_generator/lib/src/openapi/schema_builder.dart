import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import '../checkers.dart';
import '../dart_object_json.dart';
import '../doc_text.dart';
import '../json_shape.dart';
import 'dto_fields.dart';
import 'json_serializable_config.dart';

/// JSON schema as an ordered map.
typedef Schema = Map<String, Object?>;

/// A schema in `components/schemas` together with the class it describes.
class ComponentSchema {
  /// Identifies the Dart class, for example `package:app/dto.dart#ProjectDto`.
  final String source;
  Schema schema = const {};

  ComponentSchema(this.source);
}

/// Builds OpenAPI 3.1 schemas of Dart types and collects the component
/// schemas of the classes they reference.
class SchemaBuilder {
  final JsonSerializableDefaults _defaults;

  /// Component schemas by name, in the order they were first referenced.
  final components = <String, ComponentSchema>{};

  SchemaBuilder(this._defaults);

  /// Returns the schema of a response of [shape].
  ///
  /// Enums outside of DTOs are bound by their Dart name, matching the
  /// generated router.
  Schema forValue(JsonShape shape) => _schema(shape, enumsByName: true);

  /// Returns the schema of a parameter or request body of [shape].
  ///
  /// A nullable Dart type only makes the value optional, which `required`
  /// expresses, so the schema itself is not nullable.
  Schema forInput(JsonShape shape) =>
      _schema(shape, enumsByName: true, allowNull: false);

  /// Returns [schema] extended with the constraints of an `ApiField`
  /// annotation on [element].
  Schema withApiField(Schema schema, Element element) {
    final field = apiFieldChecker.firstAnnotationOf(element);
    if (field == null) return schema;
    return {
      ...schema,
      for (final name in [
        'minLength',
        'maxLength',
        'pattern',
        'minimum',
        'maximum',
        'example',
      ])
        if (field.getField(name) case final value? when !value.isNull)
          name: dartObjectToJson(value),
    };
  }

  Schema _schema(
    JsonShape shape, {
    required bool enumsByName,
    bool allowNull = true,
  }) {
    final schema = switch (shape) {
      AnyShape() => <String, Object?>{},
      ScalarShape(:final kind) => _scalar(kind),
      EnumShape(:final element) => _enum(element, enumsByName: enumsByName),
      ArrayShape(:final items, :final isSet) => {
        'type': 'array',
        'items': _schema(items, enumsByName: enumsByName),
        if (isSet) 'uniqueItems': true,
      },
      MapShape(:final values) => {
        'type': 'object',
        'additionalProperties': _schema(values, enumsByName: enumsByName),
      },
      ObjectShape(:final element) => _reference(element),
    };
    return shape.isNullable && allowNull ? _nullable(schema) : schema;
  }

  Schema _scalar(ScalarKind kind) => switch (kind) {
    ScalarKind.string => {'type': 'string'},
    ScalarKind.integer => {'type': 'integer', 'format': 'int64'},
    ScalarKind.float => {'type': 'number', 'format': 'double'},
    ScalarKind.number => {'type': 'number'},
    ScalarKind.boolean => {'type': 'boolean'},
    ScalarKind.dateTime => {'type': 'string', 'format': 'date-time'},
    ScalarKind.uri => {'type': 'string', 'format': 'uri'},
  };

  Schema _enum(EnumElement element, {required bool enumsByName}) {
    final values = enumsByName
        ? [for (final constant in element.constants) constant.name!]
        : [for (final constant in element.constants) enumJsonValue(constant)];
    return {
      'type': values.every((value) => value is int) ? 'integer' : 'string',
      'enum': values,
    };
  }

  /// Returns the JSON value json_serializable writes for an enum [constant].
  Object? enumJsonValue(FieldElement constant) {
    final jsonValue = jsonValueChecker.firstAnnotationOf(constant);
    if (jsonValue != null) {
      return dartObjectToJson(jsonValue.getField('value')!);
    }
    final jsonEnum = ConstantReader(
      jsonEnumChecker.firstAnnotationOf(constant.enclosingElement),
    );
    final valueField = jsonEnum.peek('valueField')?.stringValue;
    if (valueField != null) {
      return dartObjectToJson(
        constant.computeConstantValue()!.getField(valueField)!,
      );
    }
    final rename =
        FieldRename.fromConstant(jsonEnum.peek('fieldRename')?.objectValue) ??
        FieldRename.none;
    return rename.apply(constant.name!);
  }

  Schema _nullable(Schema schema) {
    if (schema.isEmpty) return schema;
    final type = schema['type'];
    if (type is! String) {
      return {
        'oneOf': [
          schema,
          {'type': 'null'},
        ],
      };
    }
    return {
      ...schema,
      'type': [type, 'null'],
      if (schema['enum'] case final List<Object?> values)
        'enum': [...values, null],
    };
  }

  Schema _reference(InterfaceElement element) => {
    r'$ref': '#/components/schemas/${_register(element)}',
  };

  String _register(InterfaceElement element) {
    final override = ConstantReader(
      apiSchemaChecker.firstAnnotationOf(element),
    );
    final name = override.peek('name')?.stringValue ?? element.name!;
    final source = '${element.library.uri}#${element.name}';
    final existing = components[name];
    if (existing != null) {
      if (existing.source == source) return name;
      throw InvalidGenerationSource(
        'Two classes map to the schema `$name`: ${existing.source} and $source.',
        todo: 'Rename one of them with @ApiSchema(name: ...).',
        element: element,
      );
    }
    final component = ComponentSchema(source);
    components[name] = component;
    component.schema = _classSchema(element, override);
    return name;
  }

  Schema _classSchema(InterfaceElement element, ConstantReader override) {
    final literal = override.peek('schema')?.objectValue;
    if (literal != null) return dartObjectToJson(literal)! as Schema;
    if (element is! ClassElement || element.typeParameters.isNotEmpty) {
      throw _notUnderstood(element, 'only non-generic classes are supported');
    }
    final discriminator = apiDiscriminatorChecker.firstAnnotationOf(element);
    if (discriminator != null) {
      return _oneOf(element, ConstantReader(discriminator));
    }
    final jsonSerializable = jsonSerializableChecker.firstAnnotationOf(element);
    if (jsonSerializable == null) {
      throw _notUnderstood(
        element,
        'it is not annotated with @JsonSerializable',
      );
    }
    return _object(element, ConstantReader(jsonSerializable));
  }

  InvalidGenerationSource _notUnderstood(Element element, String reason) =>
      InvalidGenerationSource(
        'Cannot infer the JSON schema of `${element.name}`: $reason.',
        todo:
            'Annotate it with @JsonSerializable or describe it with '
            '@ApiSchema(schema: {...}).',
        element: element,
      );

  Schema _object(ClassElement element, ConstantReader jsonSerializable) {
    final fields = DtoFields.of(element, jsonSerializable, _defaults);
    final properties = <String, Object?>{};
    final required = <String>[];
    final discriminator = _discriminatorOf(element);
    if (discriminator != null &&
        !fields.any((f) => f.jsonName == discriminator.property)) {
      properties[discriminator.property] = {
        'type': 'string',
        'enum': [discriminator.value],
      };
      required.add(discriminator.property);
    }
    for (final field in fields) {
      properties[field.jsonName] = _property(element, field);
      if (field.isRequired) required.add(field.jsonName);
    }
    return {
      'type': 'object',
      'description': ?DocText.of(element).fullText,
      'properties': properties,
      if (required.isNotEmpty) 'required': required,
    };
  }

  Schema _property(ClassElement owner, DtoField field) {
    final element = field.declaration;
    final defaultValue = field.defaultValue;
    return withApiField({
      ..._fieldTypeSchema(owner, field),
      'description': ?DocText.of(element).fullText,
      if (defaultValue != null)
        'default': dartObjectToJson(defaultValue, enumValue: enumJsonValue),
      if (field.isReadOnly) 'readOnly': true,
      if (field.isWriteOnly) 'writeOnly': true,
    }, element);
  }

  Schema _fieldTypeSchema(ClassElement owner, DtoField field) {
    final element = field.element;
    final override = apiSchemaChecker
        .firstAnnotationOf(field.declaration)
        ?.getField('schema');
    if (override != null && !override.isNull) {
      return dartObjectToJson(override)! as Schema;
    }
    final customization = field.customSerialization(owner);
    if (customization != null) {
      throw InvalidGenerationSource(
        'Cannot infer the JSON schema of `${owner.name}.${element.name}`: '
        '$customization.',
        todo: 'Describe the field with @ApiSchema(schema: {...}).',
        element: element,
      );
    }
    try {
      return _schema(classifyJsonType(element.type), enumsByName: false);
    } on UnsupportedTypeException catch (e) {
      throw InvalidGenerationSource(
        'Field `${owner.name}.${element.name}`: $e.',
        todo: 'Describe the field with @ApiSchema(schema: {...}).',
        element: element,
      );
    }
  }

  Schema _oneOf(ClassElement base, ConstantReader discriminator) {
    final subtypes = [
      for (final candidate in base.library.classes)
        if (_directlyExtends(candidate, base)) candidate,
    ];
    if (subtypes.isEmpty) {
      throw InvalidGenerationSource(
        '`${base.name}` has @ApiDiscriminator but no subtypes in its library.',
        element: base,
      );
    }
    final refs = {
      for (final subtype in subtypes)
        _discriminatorValue(base, subtype, discriminator): _reference(
          subtype,
        )[r'$ref'],
    };
    return {
      'description': ?DocText.of(base).fullText,
      'oneOf': [
        for (final ref in refs.values) {r'$ref': ref},
      ],
      'discriminator': {
        'propertyName': discriminator.read('propertyName').stringValue,
        'mapping': refs,
      },
    };
  }

  ({String property, String value})? _discriminatorOf(ClassElement element) {
    final parents = [
      element.supertype?.element,
      ...element.interfaces.map((i) => i.element),
    ];
    for (final parent in parents.whereType<ClassElement>()) {
      final annotation = apiDiscriminatorChecker.firstAnnotationOf(parent);
      if (annotation == null) continue;
      final reader = ConstantReader(annotation);
      return (
        property: reader.read('propertyName').stringValue,
        value: _discriminatorValue(parent, element, reader),
      );
    }
    return null;
  }

  String _discriminatorValue(
    ClassElement base,
    ClassElement subtype,
    ConstantReader discriminator,
  ) {
    final mapping = discriminator.read('mapping').mapValue;
    for (final MapEntry(:key, :value) in mapping.entries) {
      final type = value?.toTypeValue();
      if (type is InterfaceType && type.element == subtype) {
        return key!.toStringValue()!;
      }
    }
    return ConstantReader(
          apiSchemaChecker.firstAnnotationOf(subtype),
        ).peek('name')?.stringValue ??
        subtype.name!;
  }

  bool _directlyExtends(ClassElement candidate, ClassElement base) =>
      candidate != base &&
      (candidate.supertype?.element == base ||
          candidate.interfaces.any((type) => type.element == base));
}
