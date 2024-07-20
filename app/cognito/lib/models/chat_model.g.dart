// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatModel _$ChatModelFromJson(Map<String, dynamic> json) => ChatModel(
      conversations: (json['conversations'] as List<dynamic>)
          .map((e) => Conversations.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChatModelToJson(ChatModel instance) => <String, dynamic>{
      'conversations': instance.conversations,
    };

Conversations _$ConversationsFromJson(Map<String, dynamic> json) =>
    Conversations(
      conversationSummary: json['conversationSummary'] as String?,
      chats: (json['chats'] as List<dynamic>)
          .map((e) => Chat.fromJson(e as Map<String, dynamic>))
          .toList(),
      conversationId: json['conversationId'] as String,
      conversationName: json['conversationName'] as String?,
    );

Map<String, dynamic> _$ConversationsToJson(Conversations instance) =>
    <String, dynamic>{
      'chats': instance.chats,
      'conversationId': instance.conversationId,
      'conversationName': instance.conversationName,
      'conversationSummary': instance.conversationSummary,
    };

Chat _$ChatFromJson(Map<String, dynamic> json) => Chat(
      message: json['message'] as String,
      sender: json['sender'] as String,
      time: json['time'] as String,
    );

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
      'message': instance.message,
      'sender': instance.sender,
      'time': instance.time,
    };
