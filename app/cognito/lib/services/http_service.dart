import 'dart:convert';

import 'dart:io';

import 'package:cognito/services/firebase_service.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

class HttpService {
  String? baseUrl = '';
  HttpService() {
    getbaseUrl().then((value) => baseUrl = value);
  }

  getbaseUrl() async {
    return FirebaseService().getNgrokUrl();
  }

  Future<String> sendAudioRequest(String filePath) async {
    final dio = Dio();
    final formData = FormData();
    dio.options.followRedirects = false;

    dio.options.maxRedirects = 5;
    final audioFile = File(filePath);
    dio.options.headers['content-Type'] = 'multipart/form-data';

    formData.files.add(MapEntry(
        "audio_file",
        await MultipartFile.fromFile(
          filename: "vinay.mp3",
          audioFile.path,
        )));

    try {
      if (baseUrl == '') {
        await getbaseUrl().then((value) => baseUrl = value);
      }
      print(baseUrl);
      print("reached here");

      var response = await dio.postUri(
        Uri.parse(
            "$baseUrl/transcribe/"), // Replace "your_server_address" with your actual server address
        // "$baseUrl/transcribe", // Replace "your_server_address" with your actual server address
        data: formData,
        options: Options(
          followRedirects: true,
          contentType: 'multipart/form-data',
          maxRedirects: 5,
        ),
        onSendProgress: (sent, total) {
          print("Progress: $sent/$total");
        },
      );
      if (response.statusCode == 307) {
        final redirectUrl = response.headers['location']?.first;
        print(redirectUrl);
        if (redirectUrl != null) {
          final redirectResponse = await dio.post(
            redirectUrl,
            data: formData,
            onSendProgress: (sent, total) {
              print("Progress: $sent/$total");
            },
          );
          response = redirectResponse;
        }
      }

      final myresponse = response.data;
      print(response);
      print(myresponse['transcription']);
      return myresponse['transcription'];
    } catch (e) {
      print("Error: $e");
    }
    return '';
  }

  Future<String> checkHi() async {
    final dio = Dio();
    dio.options.followRedirects = false;

    dio.options.maxRedirects = 5;

    try {
      if (baseUrl == '') {
        await getbaseUrl().then((value) => baseUrl = value);
      }
      print(baseUrl);
      print("reached here");

      var response = await dio.post(
        // Uri.parse("$baseUrl/sayio"), // Replace "your_server_address" with your actual server address
        "$baseUrl/sayhi/",

        options: Options(
          followRedirects: true,
          contentType: 'application/json',
          maxRedirects: 5,
        ),
        onSendProgress: (sent, total) {
          print("Progress: $sent/$total");
        },
      );
      if (response.statusCode == 307) {
        final redirectUrl = response.headers['location']?.first;
        print(redirectUrl);
        if (redirectUrl != null) {
          final redirectResponse = await dio.post(
            redirectUrl,
            onSendProgress: (sent, total) {
              print("Progress: $sent/$total");
            },
          );
          response = redirectResponse;
        }
      }

      final myresponse = response.data;
      return myresponse['message'];
    } on DioError catch (e) {
      print("Error: $e");
    }
    return '';
  }

  // Future<String> sendAudioFileToTranscribe(File audioFile) async {
  //   try {
  //     if (baseUrl == '') {
  //       await getbaseUrl().then((value) => baseUrl = value);
  //     }
  //     String url = '$baseUrl/transcribe';
  //     var request = http.MultipartRequest('POST', Uri.parse(url));
  //     // Add the audio file to the request
  //     var fileStream = http.ByteStream(audioFile.openRead());
  //     var fileLength = await audioFile.length();
  //     var fileName = audioFile.path.split('/').last;
  //     var mimeType =
  //         MediaType('audio', 'mp3'); // Adjust the mime type accordingly
  //     var audioFilePart = http.MultipartFile(
  //       'audio_file',
  //       fileStream,
  //       fileLength,
  //       filename: fileName,
  //       contentType: mimeType,
  //     );
  //     request.files.add(audioFilePart);

  //     // Send the request
  //     var streamedResponse = await request.send();

  //     // Get the response
  //     var response = await http.Response.fromStream(streamedResponse);

  //     // Check if the request was successful
  //     if (response.statusCode == 200) {
  //       // Parse the JSON response
  //       var jsonResponse = jsonDecode(response.body);
  //       // Get the transcription from the response
  //       var transcription = jsonResponse['transcription'];
  //       return transcription;
  //     } else {
  //       // Handle other status codes (e.g., 500 for internal server error)
  //       throw Exception('Failed to transcribe audio: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     // Handle any exceptions that occur during the request
  //     throw Exception('Failed to transcribe audio: $e');
  //   }
  // }
}
