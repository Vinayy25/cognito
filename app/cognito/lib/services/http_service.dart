import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:cognito/services/firebase_service.dart';
import 'package:http_parser/http_parser.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HttpService {
  String baseUrl;

  HttpService({required this.baseUrl});
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

  Stream<String> queryWithHistoryAndTextStream({
    required String user,
    required String query,
    required String id,
    String modelType = 'text',
    required bool performRAG, 
    required bool performWebSearch,
  }) async* {
    if (baseUrl == '') {
      baseUrl = await getbaseUrl();
    }

    final request = http.Request(
      'GET',
      Uri.parse('$baseUrl/groq/chat-stream/').replace(queryParameters: {
        'user': user,
        'query': query,
        'id': id,
        'model_type': modelType,
        'perform_rag': performRAG.toString(),
        'perform_web_search': performWebSearch.toString(),
      }),
    );

    request.headers['Content-Type'] = 'application/json';

    final response = await request.send();

    await for (var chunk in response.stream.transform(utf8.decoder)) {
      print(chunk);
      yield chunk;
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
      throw Exception(
          'Failed to transcribe and save: ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  Future<String> uploadPdf({
    required String user,
    required String conversationId,
    required File pdfFile,
  }) async {
    if (baseUrl == '') {
      baseUrl = await getbaseUrl();
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload/pdf'),
    )
      ..fields['user'] = user
      ..fields['conversation_id'] = conversationId
      ..files.add(await http.MultipartFile.fromPath(
        'pdf_file',
        pdfFile.path,
        contentType: MediaType('application', 'pdf'),
      ))
      ..headers['Content-Type'] = 'multipart/form-data';

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final responseJson = jsonDecode(responseBody);
      return responseJson['message'];
    } else {
      throw Exception('Failed to upload PDF: ${response.statusCode}');
    }
  }

  Future<Map<String, String>> getTopicsAndSummary(
    String user,
    String conversationId,
  ) async {
    if (baseUrl == '') {
      baseUrl = await getbaseUrl();
    }

    final response = await http.get(
      Uri.parse('$baseUrl/chat-summary-title/').replace(queryParameters: {
        'username': user,
        'conversation_id': conversationId,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final modelResponse = jsonDecode(utf8.decode(response.bodyBytes));

      return {
        'title': modelResponse['title'],
        'summary': modelResponse['summary'],
      };
    } else if (response.statusCode == 404) {
      return {
        'title': '',
        'summary': '',
      };
    } else if (response.statusCode == 500 || response.statusCode == 502) {
      return {
        'title': '',
        'summary': '',
      };
    } else {
      throw Exception(
          'Failed to query the summary and title: ${response.statusCode}');
    }

    // add conversation details to db
  }

  Future<bool> checkServerAvailavility() async {
    if (baseUrl == '') {
      print('Fetching base url');
      baseUrl = await getbaseUrl();
    }

    final response = await http.get(
      Uri.parse('$baseUrl/health'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
