import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cognito/services/firebase_service.dart';

class HttpService {
  String? baseUrl = '';

  HttpService() {
    getbaseUrl().then((value) => baseUrl = value);
  }

  Future<String> getbaseUrl() async {
    print("fetching ngrok url ");
    return FirebaseService().getNgrokUrl();
  }

  Future<String> queryWithHistory({
    required String user,
    required String query,
    required String id,
    String modelType = 'text',
  }) async {
    if (baseUrl == '') {
      baseUrl = await getbaseUrl();
    }
    final response = await http.get(
      Uri.parse('$baseUrl/gemini/with-history-no-stream')
          .replace(queryParameters: {
        'user': user,
        'query': query,
        'id': id,
        'model_type': modelType,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final modelResponse = jsonDecode(utf8.decode(response.bodyBytes));

      return modelResponse['response'];
    } else {
      throw Exception('Failed to query with history: ${response.statusCode}');
    }
  }

  Future<String> transcribeAndSave({
    required String user,
    required String conversationId,
    required File audioFile,
  }) async {
    if (baseUrl == '') {
      baseUrl = await getbaseUrl();
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/transcribe/save').replace(queryParameters: {
        'user': user,
        'conversation_id': conversationId,
      }),
    )
      ..fields['user'] = user
      ..fields['conversation_id'] = conversationId
      ..files.add(await http.MultipartFile.fromPath(
        'audio_file',
        audioFile.path,
      ))
      ..headers['Content-Type'] = 'multipart/form-data';

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final responseJson = jsonDecode(responseBody);
      return responseJson['transcription'];
    } else {
      throw Exception('Failed to transcribe and save: ${response.statusCode}');
    }
  }
}
