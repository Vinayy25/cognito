import 'package:cognito/models/chat_model.dart';
import 'package:cognito/screens/chat_screen.dart';
import 'package:cognito/states/chat_state.dart';
import 'package:cognito/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'AI Chat',
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key}); // Use super parameter here

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final ChatState chatModelProvider = Provider.of<ChatState>(
      context,
    );

    onSubmittedCallback(String value) {
      final String uuid = const Uuid().v4();

      chatModelProvider.addConversationId(uuid);
      chatModelProvider.chat(value.toString(), uuid);

      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => ChatScreen(
            conversationId: uuid,
            chatModelProvider: chatModelProvider,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE6F7F9),
      body: Center(
        child: Container(
          width: width,
          height: height,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture and Welcome Message
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF454A60),
                  child: Icon(
                    Iconsax.profile_circle,
                    size: 50,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Welcome to AI Chat',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF454A60),
                  ),
                ),
                const SizedBox(height: 20),

                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF454A60),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onSubmitted: (value) {
                            onSubmittedCallback(value);
                          },
                          style: TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Ask me anything...',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 251, 251, 251)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.image),
                        color: const Color.fromARGB(255, 250, 251, 254),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.mic),
                        color: const Color.fromARGB(255, 250, 251, 254),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Contents and Recordings Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF454A60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        elevation: 5, // Add elevation here
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.content_copy,
                              color: Color.fromARGB(255, 250, 251, 254)),
                          SizedBox(width: 8),
                          Text('Contents',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 250, 251, 254))),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF454A60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        elevation: 5, // Add elevation here
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.mic,
                              color: Color.fromARGB(255, 250, 251, 254)),
                          SizedBox(width: 8),
                          Text('Recordings',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 250, 251, 254))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Recent Section
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'RECENT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF454A60),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Recent Items
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: chatModelProvider.chatModel.conversations.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                      conversationId: chatModelProvider
                                          .chatModel
                                          .conversations[index]
                                          .conversationId,
                                      chatModelProvider: chatModelProvider,
                                    )),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          color: const Color(0xFF454A60),
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.chat_bubble_outline,
                                        size: 40,
                                        color:
                                            Color.fromARGB(255, 250, 251, 254)),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Conversation Title',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                              255, 250, 251, 254),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Text(
                                    'Brief summary of the conversation goes here...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 250, 251, 254),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Expanded(
                                  child: Text(
                                    'Brief summary of the conversation goes here...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 250, 251, 254),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
