import 'package:json_annotation/json_annotation.dart';

enum Status { open, closed }

@JsonSerializable()
class TicketDto {
  final String title;
  final Status status;

  TicketDto(this.title, this.status);

  factory TicketDto.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
}
