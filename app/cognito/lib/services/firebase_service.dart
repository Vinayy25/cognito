import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognito/models/chat_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _db = FirebaseFirestore.instance;

  final email = FirebaseAuth.instance.currentUser?.email;

  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential authCredential = GoogleAuthProvider.credential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken);

        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(authCredential);
        final User? user = userCredential.user;
        print(user?.email ?? "no email");
      } else {
        print("error");

        await _googleSignIn.signOut();
        return 'ERROR';
      }

      return 'SUCCESS';
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getNgrokUrl() async {
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await _db.collection('ngrok_URLs').doc('url').get();
    return documentSnapshot.data()!['url'];
  }

  void createUserDocument() async {
    final User? user = _firebaseAuth.currentUser;
    final DocumentReference documentReference =
        FirebaseFirestore.instance.collection('users').doc(user?.uid);
    documentReference.set({
      'email': user?.email,
      'name': user?.displayName,
      'photoUrl': user?.photoURL,
    });
  }

  Future<ChatModel?> getUserConversations() async {
    DocumentSnapshot docSnapshot =
        await _db.collection('conversations').doc(email).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('conversations')) {
        List<Conversations> conversations = (data['conversations'] as List)
            .map((item) => Conversations.fromJson(item as Map<String, dynamic>))
            .toList();
        return ChatModel(conversations: conversations);
      }
    } else {
      await _db
          .collection('conversations')
          .doc(email)
          .set({'conversations': []});
    }
    return null;
  }

  Future<void> addConversation(Conversations conversation) async {
    DocumentReference userDocRef = _db.collection('conversations').doc(email);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    if (userDocSnapshot.exists) {
      List<dynamic> existingConversations =
          (userDocSnapshot.data() as Map<String, dynamic>)['conversations'];
      existingConversations.add(conversation.toJson());
      await userDocRef.update({'conversations': existingConversations});
    } else {
      await userDocRef.set({
        'conversations': [conversation.toJson()]
      });
    }
  }
}

