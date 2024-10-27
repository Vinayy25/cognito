import 'dart:io';
import 'package:cognito/models/recorder_model.dart';
import 'package:cognito/services/toast_service.dart';
import 'package:cognito/states/auth_provider.dart';
import 'package:cognito/states/data_provider.dart';
import 'package:cognito/states/play_audio_provider.dart';
import 'package:cognito/states/record_audio_provider.dart';
import 'package:cognito/utils/colors.dart';
import 'package:cognito/utils/text.dart';
import 'package:cognito/widgets/typing_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lottie/lottie.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class TranscribeScreen extends StatefulWidget {
  final String conversationId;
 
  const TranscribeScreen(
      {super.key, required this.conversationId});

  @override
  State<TranscribeScreen> createState() => _TranscribeScreenState();
}

class _TranscribeScreenState extends State<TranscribeScreen> {
  customizeStatusAndNavigationBar() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light));
  }

  @override
  void initState() {
    // customizeStatusAndNavigationBar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthStateProvider>(context);
    final recordProvider = Provider.of<RecordAudioProvider>(context);
    final playProvider = Provider.of<PlayAudioProvider>(context);
    final dataProvider = Provider.of<Data>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 50,
          shape: const RoundedRectangleBorder(
              side: BorderSide.none,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          centerTitle: true,
          title: const AppText(
            text: 'cognito',
            fontsize: 25,
            color: Colors.white,
          ),
          actions: [
            IconButton(
                onPressed: () {
                  authProvider.logoutAll();
                },
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                )),
            IconButton(
                onPressed: () async {
                  await FilePicker.platform
                      .pickFiles(
                          allowMultiple: false,
                          dialogTitle: 'Please select an audio file',
                          type: FileType.audio)
                      .then((value) {
                    if (value != null) {
                      dataProvider.addChat(
                        RecorderChatModel(
                            audio: File(value.files.first.path!),
                            time: TimeOfDay.now(),
                            text: 'Transcribing...'),
                         'vinay',
                        widget.conversationId,
                      );
                    }
                  });
                },
                icon: const Icon(
                  Icons.file_upload_outlined,
                  color: Colors.white,
                ))
          ],
          elevation: 0,
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0),
      extendBody: true,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                 'vinay',
                widget.conversationId,
              );
              setState(() {});
              scrollController.position.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
              );
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
                     'vinay',
                    widget.conversationId,
                  ),
                );
          } else {
            await recordProvider.recordVoice();
          }
        },
        child: Container(
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
      body: Container(
        width: width,
        height: height,
        // height: height,
        decoration: const BoxDecoration(
          color: AppColor.backgroundColor,
          // gradient: LinearGradient(
          //     transform: GradientRotation(0.7),
          //     begin: Alignment.topLeft,
          //     end: Alignment.bottomRight,
          //     colors: [
          //       Color.fromRGBO(53, 65, 75, 1),
          //       Colors.deepPurple,
          //       Colors.black
          //     ])
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 30,
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              height: height - 100,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                controller: scrollController,
                itemBuilder: (context, index) {
                  return Chat(
                    index: index,
                    dataProvider: dataProvider,
                    recordProvider: recordProvider,
                    playProvider: playProvider,
                  );
                },
                itemCount: dataProvider.chatLength(),
              ),
            ),
            // const SizedBox(height: 80),
            // recordProvider.recordedFilePath.isEmpty
            //     ? _recordHeading()
            //     : _playAudioHeading(),
            // const SizedBox(height: 40),
            // recordProvider.recordedFilePath.isEmpty
            //     ? _recordingSection()
            //     : _audioPlayingSection(),
            // if (recordProvider.recordedFilePath.isNotEmpty &&
            //     !playProvider.isSongPlaying)
            //   const SizedBox(height: 40),
            // if (recordProvider.recordedFilePath.isNotEmpty &&
            //     !playProvider.isSongPlaying)
            //   _resetButton(),
          ],
        ),
      ),
    );
  }

  _commonIconSection() {
    return Container(
      width: 70,
      height: 70,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xff4BB543),
        borderRadius: BorderRadius.circular(100),
      ),
      child: const Icon(Icons.keyboard_voice_rounded,
          color: Colors.white, size: 30),
    );
  }
}

class Chat extends StatefulWidget {
  final RecordAudioProvider recordProvider;
  final PlayAudioProvider playProvider;
  final Data dataProvider;
  final int index;
  const Chat(
      {super.key,
      required this.recordProvider,
      required this.dataProvider,
      required this.playProvider,
      required this.index});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.only(bottom: 50),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Image.asset(
                'assets/images/chat.png',
                height: 60,
                width: 60,
              ),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width - 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white10,
            ),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 110,
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      _audioControllingSection(
                          widget.dataProvider.chats[widget.index].audio?.path ??
                              '',
                          widget.playProvider,
                          widget.dataProvider,
                          widget.index),
                      _audioProgressSection(widget.playProvider,
                          widget.dataProvider, widget.index),
                    ],
                  ),
                ),
                if (widget.dataProvider.chats[widget.index].text ==
                    "Transcribing...")
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      GPTTypingText(
                        text:
                            widget.dataProvider.chats[widget.index].text ?? '',
                      ),
                    ],
                  ),
                if (widget.dataProvider.chats[widget.index].text !=
                    'Transcribing...')
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 20),
                      child: GPTTypingText(
                        text:
                            widget.dataProvider.chats[widget.index].text ?? '',
                      ),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _audioControllingSection(String songPath, PlayAudioProvider playProvider,
      Data dataProvider, int index) {
    final playProviderWithoutListen =
        Provider.of<PlayAudioProvider>(context, listen: false);

    return IconButton(
      onPressed: () async {
        if (songPath.isEmpty) return;
        dataProvider.chats[index].isPlaying = true;
        await playProviderWithoutListen.playAudio(File(songPath));
        dataProvider.chats[index].isPlaying = false;
      },
      icon: Icon(playProvider.isSongPlaying &&
              playProvider.currSongPath == songPath &&
              dataProvider.chats[index].isPlaying == true
          ? Icons.pause
          : Icons.play_arrow_rounded),
      color: Colors.white,
      iconSize: 30,
    );
  }
  

  _audioProgressSection(
      PlayAudioProvider playProvider, Data dataProvider, int index) {
    return Expanded(
        child: Container(
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: LinearPercentIndicator(
        percent: dataProvider.chats[index].isPlaying == true ||
                playProvider.currSongPath ==
                    dataProvider.chats[index].audio?.path
            ? playProvider.currLoadingStatus
            : 0,
        backgroundColor: Colors.white,
        progressColor: Colors.black,
      ),
    ));
  }
}
