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

  Future<String> queryWithHistory({
    required String user,
    required String query,
    required String id,
    String modelType = 'text',
  }) async {
    if (baseUrl == '') {
      baseUrl = await getbaseUrl();
    }
    baseUrl = 'https://8182-106-206-8-67.ngrok-free.app';
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
}
