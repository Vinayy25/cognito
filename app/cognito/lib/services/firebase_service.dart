

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService{
 final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String> signInWithGoogle( ) async {
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
      throw e;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  void createUserDocument()async{
    final User? user = _firebaseAuth.currentUser;
    final DocumentReference documentReference = FirebaseFirestore.instance.collection('users').doc(user?.uid);
    documentReference.set({
      'email': user?.email,
      'name': user?.displayName,
      'photoUrl': user?.photoURL,
    });

  }
}
