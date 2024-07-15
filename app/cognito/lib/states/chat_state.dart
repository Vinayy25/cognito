import 'package:cognito/models/chat_model.dart';
import 'package:cognito/services/firebase_service.dart';
import 'package:cognito/services/http_service1.dart';
import 'package:cognito/states/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatState extends ChangeNotifier {
  ChatModel chatModel = ChatModel(conversations: []);
  var email = FirebaseAuth.instance.currentUser!.email;
  bool shouldRefresh = false;

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

  void chat(String message, String conversationId) async {
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
      notifyListeners();

      final chatResponse = await HttpService().queryWithHistory(
        user: email!,
        query: message,
        id: conversationId,
      );

      final modelChat = Chat(
        message: chatResponse,
        sender: 'model',
        time: DateTime.now().toString(),
      );

      chatModel.conversations[conversationIndex].chats.add(modelChat);
      shouldRefresh = true;
      notifyListeners();
      await FirebaseService().addChat(conversationId, chat);
      await FirebaseService().addChat(conversationId, modelChat);
    } else {
      final conversation = Conversations(
        chats: [chat],
        conversationId: conversationId,
      );

      chatModel.conversations.add(conversation);
      shouldRefresh = true;
      notifyListeners();
      await FirebaseService().addChat(conversationId, chat);
    }
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
