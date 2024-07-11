import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class ChatModel {
  final List<Conversations> conversations;

  ChatModel({required this.conversations});

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChatModelToJson(this);
}

@JsonSerializable()
class Conversations {
  final List<Chat> chats;
  final String conversationId;
  final String? conversationName;

  Conversations({
    required this.chats,
    required this.conversationId,
    this.conversationName,
  });

  factory Conversations.fromJson(Map<String, dynamic> json) =>
      _$ConversationsFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationsToJson(this);
}

@JsonSerializable()
class Chat {
  final String message;
  final String sender;
  final String time;

  Chat({
    required this.message,
    required this.sender,
    required this.time,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
  Map<String, dynamic> toJson() => _$ChatToJson(this);
}
