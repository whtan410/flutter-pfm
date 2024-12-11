import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'dart:developer';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _createUserDocument(User user, {String? displayName}) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        final newUser = UserModel(
          uid: user.uid,
          email: user.email!,
          displayName: displayName ?? user.displayName,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      }
    } catch (e) {
      log('Error creating user document: $e');
      rethrow;
    }
  }

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);
      
      // Create/update user document in Firestore
      await _createUserDocument(userCredential.user!);
      
      return userCredential.user;
    } catch (e) {
      log('Error in Google sign in: $e');
      rethrow;
    }
  }

  // Email/Password Sign Up
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await _createUserDocument(result.user!);
      return result.user;
    } catch (e) {
      log('Error in email sign up: $e');
      rethrow;
    }
  }

    // Email/Password Sign In
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      log('Error in email sign in : $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      
      if (user != null) {
        // Check if user signed in with Google
        final providerData = user.providerData;
        final isGoogleUser = providerData.any((userInfo) => 
          userInfo.providerId == 'google.com'
        );

        // Only sign out from Google if user used Google Sign-In
        if (isGoogleUser) {
          final googleSignIn = GoogleSignIn();
          if (await googleSignIn.isSignedIn()) {
            await googleSignIn.signOut();
          }
        }
      }

      // Always sign out from Firebase
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      log('Error signing out: $e');
      rethrow;
      } 
    }
}

 