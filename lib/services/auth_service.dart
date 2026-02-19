import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<dynamic> authStateChanges() => _auth.authStateChanges();

  String? get currentUid => _auth.currentUser?.uid;

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUp(String name, String email, String password, String role) async {
    try {
      // Create Firebase auth user with 15-second timeout
      final cred = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 15), 
            onTimeout: () => throw Exception('Account creation timed out. Please try again.'));

      final user = cred.user!;
      final profile = JanataUser(
        uid: user.uid, 
        name: name, 
        email: user.email ?? '', 
        role: role
      );

      try {
        // Save user profile to Firestore
        await _db
            .collection('users')
            .doc(user.uid)
            .set(profile.toMap())
            .timeout(const Duration(seconds: 15),
              onTimeout: () => throw Exception('Profile save timed out. Please try again.'));
      } on FirebaseException catch (fe) {
        // If Firestore write fails, rollback by deleting the auth user
        try {
          await user.delete();
        } catch (e) {
          // Ignore cleanup errors
        }

        if (fe.code == 'permission-denied') {
          throw Exception('Unable to save profile. Please check your Firestore security rules.');
        }
        rethrow;
      }

      return cred;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'configuration-not-found') {
        throw Exception('Authentication not configured. Please contact support.');
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<JanataUser?> getProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return JanataUser.fromMap(doc.data()!);
  }

  Future<void> updateProfile(
    String uid, {
    String? name,
    String? bio,
    String? education,
    String? works,
    String? phone,
    String? gender,
    String? province,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (bio != null) updates['bio'] = bio;
    if (education != null) updates['education'] = education;
    if (works != null) updates['works'] = works;
    if (phone != null) updates['phone'] = phone;
    if (gender != null) updates['gender'] = gender;
    if (province != null) updates['province'] = province;
    
    if (updates.isNotEmpty) {
      await _db.collection('users').doc(uid).update(updates);
    }
  }
} 

