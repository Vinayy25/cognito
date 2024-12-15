import 'dart:io';

import 'package:cognito/models/chat_model.dart';
import 'package:cognito/services/firebase_service.dart';
import 'package:cognito/services/http_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatState extends ChangeNotifier {
  ChatModel chatModel = ChatModel(conversations: []);
  var email = FirebaseAuth.instance.currentUser!.email;
  bool shouldRefresh = false;
  String baseUrl = 'http://cognito.fun';
  bool performRAG = false;
  bool performWebSearch = false;
  ChatState() {
    initializeData();
  }
  void refresh() {
    notifyListeners();
  }

  void setPerformRAG(bool value) {
    performRAG = value;
    notifyListeners();
  }

  void checkForSummary() async {
    bool changesMade = false;

    List<Conversations> previousChatSummaryAndTitle = chatModel.conversations;
    for (int conversationIndex = 0;
        conversationIndex < chatModel.conversations.length;
        conversationIndex++) {
      var x = chatModel.conversations[conversationIndex];
      if (x.chats.length == 4 ||
          x.chats.length % 10 == 0 ||
          x.conversationName == null) {
        print(x.conversationName);
        Map<String, String> topicsAndSummary =
            await HttpService(baseUrl: baseUrl)
                .getTopicsAndSummary(email!, x.conversationId);

        if (topicsAndSummary['title'] == null ||
            topicsAndSummary['summary'] == null ||
            topicsAndSummary['title'] == '' ||
            topicsAndSummary['summary'] == '') {
          x.conversationName =
              previousChatSummaryAndTitle[conversationIndex].conversationName;
          x.conversationSummary = previousChatSummaryAndTitle[conversationIndex]
              .conversationSummary;
        } else {
          x.conversationName = topicsAndSummary['title'];
          x.conversationSummary = topicsAndSummary['summary'];

          changesMade = true;
        }
      }
      if (changesMade == true) {
        await FirebaseService().saveSummaryAndTitle(chatModel);
      }
      notifyListeners();
    }

    notifyListeners();
  }

  Future<void> initializeData() async {
    baseUrl = await HttpService(baseUrl: '').getbaseUrl();
    print(baseUrl);
    Map<String, dynamic> x = await FirebaseService().getConversationIds();
    print(x);

    List<dynamic> conversationIds = x['conversation_ids'];
    Map<String, dynamic> conversationDetails = x['conversation_details'][0];

    for (String conversationId in conversationIds) {
      List<Chat> chats = await FirebaseService().getChats(conversationId);
      final conversation = Conversations(
        chats: chats,
        conversationId: conversationId,
        conversationName: conversationDetails['title'],
        conversationSummary: conversationDetails['summary'],
      );
      chatModel.conversations.add(conversation);
    }
    checkForSummary();
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

      final chatResponse = await HttpService(baseUrl: baseUrl).queryWithHistory(
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

  Future<void> pickAndUploadFile(String user, String conversationId) async {
    try {
      // Pick a PDF file
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

      if (result != null) {
        File file = File(result.files.single.path!);

        // Upload the file
        String responseMessage = await HttpService(baseUrl: baseUrl).uploadPdf(
          user: user,
          conversationId: conversationId,
          pdfFile: file,
        );

        // Show a success message
        print(responseMessage);
      } else {
        print('User canceled the picker');
      }
    } catch (e) {
      print('Error picking or uploading file: $e');
      print(
        'Error picking or uploading file: $e',
      );
    }
  }

  void chatStream(String message, String conversationId) async {
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

      // Start streaming chat response
      final chatResponseStream = HttpService(baseUrl: baseUrl)
          .queryWithHistoryAndTextStream(
              user: email!,
              query: message,
              id: conversationId,
              performRAG: performRAG,
              performWebSearch: performWebSearch
              
              );

      String accumulatedResponse = '';
      Chat modelChat =
          Chat(message: "Generating response...", sender: 'model', time: '');
      chatModel.conversations[conversationIndex].chats.add(modelChat);
      chatResponseStream.listen((chunk) {
        accumulatedResponse += chunk;

        modelChat = Chat(
          message: accumulatedResponse,
          sender: 'model',
          time: DateTime.now().toString(),
        );

        // Append the model chat message instead of replacing
        chatModel.conversations[conversationIndex].chats.last = modelChat;
        shouldRefresh = true;
        notifyListeners();
      }, onDone: () async {
        shouldRefresh = true;
        await FirebaseService().addChat(conversationId, chat);
        notifyListeners();
      }, onError: (error) {
        print('Error receiving chat stream: $error');
      });
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
}
