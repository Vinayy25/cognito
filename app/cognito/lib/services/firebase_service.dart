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
    print("url is " + documentSnapshot.data()!['url']);
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

  Future<List<String>> getConversationIds() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await _db
          .collection('users')
          .doc(email)
          .collection('conversation_ids')
          .doc('id')
          .get();

      if (!documentSnapshot.exists ||
          documentSnapshot.data()!['conversation_ids'] == null) {
        return [];
      }
      return List<String>.from(documentSnapshot.data()!['conversation_ids']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, String>?>> getSummaryAndTitles(
      String conversationId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await _db
          .collection('users')
          .doc(email)
          .collection('conversation_ids')
          .doc('id')
          .get();
      return List<Map<String, String>>.from(
          documentSnapshot.data()!['conversation_details']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Chat>> getChats(String conversationId) async {
    DocumentReference conversationDocRef = _db
        .collection('users')
        .doc(email)
        .collection('conversations')
        .doc(conversationId);

    DocumentSnapshot conversationDocSnapshot = await conversationDocRef.get();

    if (conversationDocSnapshot.exists) {
      List<dynamic> chatData =
          (conversationDocSnapshot.data() as Map<String, dynamic>)['chats'];
      List<Chat> chats = chatData.map((data) => Chat.fromJson(data)).toList();
      return chats;
    } else {
      return [];
    }
  }

  Future<void> addChat(String conversationId, Chat chat) async {
    DocumentReference conversationDocRef = _db
        .collection('users')
        .doc(email)
        .collection('conversations')
        .doc(conversationId);

    DocumentSnapshot conversationDocSnapshot = await conversationDocRef.get();

    if (conversationDocSnapshot.exists) {
      List<dynamic> existingChats =
          (conversationDocSnapshot.data() as Map<String, dynamic>)['chats'];
      existingChats.add(chat.toJson());

      try {
        await conversationDocRef.update({'chats': existingChats});
      } catch (e) {
        rethrow;
      }
    } else {
      try {
        await conversationDocRef.set({
          'chats': [chat.toJson()]
        });
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<void> addConversationId(String id) async {
    try {
      DocumentReference documentReference = _db
          .collection('users')
          .doc(email)
          .collection('conversation_ids')
          .doc('id');

      DocumentSnapshot documentSnapshot = await documentReference.get();

      if (documentSnapshot.exists &&
          (documentSnapshot.data()
                  as Map<String, dynamic>)['conversation_ids'] !=
              null) {
        List<dynamic> conversationIds = (documentSnapshot.data()
            as Map<String, dynamic>)['conversation_ids'];

        if (conversationIds.contains(id)) {
          return;
        }
        conversationIds.add(id);
        await documentReference.update({'conversation_ids': conversationIds});
      } else {
        await documentReference.set({
          'conversation_ids': [id]
        }, SetOptions(merge: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveSummaryAndTitle(
    ChatModel chatModel,
  ) async {
    // Ref erence to the user's document

    DocumentReference documentReference = _db
        .collection('users')
        .doc(email)
        .collection('conversation_ids')
        .doc('id');

    DocumentSnapshot documentSnapshot = await documentReference.get();

    if (documentSnapshot.exists &&
        (documentSnapshot.data()
                as Map<String, dynamic>)['conversation_details'] !=
            null) {
      List<dynamic> conversationDetails = (documentSnapshot.data()
          as Map<String, dynamic>)['conversation_details'];

      conversationDetails = chatModel.conversations.map((conversation) {
        return {
          'conversation_id': conversation.conversationId,
          'title': conversation.conversationName,
          'summary': conversation.conversationSummary,
        };
      }).toList();
      await documentReference
          .update({'conversation_details': conversationDetails});
    } else {
      try {
        await documentReference.set({
          'conversation_details': chatModel.conversations.map((conversation) {
            return {
              'conversation_id': conversation.conversationId,
              'title': conversation.conversationName!,
              'summary': conversation.conversationSummary!,
            };
          }).toList()
        }, SetOptions(merge: true));
      } catch (e) {
        rethrow;
      }
    }
  }
}
