import 'package:cognito/models/recorder_model.dart';
import 'package:cognito/services/http_service1.dart';
import 'package:flutter/material.dart';


class Data extends ChangeNotifier {
  List<RecorderChatModel> chats = [];
  bool requestPending = false;

  addChat(RecorderChatModel chat, String user, String id) {
    chats.add(chat);
    fetchTrasnscription(
      user,
      id,
    );
    notifyListeners();
  }

  fetchTrasnscription(String user,  String id) async {
    requestPending = true;
    await HttpService()
        .transcribeAndSave(
          user: user, 
          conversationId: id,
          audioFile: chats.last.audio!,
    )
        .then((value) {
      value = value.substring(2, value.length - 2);
      chats.last.text = value;

      notifyListeners();
    });
    requestPending = false;

    notifyListeners();
  }

  int chatLength() {
    return chats.length;
  }

  deleteChat(int index) {
    chats.removeAt(index);
    notifyListeners();
  }

  updateChat(int index, RecorderChatModel chat) {
    chats[index] = chat;
    notifyListeners();
  }

  clearChat() {
    chats.clear();
    notifyListeners();
  }
}
