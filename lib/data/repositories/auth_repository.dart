import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthUser {
  const AuthUser({
    required this.uid,
    this.displayName,
    this.email,
  });

  final String uid;
  final String? displayName;
  final String? email;
}

class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  Stream<AuthUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_mapUser);
  }

  AuthUser? get currentUser => _mapUser(_firebaseAuth.currentUser);

  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth
        .signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        )
        .timeout(_authTimeout);

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user returned from Firebase Auth.',
      );
    }

    return _mapUser(user)!;
  }

  Future<AuthUser> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth
        .createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        )
        .timeout(_authTimeout);

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user returned from Firebase Auth.',
      );
    }

    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty) {
      await user.updateDisplayName(trimmedName).timeout(_authTimeout);
      await user.reload().timeout(_authTimeout);
    }

    return _mapUser(_firebaseAuth.currentUser ?? user)!;
  }

  Future<AuthUser> signInWithGoogle() async {
    try {
      try {
        await _googleSignIn.signOut().timeout(_googleTimeout);
      } on TimeoutException {
        await _googleSignIn.disconnect().timeout(_googleTimeout);
      } catch (_) {
        // A stale Google session should not block opening the account picker.
      }

      final googleUser = await _googleSignIn.signIn().timeout(_googleTimeout);

      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'google-sign-in-cancelled',
          message: 'Google sign-in was cancelled.',
        );
      }

      final googleAuth = await googleUser.authentication.timeout(
        _googleTimeout,
      );
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth
          .signInWithCredential(credential)
          .timeout(_authTimeout);
      final user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user returned from Google sign-in.',
        );
      }

      return _mapUser(user)!;
    } on PlatformException catch (error) {
      throw FirebaseAuthException(
        code: error.code,
        message: error.message ?? 'Google sign-in failed.',
      );
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  AuthUser? _mapUser(User? user) {
    if (user == null) {
      return null;
    }

    return AuthUser(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
    );
  }

  static const Duration _authTimeout = Duration(seconds: 25);
  static const Duration _googleTimeout = Duration(seconds: 20);
}
