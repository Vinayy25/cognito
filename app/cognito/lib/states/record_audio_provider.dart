import 'dart:io';

import 'package:cognito/services/permission_management.dart';
import 'package:cognito/services/storage_management.dart';
import 'package:cognito/services/toast_service.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

class RecordAudioProvider extends ChangeNotifier {
  final Record _record = Record();
  bool _isRecording = false;
  String _afterRecordingFilePath = '';

  bool get isRecording => _isRecording;
  String get recordedFilePath => _afterRecordingFilePath;
  

  clearOldData() {
    _afterRecordingFilePath = '';
    notifyListeners();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile() async {
    final path = await _localPath;
    // Generate unique filename using timestamp and UUID
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}';
    return File('$path/$fileName');
  }

  Future<String> saveFile(List<int> data) async {
    final file = await _localFile();
    await file.writeAsBytes(data);
    return file.path;
  }

  recordVoice() async {
    final isPermitted = (await PermissionManagement.recordingPermission());

    if (!isPermitted) {
      print('Permission not granted');
      showToast('Permission not granted');
      return;
    }

    if (!(await _record.hasPermission())) return;

    final voiceDirPath = await StorageManagement.getAudioDir;
    final voiceFilePath = StorageManagement.createRecordAudioPath(
        dirPath: voiceDirPath, fileName: 'audio_message');

    await _record.start(path: voiceFilePath);
    _isRecording = true;

    notifyListeners();

    showToast('Recording Started');
  }

 Future<File> stopRecording(int index) async {
    String? audioFilePath;

    if (await _record.isRecording()) {
      audioFilePath = '${await _record.stop()}';
      showToast('Recording Stopped');
    }

    print('Audio file path: $audioFilePath');

    _isRecording = false;
    _afterRecordingFilePath = audioFilePath ?? '';
    if(_afterRecordingFilePath.isNotEmpty) {
         String res= await  saveFile(await File(_afterRecordingFilePath).readAsBytes());
         return File(res);
   

    }

    notifyListeners();
    return File('');
 
  }

}
