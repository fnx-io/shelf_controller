import 'package:json_annotation/json_annotation.dart';
import 'package:shelf_controller/shelf_controller.dart';

part 'dto.g.dart';

/// Lifecycle state of a project.
enum ProjectState {
  @JsonValue('active')
  active,
  @JsonValue('archived')
  archived,
}

/// A project.
@JsonSerializable()
class ProjectDto {
  /// Unique project code.
  final String code;

  /// Human readable name.
  final String name;

  /// Current lifecycle state.
  final ProjectState state;

  /// Logins of the project members.
  final List<String> members;

  /// When the project was created.
  final DateTime createdAt;

  /// Attachments of the project.
  final List<Attachment> attachments;

  const ProjectDto({
    required this.code,
    required this.name,
    required this.createdAt,
    this.state = ProjectState.active,
    this.members = const [],
    this.attachments = const [],
  });

  factory ProjectDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectDtoToJson(this);
}

/// Data needed to create a project.
@JsonSerializable()
class CreateProjectDto {
  /// Unique project code, upper-case letters and digits.
  @ApiField(
    pattern: r'^[A-Z0-9]+$',
    minLength: 2,
    maxLength: 10,
    example: 'WEB',
  )
  final String code;

  /// Human readable name.
  @ApiField(minLength: 1, maxLength: 200)
  final String name;

  const CreateProjectDto({required this.code, required this.name});

  factory CreateProjectDto.fromJson(Map<String, dynamic> json) =>
      _$CreateProjectDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateProjectDtoToJson(this);
}

/// Something attached to a project.
///
/// The JSON object carries its kind in the `type` property.
@ApiDiscriminator(
  'type',
  mapping: {'link': LinkAttachment, 'note': NoteAttachment},
)
sealed class Attachment {
  const Attachment();

  factory Attachment.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'link' => LinkAttachment.fromJson(json),
        'note' => NoteAttachment.fromJson(json),
        final type => throw FormatException('Unknown attachment type: $type'),
      };

  Map<String, dynamic> toJson();
}

/// A link to an external resource.
@JsonSerializable()
class LinkAttachment extends Attachment {
  /// The target of the link.
  final Uri url;

  const LinkAttachment(this.url);

  factory LinkAttachment.fromJson(Map<String, dynamic> json) =>
      _$LinkAttachmentFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
    'type': 'link',
    ..._$LinkAttachmentToJson(this),
  };
}

/// A text note.
@JsonSerializable()
class NoteAttachment extends Attachment {
  /// The text of the note.
  final String text;

  const NoteAttachment(this.text);

  factory NoteAttachment.fromJson(Map<String, dynamic> json) =>
      _$NoteAttachmentFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
    'type': 'note',
    ..._$NoteAttachmentToJson(this),
  };
}

/// The signed-in user.
@JsonSerializable()
class UserDto {
  /// Login of the user.
  final String login;

  /// Roles granted to the user.
  final Set<String> roles;

  const UserDto({required this.login, required this.roles});

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}
