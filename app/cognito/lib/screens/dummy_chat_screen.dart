import 'package:cognito/services/http_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class DummyChatScreen extends StatefulWidget {
  const DummyChatScreen({super.key});

  @override
  State<DummyChatScreen> createState() => _DummyChatScreenState();
}

class _DummyChatScreenState extends State<DummyChatScreen> {
  final TextEditingController promptController = TextEditingController();
  final StreamController<String> _streamController = StreamController<String>();

  @override
  void dispose() {
    // Properly dispose of the controllers
    promptController.dispose();
    _streamController.close();
    super.dispose();
  }

  void _fetchStream(String query)  {
    final newStream =  HttpService().queryWithHistoryAndTextStream(
      user: '123',
      query: query,
      id: '123',
      modelType: 'groq',
      performRAG: false,
      performWebSearch: false,
    );

    

    newStream.listen((data) {
      // Add data to the stream controller
      _streamController.add(data);
    }, onError: (error) {
      _streamController.addError(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Text('Dummy Chat Screen'),
            Container(
              width: 300,
              height: 700,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: StreamBuilder<String>(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Waiting for data...');
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return Text(snapshot.data!);
                  }
                  return const Text('No data yet.');
                },
              ),
            ),
            TextField(
              controller: promptController,
              onSubmitted: (value) {
                _fetchStream(value); // Fetch data from the API
                promptController.clear();
              },
            ),
            IconButton(
              onPressed: () {
                _fetchStream('Hello'); // Fetch default query
              },
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
