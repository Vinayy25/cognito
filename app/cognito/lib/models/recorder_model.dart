import 'dart:io';

import 'package:flutter/material.dart';

class RecorderChatModel {
  File? audio;
  TimeOfDay? time;
  String? text;
  bool isPlaying = false;
  bool? isPaused;
  RecorderChatModel(
      {this.audio,
      this.time,
      this.text,
      this.isPlaying = false,
      this.isPaused});
}
