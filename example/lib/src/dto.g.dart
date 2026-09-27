// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectDto _$ProjectDtoFromJson(Map<String, dynamic> json) => ProjectDto(
  code: json['code'] as String,
  name: json['name'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  state:
      $enumDecodeNullable(_$ProjectStateEnumMap, json['state']) ??
      ProjectState.active,
  members:
      (json['members'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ProjectDtoToJson(ProjectDto instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'state': _$ProjectStateEnumMap[instance.state]!,
      'members': instance.members,
      'created_at': instance.createdAt.toIso8601String(),
      'attachments': instance.attachments,
    };

const _$ProjectStateEnumMap = {
  ProjectState.active: 'active',
  ProjectState.archived: 'archived',
};

CreateProjectDto _$CreateProjectDtoFromJson(Map<String, dynamic> json) =>
    CreateProjectDto(
      code: json['code'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$CreateProjectDtoToJson(CreateProjectDto instance) =>
    <String, dynamic>{'code': instance.code, 'name': instance.name};

LinkAttachment _$LinkAttachmentFromJson(Map<String, dynamic> json) =>
    LinkAttachment(Uri.parse(json['url'] as String));

Map<String, dynamic> _$LinkAttachmentToJson(LinkAttachment instance) =>
    <String, dynamic>{'url': instance.url.toString()};

NoteAttachment _$NoteAttachmentFromJson(Map<String, dynamic> json) =>
    NoteAttachment(json['text'] as String);

Map<String, dynamic> _$NoteAttachmentToJson(NoteAttachment instance) =>
    <String, dynamic>{'text': instance.text};

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
  login: json['login'] as String,
  roles: (json['roles'] as List<dynamic>).map((e) => e as String).toSet(),
);

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
  'login': instance.login,
  'roles': instance.roles.toList(),
};
