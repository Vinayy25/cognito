import 'package:cognito/models/chat_model.dart';
import 'package:cognito/services/firebase_service.dart';
import 'package:flutter/material.dart';

class ChatState extends ChangeNotifier {
  ChatModel chatModel = ChatModel(conversations: []);

  ChatState() {
    initializeData();
  }

  Future<void> initializeData() async {
    ChatModel? conversationData =
        await FirebaseService().getUserConversations();

    if (conversationData != null) {
      chatModel = conversationData;
      notifyListeners();
    }
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
    } else {
      final conversation = Conversations(
        chats: [chat],
        conversationId: conversationId,
      );
      chatModel.conversations.add(conversation);
      FirebaseService().addConversation(conversation);
    }

    notifyListeners();
  }
}
