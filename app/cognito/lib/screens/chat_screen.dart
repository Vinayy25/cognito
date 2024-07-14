import 'package:cognito/services/firebase_service.dart';
import 'package:cognito/states/chat_state.dart';
import 'package:cognito/states/play_audio_provider.dart';
import 'package:cognito/states/record_audio_provider.dart';
import 'package:cognito/utils/colors.dart';
import 'package:cognito/utils/design.dart';
import 'package:cognito/utils/text.dart';
import 'package:cognito/widgets/my_drawer.dart';
import 'package:cognito/widgets/welcome_message.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatelessWidget {
  final String conversationId;
  final ChatState chatModelProvider;
  const ChatScreen(
      {super.key,
      required this.conversationId,
      required this.chatModelProvider});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final TextEditingController promptController = TextEditingController();
    final AdvancedDrawerController drawerController =
        AdvancedDrawerController();
    final ScrollController scrollController = ScrollController();
    final ScrollController viewScrollController = ScrollController();

    final recordProvider = Provider.of<RecordAudioProvider>(context);
    final playProvider = Provider.of<PlayAudioProvider>(context);

    void sendMessage(String message) {
      if (message.trim().isNotEmpty) {
        chatModelProvider.chat(message, conversationId);
        promptController.clear();
      }
    }

    return AdvancedDrawer(
        controller: drawerController,
        rtlOpening: true,
        backdropColor: AppColor.appBarColor,
        childDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: AppColor.secondaryTextColor,
                blurRadius: 10,
                spreadRadius: 1,
              )
            ]),
        drawer: const MyDrawer(),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
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
            actions: [
              Container(
                decoration: BoxDecoration(
                    color: AppColor.iconBackgroundColor,
                    borderRadius: BorderRadius.circular(20)),
                child: IconButton(
                    onPressed: () {
                      drawerController.showDrawer();
                    },
                    icon: const Icon(
                      Iconsax.user,
                      color: AppColor.iconColor,
                    )),
              ),
              const SizedBox(
                width: 10,
              )
            ],
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Expanded(
                      child: ListView.builder(
                    shrinkWrap: true,
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.only(top: 0, bottom: 20),
                    itemCount: 10,
                    controller: viewScrollController,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return ((chatModelProvider
                                  .chatModel
                                  .conversations[(chatModelProvider
                                      .chatModel.conversations
                                      .indexWhere(
                                (element) =>
                                    element.conversationId == conversationId,
                              ))]
                                  .chats
                                  .length) >
                              1)
                          ? Container()
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SquareBoxDesign(text: 'Hello this is test'),
                                    SquareBoxDesign(
                                        text:
                                            'Hello this is testing vinays code and design'),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SquareBoxDesign(text: 'Hello this is test'),
                                    SquareBoxDesign(
                                        text: 'Hello this is and design'),
                                  ],
                                ),
                              ],
                            );
                    },
                  )),
                  Consumer<ChatState>(builder: (context, provider, child) {
                    return Container(
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
                                      onPressed: () {},
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
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
                                    scrollController.jumpTo(scrollController
                                        .position.maxScrollExtent);
                                  },
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (value) {
                                    sendMessage(promptController.text);
                                  },
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintStyle:
                                          TextStyle(color: AppColor.hintColor),
                                      hintText: "Message cognito.."),
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: () async {
                                  // chatModelProvider.chat(
                                  //     promptController.text, conversationId);
                                  sendMessage(promptController.text);
                                },
                                icon: const Icon(Iconsax.send_15,
                                    color: AppColor.iconColor))
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ));
  }
}
