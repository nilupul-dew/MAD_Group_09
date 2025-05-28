import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user exists (for sign up vs sign in)
  Future<bool> userExists({String? email, String? phoneNumber}) async {
    try {
      if (email != null) {
        final methods = await _auth.fetchSignInMethodsForEmail(email);
        return methods.isNotEmpty;
      }
      if (phoneNumber != null) {
        // For phone numbers, we'll check Firestore
        final query = await _firestore
            .collection('users')
            .where('phone', isEqualTo: phoneNumber)
            .get();
        return query.docs.isNotEmpty;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Email Sign Up (new users)
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserData(userCredential.user!, 'email');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  // Email Sign In (existing users)
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserData(userCredential.user!, 'email');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _saveUserData(userCredential.user!, 'google');
      return userCredential;
    } catch (e) {
      throw FirebaseAuthException(code: 'google-signin-failed', message: '$e');
    }
  }

  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login();
      if (result.status != LoginStatus.success) return null;

      final credential = FacebookAuthProvider.credential(
        result.accessToken!.token,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _saveUserData(userCredential.user!, 'facebook');
      return userCredential;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'facebook-signin-failed',
        message: '$e',
      );
    }
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (_) {},
      verificationFailed: (e) => onError(e.message ?? "Verification failed"),
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<UserCredential> signInWithOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    await _saveUserData(userCredential.user!, 'phone');
    return userCredential;
  }

  // Update display name
  Future<void> updateDisplayName(String firstName, String lastName) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    final displayName = lastName.isEmpty ? firstName : '$firstName $lastName';
    await user.updateDisplayName(displayName);

    // Also update in Firestore
    await _firestore.collection('users').doc(user.uid).update({
      'firstName': firstName,
      'lastName': lastName,
    });
  }

  // Update user profile with image upload
  Future<void> updateUserProfile({
    String? address,
    String? gender,
    String? country,
    File? profileImage,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    Map<String, dynamic> updateData = {};

    if (address != null) updateData['address'] = address;
    if (gender != null) updateData['gender'] = gender;
    if (country != null) updateData['country'] = country;

    // Upload profile image if provided
    if (profileImage != null) {
      try {
        final ref = _storage.ref().child('profile_images/${user.uid}');
        await ref.putFile(profileImage);
        final downloadUrl = await ref.getDownloadURL();
        
        // Update Firebase Auth profile
        await user.updatePhotoURL(downloadUrl);
        
        // Update Firestore
        updateData['profileImage'] = downloadUrl;
      } catch (e) {
        throw Exception('Failed to upload profile image: $e');
      }
    }

    // Update Firestore document
    if (updateData.isNotEmpty) {
      await _firestore.collection('users').doc(user.uid).update(updateData);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _facebookAuth.logOut();
    await _auth.signOut();
  }

  // Check authentication state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Save user data to Firestore
  Future<void> _saveUserData(User user, String provider) async {
    await _firestore.collection('users').doc(user.uid).set({
      'userId': user.uid,
      'email': user.email ?? '',
      'phone': user.phoneNumber ?? '',
      'profileImage': user.photoURL ?? '',
      'signInProvider': provider,
      'createdDate': FieldValue.serverTimestamp(),
      'firstName': '',
      'lastName': '',
      'address': '',
      'gender': '',
      'country': '',
    }, SetOptions(merge: true));
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete profile image from Storage
      try {
        await _storage.ref().child('profile_images/${user.uid}').delete();
      } catch (e) {
        // Image might not exist, continue with account deletion
      }
      
      // Delete user account
      await user.delete();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}