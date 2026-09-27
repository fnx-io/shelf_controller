import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import '../checkers.dart';
import '../json_shape.dart';
import 'json_serializable_config.dart';

/// A field of a `@JsonSerializable` class as json_serializable treats it.
class DtoField {
  final FieldElement element;

  /// The key of the field in JSON.
  final String jsonName;

  /// Whether `fromJson` reads the field.
  final bool isInFromJson;

  /// Whether `toJson` writes the field.
  final bool isInToJson;

  final bool _classCreatesFactory;
  final bool _classCreatesToJson;
  final bool _isExplicitlyRequired;
  final ConstantReader _jsonKey;
  final ConstantReader _classConfig;

  /// The value used when the key is missing, from `JsonKey.defaultValue` or
  /// the constructor parameter.
  final DartObject? defaultValue;

  DtoField._({
    required this.element,
    required this.jsonName,
    required this.isInFromJson,
    required this.isInToJson,
    required this.defaultValue,
    required bool classCreatesFactory,
    required bool classCreatesToJson,
    required bool isExplicitlyRequired,
    required ConstantReader jsonKey,
    required ConstantReader classConfig,
  }) : _classCreatesFactory = classCreatesFactory,
       _classCreatesToJson = classCreatesToJson,
       _isExplicitlyRequired = isExplicitlyRequired,
       _jsonKey = jsonKey,
       _classConfig = classConfig;

  /// The element carrying annotations and the doc comment: the getter for
  /// a property declared as a getter, the field otherwise.
  Element get declaration => declarationOf(element);

  bool get _isNullable => isNullableType(element.type);

  /// Whether the key is listed in `required`.
  bool get isRequired =>
      _isExplicitlyRequired || (!_isNullable && defaultValue == null);

  /// Whether the field is only written by `toJson`.
  bool get isReadOnly => _classCreatesFactory && isInToJson && !isInFromJson;

  /// Whether the field is only read by `fromJson`.
  bool get isWriteOnly => _classCreatesToJson && isInFromJson && !isInToJson;

  /// Describes a custom conversion of the field that makes its JSON shape
  /// unknown, or returns `null` when the default conversion applies.
  String? customSerialization(ClassElement owner) {
    if (!_jsonKey.isNull &&
        (!_jsonKey.read('fromJson').isNull ||
            !_jsonKey.read('toJson').isNull)) {
      return 'it uses JsonKey fromJson/toJson functions';
    }
    if (declaration.metadata.annotations.any(_isConverterAnnotation)) {
      return 'it uses a JsonConverter';
    }
    if (_classConverterTypes().any(_convertsFieldType)) {
      return 'a JsonConverter of the class applies to it';
    }
    return null;
  }

  bool _isConverterAnnotation(ElementAnnotation annotation) {
    final type = annotation.computeConstantValue()?.type;
    return type != null && jsonConverterChecker.isAssignableFromType(type);
  }

  Iterable<DartType> _classConverterTypes() sync* {
    final converters = _classConfig.peek('converters')?.listValue ?? const [];
    for (final converter in converters) {
      final type = converter.type;
      if (type is! InterfaceType) continue;
      for (final supertype in type.allSupertypes) {
        if (jsonConverterChecker.isExactlyType(supertype)) {
          yield supertype.typeArguments.first;
        }
      }
    }
  }

  bool _convertsFieldType(DartType converted) =>
      converted.element == element.type.element;
}

/// Collects the serialized fields of a class like json_serializable does.
class DtoFields {
  const DtoFields._();

  /// Returns the fields of [element] that appear in `fromJson` or `toJson`,
  /// superclass fields first, then in declaration order.
  static List<DtoField> of(
    ClassElement element,
    ConstantReader classConfig,
    JsonSerializableDefaults defaults,
  ) {
    final rename =
        FieldRename.fromConstant(
          classConfig.peek('fieldRename')?.objectValue,
        ) ??
        defaults.fieldRename;
    final createFactory = classConfig.peek('createFactory')?.boolValue ?? true;
    final createToJson = classConfig.peek('createToJson')?.boolValue ?? true;
    final ignoreUnannotated =
        classConfig.peek('ignoreUnannotated')?.boolValue ?? false;
    final constructorParams = _constructorParams(element, classConfig);

    final fields = <DtoField>[];
    for (final field in _sortedFields(element)) {
      final jsonKey = ConstantReader(
        jsonKeyChecker.firstAnnotationOf(declarationOf(field)),
      );
      bool? flag(String name) => jsonKey.peek(name)?.boolValue;
      final ignored =
          flag('ignore') == true || (ignoreUnannotated && jsonKey.isNull);
      final isAccessible =
          !ignored &&
          (field.isPublic || flag('includeFromJson') == true) &&
          field.getter != null &&
          flag('includeFromJson') != false;
      final isUsedByFactory =
          constructorParams.containsKey(field.name) || field.setter != null;
      final isInFromJson = createFactory && isAccessible && isUsedByFactory;
      final isInToJson =
          createToJson &&
          !ignored &&
          flag('includeToJson') != false &&
          ((createFactory ? isInFromJson : isAccessible) ||
              flag('includeToJson') == true);
      if (!isInFromJson && !isInToJson) continue;

      final param = constructorParams[field.name];
      fields.add(
        DtoField._(
          element: field,
          jsonName:
              jsonKey.peek('name')?.stringValue ?? rename.apply(field.name!),
          isInFromJson: isInFromJson,
          isInToJson: isInToJson,
          defaultValue:
              jsonKey.peek('defaultValue')?.objectValue ??
              (param != null && param.hasDefaultValue
                  ? param.computeConstantValue()
                  : null),
          classCreatesFactory: createFactory,
          classCreatesToJson: createToJson,
          isExplicitlyRequired: flag('required') == true,
          jsonKey: jsonKey,
          classConfig: classConfig,
        ),
      );
    }
    return fields;
  }

  static Map<String, FormalParameterElement> _constructorParams(
    ClassElement element,
    ConstantReader classConfig,
  ) {
    final name = classConfig.peek('constructor')?.stringValue ?? '';
    final constructor = name.isEmpty
        ? element.unnamedConstructor
        : element.getNamedConstructor(name);
    return {
      for (final param
          in constructor?.formalParameters ?? const <FormalParameterElement>[])
        param.name!: param,
    };
  }

  /// Instance fields of [element] and its superclasses; a field declared in
  /// a subclass keeps the position of the inherited one.
  static List<FieldElement> _sortedFields(ClassElement element) {
    final byName = <String, FieldElement>{};
    for (final type in _hierarchyTopDown(element)) {
      final declared = type.fields.where((f) => !f.isStatic).toList()
        ..sort((a, b) => _offset(a).compareTo(_offset(b)));
      for (final field in declared) {
        final existing = byName[field.name!];
        final hasJsonKey = jsonKeyChecker.hasAnnotationOf(declarationOf(field));
        if (existing == null || hasJsonKey) byName[field.name!] = field;
      }
    }
    return byName.values.toList();
  }

  static List<InterfaceElement> _hierarchyTopDown(ClassElement element) {
    final chain = <InterfaceElement>[];
    InterfaceElement? current = element;
    while (current != null &&
        current is ClassElement &&
        !current.isDartCoreObject) {
      chain.insert(0, current);
      for (final mixin in current.mixins.reversed) {
        chain.insert(0, mixin.element);
      }
      current = current.supertype?.element;
    }
    return chain;
  }

  static int _offset(FieldElement field) {
    final accessor = field.isOriginGetterSetter
        ? (field.getter ?? field.setter)
        : null;
    return (accessor?.firstFragment ?? field.firstFragment).nameOffset ?? 0;
  }
}

/// The element declaring [field] in source: its getter when the field is
/// induced by a getter.
Element declarationOf(FieldElement field) =>
    field.isOriginGetterSetter ? (field.getter ?? field) : field;
