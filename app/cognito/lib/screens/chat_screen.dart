import 'package:cognito/models/chat_model.dart';
import 'package:cognito/models/recorder_model.dart';
import 'package:cognito/services/http_service.dart';
import 'package:cognito/states/chat_state.dart';
import 'package:cognito/states/data_provider.dart';
import 'package:cognito/states/play_audio_provider.dart';
import 'package:cognito/utils/colors.dart';
import 'package:cognito/utils/text.dart';
import 'package:cognito/widgets/chat_card.dart';
import 'package:cognito/widgets/welcome_message.dart';
import 'package:flutter/cupertino.dart';
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

    // final playProvider = Provider.of<PlayAudioProvider>(context);
    final dataProvider = Provider.of<Data>(context, listen: true);
    dataProvider.baseUrl = 'http://206.1.53.54';

    void sendMessage(String message) {
      if (message.trim().isNotEmpty) {
        widget.chatModelProvider.chatStream(message, widget.conversationId);
        promptController.clear();
      }
      // setState(() {});
    }

    var myChat = (widget
        .chatModelProvider
        .chatModel
        .conversations[
            (widget.chatModelProvider.chatModel.conversations.indexWhere(
      (element) => element.conversationId == widget.conversationId,
    ))]
        .chats);

    Widget unwantedWidget(int len) {
      return Visibility(
        visible: len < 2,
        child: const Column(
          children: [
            SizedBox(
              height: 100,
            ),
            Divider(
              thickness: 0.25,
              color: AppColor.primaryTextColor,
            ),
            WelcomeMessage(),
            Divider(
              thickness: 0.25,
              color: AppColor.primaryTextColor,
            ),
            SizedBox(
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
                      visible: chats.isNotEmpty,
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
                        spreadRadius: 1),
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
                                  widget.chatModelProvider.pickAndUploadFile(
                                      widget.chatModelProvider.email ?? '',
                                      widget.conversationId,
                                      widget.chatModelProvider.chatModel
                                          .conversations
                                          .indexWhere(
                                        (element) =>
                                            element.conversationId ==
                                            widget.conversationId,
                                      ));
                                },
                                icon: const Icon(
                                  Iconsax.camera4,
                                  color: AppColor.iconColor,
                                )),
                            IconButton(
                                onPressed: () {
                                  widget.chatModelProvider.performWebSearch =
                                      !widget
                                          .chatModelProvider.performWebSearch;
                                  setState(() {});
                                },
                                icon: Icon(Iconsax.global_search,
                                    color: widget
                                            .chatModelProvider.performWebSearch
                                        ? AppColor.iconColor
                                        : AppColor.secondaryTextColor)),
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
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                }
                              });
                            },
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: AppColor.hintColor),
                                hintText: "Ask cognito.."),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          CupertinoSwitch(
                            value: widget.chatModelProvider.performRAG,
                            activeTrackColor: AppColor.iconColor,
                            onChanged: (bool value) {
                              setState(() {
                                widget.chatModelProvider.setPerformRAG(value);
                              });
                            },
                          ),
                          AppText(
                              text: "RAG",
                              fontsize: 12,
                              color: AppColor.primaryTextColor),
                        ],
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
