import 'dart:convert';

import 'dart:io';

import 'package:cognito/services/firebase_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/scheduler.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

class HttpService {
  String? baseUrl = '';
  final dio = Dio();
  HttpService() {
    getbaseUrl().then((value) => baseUrl = value);
  }

  getbaseUrl() async {
    print("fetching ngrok url ");
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
          filename: "audio_file.mp3",
          audioFile.path,
        )));

    try {
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
    dio.options.followRedirects = false;

    dio.options.maxRedirects = 5;

    try {
      if (baseUrl == '') {
        await getbaseUrl().then((value) => baseUrl = value);
      }
 

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
    } catch (e) {
      print("Error: $e");
      throw Exception('Failed to check hi: $e');
    }
  }

  Future<String> queryWithHistory({
    required String user,
    required String query,
    required String id,
    String modelType = 'text',
  }) async {
    try {
      final fetchUrl = Uri.parse(
        '$baseUrl/gemini/with-history-no-stream',
      );
      final response = await dio.get(
        fetchUrl.path, // Replace with your actual endpoint URL
        queryParameters: {
          'user': user,
          'query': query,
          'id': id,
          'model_type': modelType,
        },
        options: Options(
          // responseType: ResponseType.stream, // To handle StreamingResponse
          // followRedirects: true,
          contentType: 'application/json',
          // maxRedirects: 5,
        ),
      );

      // Handle the response (streaming data)
      return response.data;
    } catch (e) {
    
      throw Exception('Failed to query with history: $e');
    }
  }

  // request to get conversation summary and name for templates
  


}
