import 'package:cognito/models/chat_model.dart';
import 'package:cognito/services/firebase_service.dart';
import 'package:flutter/material.dart';

class ChatState extends ChangeNotifier {
  ChatModel chatModel = ChatModel(conversations: []);

  ChatState() {
    initializeData();
  }

  Future<void> initializeData() async {
    List<String> conversationIds = await FirebaseService().getConversationIds();

    for (String conversationId in conversationIds) {
      List<Chat> chats = await FirebaseService().getChats(conversationId);
      final conversation = Conversations(
        chats: chats,
        conversationId: conversationId,
      );
      chatModel.conversations.add(conversation);
    }
    notifyListeners();
  }

  void chat(String message, String conversationId) {
    final chat = Chat(
      message: message,
      sender: 'user',
      time: DateTime.now().toString(),
    );

    final conversationIndex = chatModel.conversations.indexWhere(
      (element) => element.conversationId == conversationId,
    );

    if (conversationIndex != -1) {
      chatModel.conversations[conversationIndex].chats.add(chat);
      FirebaseService().addChat(conversationId, chat);
    } else {
      final conversation = Conversations(
        chats: [...chatModel.conversations[conversationIndex].chats, chat],
        conversationId: conversationId,
      );
      chatModel.conversations.add(conversation);
      FirebaseService().addChat(conversationId, chat);
    }

    notifyListeners();
  }

  void addConversationId(String conversationId) async {
    final conversation = Conversations(
      chats: [],
      conversationId: conversationId,
    );
    chatModel.conversations.add(conversation);
    await FirebaseService().addConversationId(conversationId);
    notifyListeners();
  }
}
