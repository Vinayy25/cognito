import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

Future<void> initializeConversations(String email) async {
  try {
    final String uuid = email;
    final db = FirebaseFirestore.instance;

    final Map<String, List<Map<String, String>>> data = {"chats": []};
    final Map<String, dynamic> idData = {
      "conversation_ids": [uuid], 
      "conversation_details": [
        {
          "conversation_id": uuid,
          "summary": "Continue with your conversation...",
          "title": "New chat"
        }
      ]
    };

    WriteBatch batch = db.batch();

    // Add the conversations document to the batch
    DocumentReference conversationsRef =
        db.collection('users').doc(email).collection('conversations').doc(uuid);
    batch.set(conversationsRef, data);

    // Add the conversation_ids document to the batch
    DocumentReference conversationIdsRef = db
        .collection('users')
        .doc(email)
        .collection('conversation_ids')
        .doc("id");
    batch.set(conversationIdsRef, idData);



    await batch.commit();

    print("Conversation data initialized for user: $email");
  } catch (e) {
    print("Error initializing conversations: $e");
    rethrow;
  }
}
