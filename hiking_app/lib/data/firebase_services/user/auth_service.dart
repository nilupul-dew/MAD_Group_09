import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

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

  // Load user data from Firestore
  static Future<Map<String, dynamic>?> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return {
        'uid': user.uid,
        'firstName': data['firstName'],
        'lastName': data['lastName'],
        'email': user.email,
        'address': data['address'],
        'gender': data['gender'],
        'country': data['country'],
        'profileImage': data['profileImage'], // <- IMAGE URL
      };
    } catch (e) {
      print('❌ Failed to load user data: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserDataById(String userId) async {
    if (userId.isEmpty) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) {
        print('❌ User with ID $userId not found');
        return null;
      }

      final data = doc.data()!;
      return {
        'uid': userId,
        'firstName': data['firstName'],
        'lastName': data['lastName'],
        'email': data['email'],
        'address': data['address'],
        'gender': data['gender'],
        'country': data['country'],
        'profileImage': data['profileImage'],
        'createdAt': data['createdAt'],
        'updatedAt': data['updatedAt'],
      };
    } catch (e) {
      print('❌ Failed to load user data for ID $userId: $e');
      return null;
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
    Uint8List? profileImage,
    String? imageName,
  }) async {
    print("🔄 Updating user profile...$profileImage,$imageName");
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    Map<String, dynamic> updateData = {};

    if (address != null) updateData['address'] = address;
    if (gender != null) updateData['gender'] = gender;
    if (country != null) updateData['country'] = country;

    // Upload profile image if provided

    try {
      // Upload new image if provided
      if (profileImage != null) {
        final uploadedUrl = await uploadToImgBB(
            profileImage, imageName ?? 'profile_image_${user.uid}.jpg');
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          updateData['profileImage'] = uploadedUrl;
          print("🔄 Uploaded image URL: $uploadedUrl");
        } else {
          print(
            "⚠️ Image upload failed or returned null. Keeping existing image.",
          );
        }
      }
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }

    // Update Firestore document
    if (updateData.isNotEmpty) {
      await _firestore.collection('users').doc(user.uid).update(updateData);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print('Google sign out error: $e');
        // Continue with other sign outs
      }

      // Sign out from Facebook with error handling
      try {
        await _facebookAuth.logOut();
      } on MissingPluginException catch (e) {
        print('Facebook plugin not available: $e');
        // Continue with Firebase sign out
      } catch (e) {
        print('Facebook sign out error: $e');
        // Continue with Firebase sign out
      }

      // Always sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      // Still try to sign out from Firebase as fallback
      try {
        await _auth.signOut();
      } catch (firebaseError) {
        throw Exception('Complete sign out failed: $firebaseError');
      }
    }
  }

  // Check authentication state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Save user data to Firestore
  Future<void> _saveUserData(User user, String provider) async {
    // First check if user document exists and has a custom profile image
    final existingDoc =
        await _firestore.collection('users').doc(user.uid).get();

    Map<String, dynamic> userData = {
      'userId': user.uid,
      'email': user.email ?? '',
      'phone': user.phoneNumber ?? '',
      'signInProvider': provider,
      'createdDate': FieldValue.serverTimestamp(),
    };

    // Only set profileImage if user doesn't have one already
    if (!existingDoc.exists ||
        existingDoc.data()?['profileImage'] == null ||
        existingDoc.data()?['profileImage'] == '') {
      userData['profileImage'] = user.photoURL ?? '';
    }
    if (existingDoc['firstName'] == null || existingDoc['firstName'] == '') {
      userData['firstName'] = '';
    }
    if (existingDoc['lastName'] == null || existingDoc['lastName'] == '') {
      userData['lastName'] = '';
    }
    if (existingDoc['address'] == null || existingDoc['address'] == '') {
      userData['address'] = '';
    }
    if (existingDoc['gender'] == null || existingDoc['gender'] == '') {
      userData['gender'] = '';
    }
    if (existingDoc['country'] == null || existingDoc['country'] == '') {
      userData['country'] = '';
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userData, SetOptions(merge: true));
  }
  // Future<void> _saveUserData(User user, String provider) async {
  //   await _firestore.collection('users').doc(user.uid).set({
  //     'userId': user.uid,
  //     'email': user.email ?? '',
  //     'phone': user.phoneNumber ?? '',
  //     'profileImage': user.photoURL ?? '',
  //     'signInProvider': provider,
  //     'createdDate': FieldValue.serverTimestamp(),
  //     'firstName': '',
  //     'lastName': '',
  //     'address': '',
  //     'gender': '',
  //     'country': '',
  //   }, SetOptions(merge: true));
  // }

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

  Future<String?> uploadToImgBB(Uint8List imageBytes, String fileName) async {
    const apiKey = '7a6786581dabb83cf3d9fef912b12b8f';

    try {
      final base64Image = base64Encode(imageBytes);
      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload'),
        body: {'key': apiKey, 'image': base64Image, 'name': fileName},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['data']['url'];
        print("✅ Image uploaded to ImgBB: $imageUrl");
        return imageUrl;
      } else {
        print("❌ ImgBB upload failed: ${response.body}");
      }
    } catch (e) {
      print("❌ Error uploading to ImgBB: $e");
    }
    return null;
  }

  // 🟣 Compress image to reduce size
  Future<Uint8List?> compressImage(Uint8List originalBytes) async {
    try {
      final compressed = await FlutterImageCompress.compressWithList(
        originalBytes,
        quality: 60,
        minWidth: 800,
        minHeight: 800,
      );
      print(
        "📉 Compressed from ${originalBytes.lengthInBytes} → ${compressed.lengthInBytes} bytes",
      );
      return compressed;
    } catch (e) {
      print("❌ Compression failed: $e");
      return originalBytes;
    }
  }
}
