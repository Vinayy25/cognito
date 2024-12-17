import 'dart:io';

import 'package:cognito/main.dart';
import 'package:cognito/models/chat_model.dart';
import 'package:cognito/services/firebase_service.dart';
import 'package:cognito/services/http_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatState extends ChangeNotifier {
  ChatModel chatModel = ChatModel(conversations: []);
  var email = FirebaseAuth.instance.currentUser!.email;
  bool shouldRefresh = false;
  String baseUrl = 'http://206.1.53.47';
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
            await HttpService().getTopicsAndSummary(email!, x.conversationId);

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

  // void chat(String message, String conversationId) async {
  //   final chat = Chat(
  //     message: message,
  //     sender: 'user',
  //     time: DateTime.now().toString(),
  //   );

  //   final conversationIndex = chatModel.conversations.indexWhere(
  //     (element) => element.conversationId == conversationId,
  //   );

  //   if (conversationIndex != -1) {
  //     chatModel.conversations[conversationIndex].chats.add(chat);
  //     notifyListeners();

  //     final chatResponse = await HttpService(baseUrl: baseUrl).queryWithHistoryAndText(
  //       user: email!,
  //       query: message,
  //       id: conversationId,
  //     );

  //     final modelChat = Chat(
  //       message: chatResponse,
  //       sender: 'model',
  //       time: DateTime.now().toString(),
  //     );

  //     chatModel.conversations[conversationIndex].chats.add(modelChat);
  //     shouldRefresh = true;
  //     notifyListeners();
  //     await FirebaseService().addChat(conversationId, chat);
  //     await FirebaseService().addChat(conversationId, modelChat);
  //   } else {
  //     final conversation = Conversations(
  //       chats: [chat],
  //       conversationId: conversationId,
  //     );

  //     chatModel.conversations.add(conversation);
  //     shouldRefresh = true;
  //     notifyListeners();
  //     await FirebaseService().addChat(conversationId, chat);
  //   }
  // }

  void addConversationId(String conversationId) async {
    final conversation = Conversations(
      chats: [],
      conversationId: conversationId,
    );
    chatModel.conversations.add(conversation);
    await FirebaseService().addConversationId(conversationId);
    notifyListeners();
  }
Future<void> pickAndUploadFile(
    String user,
    String conversationId,
    int conversationIndex,
  ) async {
    try {
      // Allow user to choose between camera or gallery
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source:
            await _selectImageSource(), // Helper function to select image source
      );

      if (file == null) {
        print('No file selected');
        return;
      }

      // Upload the selected image
      final response = await HttpService().uploadFile(
        user: user,
        conversationId: conversationId,
        imageFile: File(file.path),
        prompt:
            "Analyze the image and provide a short summary of the content in less than 100 words.",
      );

      print('Upload response: $response');

      // Create a chat object for the response
      final chat = Chat(
        message: response,
        sender: 'model',
        time: DateTime.now().toString(),
      );

      // Add chat to the conversation at the given index
      chatModel.conversations[conversationIndex].chats.add(chat);
      notifyListeners();
    } catch (e) {
      print('Error picking or uploading file: $e');
    }
  }

// Helper function to select the image source (camera or gallery)
  Future<ImageSource> _selectImageSource() async {
    final source = await showDialog<ImageSource>(
      context: NavigationService.navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    return source ?? ImageSource.gallery; // Default to gallery if no selection
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
      final chatResponseStream = HttpService().queryWithHistoryAndTextStream(
          user: email!,
          query: message,
          id: conversationId,
          performRAG: performRAG,
          performWebSearch: performWebSearch);

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
