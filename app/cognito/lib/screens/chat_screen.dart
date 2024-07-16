import 'dart:io';

import 'package:cognito/models/recorder_model.dart';
import 'package:cognito/services/firebase_service.dart';
import 'package:cognito/services/http_service1.dart';
import 'package:cognito/services/toast_service.dart';
import 'package:cognito/states/chat_state.dart';
import 'package:cognito/states/data_provider.dart';
import 'package:cognito/states/play_audio_provider.dart';
import 'package:cognito/states/record_audio_provider.dart';
import 'package:cognito/utils/colors.dart';
import 'package:cognito/utils/design.dart';
import 'package:cognito/utils/text.dart';
import 'package:cognito/widgets/chat_card.dart';
import 'package:cognito/widgets/my_drawer.dart';
import 'package:cognito/widgets/welcome_message.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';

import 'package:iconsax/iconsax.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final ChatState chatModelProvider;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.chatModelProvider,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController viewScrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState

    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewScrollController
          .jumpTo(viewScrollController.position.maxScrollExtent);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final TextEditingController promptController = TextEditingController();
    final AdvancedDrawerController drawerController =
        AdvancedDrawerController();
    final ScrollController scrollController = ScrollController();

    final recordProvider = Provider.of<RecordAudioProvider>(context);
    final playProvider = Provider.of<PlayAudioProvider>(context);
    final dataProvider = Provider.of<Data>(context, listen: true);

    void sendMessage(String message) {
      if (message.trim().isNotEmpty) {
        widget.chatModelProvider.chat(message, widget.conversationId);
        promptController.clear();
      }
      setState(() {});
    }

    var myChat = (widget
        .chatModelProvider
        .chatModel
        .conversations[
            (widget.chatModelProvider.chatModel.conversations.indexWhere(
      (element) => element.conversationId == widget.conversationId,
    ))]
        .chats);
    Future<void> _pickAndUploadFile(String user, String conversation_id) async {
      try {
        // Pick a PDF file
        FilePickerResult? result = await FilePicker.platform
            .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

        if (result != null) {
          File file = File(result.files.single.path!);

          // Upload the file
          String responseMessage = await HttpService().uploadPdf(
            user: user,
            conversationId: conversation_id,
            pdfFile: file,
          );

          // Show a success message
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(responseMessage)));
        } else {
          print('User canceled the picker');
        }
      } catch (e) {
        print('Error picking or uploading file: $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error uploading file: $e')));
      }
    }

    Widget unwantedWidget(int len) {
      return Visibility(
        visible: len < 2,
        child: Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            const Divider(
              thickness: 0.25,
              color: AppColor.primaryTextColor,
            ),
            const WelcomeMessage(),
            const Divider(
              thickness: 0.25,
              color: AppColor.primaryTextColor,
            ),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniStartDocked,
      floatingActionButton: GestureDetector(
        onTap: () async {
          if (dataProvider.requestPending == true) {
            showToast(
                'please wait for previous audio transcription to be completed');
          } else if (recordProvider.isRecording == true) {
            await recordProvider
                .stopRecording(dataProvider.chatLength() + 1)
                .then((value) {
              dataProvider.addChat(
                RecorderChatModel(
                    audio: value,
                    time: TimeOfDay.now(),
                    text: 'Transcribing...'),
                widget.chatModelProvider.email ?? '',
                widget.conversationId,
              );

              // _scrollController.position.animateTo(
              //   _scrollController.position.maxScrollExtent,
              //   duration: const Duration(milliseconds: 500),
              //   curve: Curves.fastOutSlowIn,
              // );
            });
          } else {
            await recordProvider.recordVoice();
          }
        },
        onLongPress: () async {
          if (dataProvider.requestPending == true) {
            showToast(
                'please wait for previous audio transcription to be completed');
          } else if (recordProvider.isRecording == true) {
            await recordProvider
                .stopRecording(dataProvider.chatLength() + 1)
                .then(
                  (value) => dataProvider.addChat(
                    RecorderChatModel(
                        audio: value,
                        time: TimeOfDay.now(),
                        text: 'Transcribing...'),
                    widget.chatModelProvider.email ?? '',
                    widget.conversationId,
                  ),
                );
          } else {
            await recordProvider.recordVoice();
          }
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 70),
          height: 80,
          width: 80,
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 89, 79, 79),
                blurRadius: 5,
                spreadRadius: 1,
                offset: Offset(0, 0),
              )
            ],
            shape: BoxShape.circle,
            color: Color.fromRGBO(53, 55, 75, 1),
          ),
          child: recordProvider.isRecording == true
              ? Lottie.asset('assets/animations/voice_recording_inwhite.json',
                  frameRate: FrameRate.max,
                  repeat: true,
                  reverse: true,
                  fit: BoxFit.contain)
              : const Icon(size: 35, Icons.mic, color: Colors.white),
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        centerTitle: true,
        title: const AppText(
          text: 'cognito',
          fontsize: 25,
          color: Colors.white,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Iconsax.arrow_left_2, color: AppColor.iconColor),
        ),
        automaticallyImplyLeading: true,
        forceMaterialTransparency: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Container(
          height: height,
          width: width,
          color: AppColor.backgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              unwantedWidget(myChat.length),
              Consumer<ChatState>(builder: (context, value, child) {
                if (value.shouldRefresh == true) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    viewScrollController
                        .jumpTo(viewScrollController.position.maxScrollExtent);
                  });
                  value.shouldRefresh = false;
                }

                var chats = value
                    .chatModel
                    .conversations[(value.chatModel.conversations.indexWhere(
                  (element) => element.conversationId == widget.conversationId,
                ))]
                    .chats;
                return Expanded(
                    child: ListView.builder(
                  shrinkWrap: false,
                  padding: const EdgeInsets.only(top: 70, bottom: 20),
                  itemCount: chats.length,
                  controller: viewScrollController,
                  itemBuilder: (context, index) {
                    return Visibility(
                      visible: chats.length >= 1,
                      child: Align(
                        alignment: chats[index].sender == 'user'
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: ChatCard(
                          isUser: chats[index].sender == 'user',
                          text: chats[index].message,
                        ),
                      ),
                    );
                  },
                ));
              }),
              Container(
                decoration: BoxDecoration(
                  color: AppColor.appBarColor,
                  boxShadow: const [
                    BoxShadow(
                        color: AppColor.secondaryTextColor,
                        blurRadius: 10,
                        spreadRadius: 1)
                  ],
                  border: Border.all(
                    color: AppColor.borderColor,
                  ),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  _pickAndUploadFile(
                                      widget.chatModelProvider.email ?? '',
                                      widget.conversationId);
                                },
                                icon: const Icon(
                                  Iconsax.folder_add5,
                                  color: AppColor.iconColor,
                                )),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(Iconsax.microphone5,
                                    color: AppColor.iconColor)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 50,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all()),
                          child: TextField(
                            onTapOutside: (value) {
                              // dismiss keyboard
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');
                            },
                            controller: promptController,
                            onTap: () {
                              scrollController.jumpTo(
                                  scrollController.position.maxScrollExtent);
                            },
                            textInputAction: TextInputAction.send,
                            onSubmitted: (value) {
                              sendMessage(promptController.text);

                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (viewScrollController.hasClients) {
                                  viewScrollController.animateTo(
                                    viewScrollController
                                        .position.maxScrollExtent,
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                }
                              });
                            },
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: AppColor.hintColor),
                                hintText: "Message cognito.."),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            sendMessage(promptController.text);
                          },
                          icon: const Icon(Iconsax.send_15,
                              color: AppColor.iconColor))
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
