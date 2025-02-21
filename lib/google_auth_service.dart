import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger _logger = Logger();

  // Specify the client ID explicitly for web
  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: "276273650987-ipbcoojem94m9kp34etd8mn2bjad1ajt.apps.googleusercontent.com",
    scopes: ['email'],
  );

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Save user data in Firestore if it doesn't already exist
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final userDoc = await userRef.get();

        if (!userDoc.exists) {
          await userRef.set({
            'name': user.displayName,
            'email': user.email,
            'isAdmin': false,
          });
        }
        return user;
      }
      return null;
    } catch (e) {
      _logger.e("Google Sign-In Error", error: e);
      if (e is FirebaseAuthException) {
        _logger.e("Firebase Auth Error", error: e, stackTrace: StackTrace.current);
        throw FirebaseAuthException(
          code: e.code,
          message: "Authentication failed: ${e.message}",
        );
      } else if (e is PlatformException) {
        _logger.e("Platform Error", error: e, stackTrace: StackTrace.current);
        throw PlatformException(
          code: e.code,
          message: "Platform error: ${e.message}",
          details: e.details,
        );
      }
      throw Exception("An unexpected error occurred during sign-in");
    }
  }

  Future<bool> isSignInSuccessful() async {
    try {
      final user = await signInWithGoogle();
      return user != null;
    } catch (e) {
      _logger.e("Sign-In Check Error", error: e);
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
