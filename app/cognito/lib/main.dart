import 'package:cognito/firebase_options.dart';
import 'package:cognito/screens/auth_screen.dart';
import 'package:cognito/screens/chat_screen.dart';
import 'package:cognito/screens/dummy_chat_screen.dart';
import 'package:cognito/screens/main_screen.dart';
import 'package:cognito/states/auth_provider.dart';
import 'package:cognito/states/chat_state.dart';
import 'package:cognito/states/data_provider.dart';
import 'package:cognito/states/play_audio_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
  
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthStateProvider()),
          ChangeNotifierProvider(create: (_) => ChatState()),
          // ChangeNotifierProvider(create: (_) => PlayAudioProvider()),
          ChangeNotifierProvider(create: (_) => Data()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Chat app',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            fontFamily: 'Montserrat',
          ),
          home: Consumer<AuthStateProvider>(
            builder: (context, provider, child) {
              if (provider.isAuthenticated) {
               
                return Consumer<ChatState>(
                  builder: (context, chatState, child) {
                    if (provider.isNewUser == true) {
                      return ChatScreen(
                        conversationId: provider.email,
                        chatModelProvider: chatState,
                      );
                    } else {
                      return MainScreen(
                        chatModelProvier: chatState,
                      );
                    }
                  },
                );
              } else {
                return LoginPage(
                  authProvider: provider,
                );
              }
            },
          ),
        ));
  }
}
