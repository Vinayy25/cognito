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
        // check if the user is new

        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(authCredential);
        final User? user = userCredential.user;
        if (userCredential.additionalUserInfo!.isNewUser) {
          return "NEW_USER";
        }
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
      if (email.isNotEmpty && password.isNotEmpty) {
        await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createUserAccount(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password);
        await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
      }
    } catch (e) {
      rethrow;
    }
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

  Future<Map<String, dynamic>> getConversationIds() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await _db
          .collection('users')
          .doc(email)
          .collection('conversation_ids')
          .doc('id')
          .get();

          print(documentSnapshot.data());

      if (!documentSnapshot.exists ||
          documentSnapshot.data()!['conversation_ids'] == null) {
            print("does not exist");
        return {};
      }

      Map<String, dynamic> x = {
        "conversation_ids": documentSnapshot.data()!['conversation_ids'],
        "conversation_details": documentSnapshot.data()!['conversation_details']
      };
      print("this is x"+ x.toString());
      return x;
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

 Future<void> saveSummaryAndTitle(ChatModel chatModel) async {
    // Reference to the user's document
    DocumentReference documentReference = _db
        .collection('users')
        .doc(email)
        .collection('conversation_ids')
        .doc('id');

    DocumentSnapshot documentSnapshot = await documentReference.get();

    List<dynamic> conversationDetails = [];

    // If the document exists and conversation_details is available, use it.
    if (documentSnapshot.exists) {
      final data = documentSnapshot.data() as Map<String, dynamic>;
      if (data['conversation_details'] != null) {
        conversationDetails = List.from(data['conversation_details']);
      }
    }

    // Create a lookup map for the conversations using dynamic since 'Conversation' isn't defined.
    final Map<String, dynamic> chatConversationsMap = {
      for (var conversation in chatModel.conversations)
        conversation.conversationId: conversation,
    };

    // Update each existing conversation if there's a matching conversation in chatModel.
    for (int i = 0; i < conversationDetails.length; i++) {
      final convId = conversationDetails[i]['conversation_id'];
      if (chatConversationsMap.containsKey(convId)) {
        final conversation = chatConversationsMap[convId];
        conversationDetails[i]['title'] =
            (conversation.conversationName == null ||
                    (conversation.conversationName is String &&
                        conversation.conversationName.isEmpty))
                ? 'New chat'
                : conversation.conversationName;
        conversationDetails[i]['summary'] =
            (conversation.conversationSummary == null ||
                    (conversation.conversationSummary is String &&
                        conversation.conversationSummary.isEmpty))
                ? 'Continue with your conversation...'
                : conversation.conversationSummary;
      }
    }

    // Add any new conversations from chatModel that are not yet in conversationDetails.
    for (final conversation in chatModel.conversations) {
      final exists = conversationDetails.any(
          (detail) => detail['conversation_id'] == conversation.conversationId);
      if (!exists) {
        conversationDetails.add({
          'conversation_id': conversation.conversationId,
          'title': (conversation.conversationName == null ||
                  (conversation.conversationName is String &&
                      conversation.conversationName!.isEmpty))
              ? 'New chat'
              : conversation.conversationName,
          'summary': (conversation.conversationSummary == null ||
                  (conversation.conversationSummary is String &&
                      conversation.conversationSummary!.isEmpty))
              ? 'Continue with your conversation...'
              : conversation.conversationSummary,
        });
      }
    }

    // Update the document with the modified conversation details.
    try {
      await documentReference.set(
        {'conversation_details': conversationDetails},
        SetOptions(merge: true),
      );
    } catch (e) {
      rethrow;
    }
  }


}
