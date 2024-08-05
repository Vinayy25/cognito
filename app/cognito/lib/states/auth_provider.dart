import 'package:cognito/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthStateProvider extends ChangeNotifier {
  bool isAuthenticated = false;
  bool signInPage = true;

  String email = "";
  AuthStateProvider() {
    checkAuthStatus();
  }
  bool isNewUser = false;

  void toggleSignInPage() {
    signInPage = !signInPage;
    notifyListeners();
  }

  void setAuthenticated(bool value) {
    isAuthenticated = value;
    notifyListeners();
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();

    await FirebaseService().signOut();
    isAuthenticated = false;
    notifyListeners();
  }

  final auth = FirebaseAuth.instance;

  Future<void> logoutAll() async {
    await FirebaseService().signOut();
    await auth.signOut();
  }

  void checkAuthStatus() async{
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        isAuthenticated = false;
        print("my State: $isAuthenticated");
        notifyListeners();
      } else {
        isAuthenticated = true;
        email = user.email!;
        notifyListeners();
      }
    });
  }
}
