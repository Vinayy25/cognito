import 'dart:convert';
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

  Future<Stream<String>> queryWithHistory({
    required String user,
    required String query,
    required String id,
    String modelType = 'text',
  }) async {
    if (baseUrl == '') {
      baseUrl = await getbaseUrl();
    }
    baseUrl = 'https://fa24-152-58-239-232.ngrok-free.app';
    final response = await http.get(
      Uri.parse('$baseUrl/gemini/with-history').replace(queryParameters: {
        'user': user,
        'query': query,
        'id': id,
        'model_type': modelType,
      }),
      headers: {
        'Content-Type': 'application/json',
        'stream': 'true',
      },
    );

    if (response.statusCode == 200) {
      final stream = Stream<String>.fromIterable(response.body.split('\n'));
      return stream;
    } else {
      throw Exception('Failed to query with history: ${response.statusCode}');
    }
  }
}
