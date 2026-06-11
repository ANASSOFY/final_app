import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/auth_repository.dart';

enum AuthStatus { unauthenticated, guest, authenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.uid,
    this.displayName,
    this.email,
    this.isLoading = false,
    this.errorMessage,
  });

  const AuthState.unauthenticated({this.isLoading = false, this.errorMessage})
    : status = AuthStatus.unauthenticated,
      uid = null,
      displayName = null,
      email = null;

  final AuthStatus status;
  final String? uid;
  final String? displayName;
  final String? email;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isGuest => status == AuthStatus.guest;

  String get resolvedName {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim();
    }

    if (isGuest) {
      return 'Guest Explorer';
    }

    return 'Explorer';
  }

  AuthState copyWith({
    AuthStatus? status,
    String? uid,
    String? displayName,
    String? email,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState.unauthenticated()) {
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      _lastKnownUser = currentUser;
      _hasActiveAuthenticatedSession = true;
      emit(_authenticatedState(currentUser));
    }

    _authSubscription = _authRepository.authStateChanges().listen((user) {
      if (user != null) {
        _lastKnownUser = user;
        _hasActiveAuthenticatedSession = true;
        _authOperationInProgress = false;
        _isGuestMode = false;
        emit(_authenticatedState(user));
        return;
      }

      if (_isGuestMode || state.isGuest) {
        emit(
          const AuthState(
            status: AuthStatus.guest,
            displayName: 'Guest Explorer',
          ),
        );
      } else if (_authOperationInProgress || state.isLoading) {
        return;
      } else if (_hasActiveAuthenticatedSession && _lastKnownUser != null) {
        emit(_authenticatedState(_lastKnownUser!));
        return;
      } else if (state.isAuthenticated && _authRepository.currentUser != null) {
        final currentUser = _authRepository.currentUser!;
        _lastKnownUser = currentUser;
        _hasActiveAuthenticatedSession = true;
        emit(_authenticatedState(currentUser));
      } else {
        emit(const AuthState.unauthenticated());
      }
    });
  }

  final AuthRepository _authRepository;
  StreamSubscription<AuthUser?>? _authSubscription;
  bool _isGuestMode = false;
  bool _authOperationInProgress = false;
  bool _hasActiveAuthenticatedSession = false;
  AuthUser? _lastKnownUser;

  Future<bool> signIn({required String email, required String password}) async {
    _authOperationInProgress = true;
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      _isGuestMode = false;
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _lastKnownUser = user;
      _hasActiveAuthenticatedSession = true;
      emit(_authenticatedState(user));
      return true;
    } on FirebaseAuthException catch (e) {
      _authOperationInProgress = false;
      emit(AuthState.unauthenticated(errorMessage: _firebaseErrorMessage(e)));
      return false;
    } on TimeoutException {
      _authOperationInProgress = false;
      emit(
        const AuthState.unauthenticated(
          errorMessage: 'Sign-in is taking too long. Check your connection.',
        ),
      );
      return false;
    } catch (_) {
      _authOperationInProgress = false;
      emit(
        const AuthState.unauthenticated(
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _authOperationInProgress = true;
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      _isGuestMode = false;
      final user = await _authRepository.registerWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );
      _lastKnownUser = user;
      _hasActiveAuthenticatedSession = true;
      emit(_authenticatedState(user));
      return true;
    } on FirebaseAuthException catch (e) {
      _authOperationInProgress = false;
      emit(AuthState.unauthenticated(errorMessage: _firebaseErrorMessage(e)));
      return false;
    } on TimeoutException {
      _authOperationInProgress = false;
      emit(
        const AuthState.unauthenticated(
          errorMessage:
              'Account creation is taking too long. Check your connection.',
        ),
      );
      return false;
    } catch (_) {
      _authOperationInProgress = false;
      emit(
        const AuthState.unauthenticated(
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _authOperationInProgress = true;
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      _isGuestMode = false;
      final user = await _authRepository.signInWithGoogle();
      _lastKnownUser = user;
      _hasActiveAuthenticatedSession = true;
      emit(_authenticatedState(user));
      return true;
    } on FirebaseAuthException catch (e) {
      _authOperationInProgress = false;
      emit(AuthState.unauthenticated(errorMessage: _firebaseErrorMessage(e)));
      return false;
    } on TimeoutException {
      _authOperationInProgress = false;
      emit(
        const AuthState.unauthenticated(
          errorMessage:
              'Google sign-in is taking too long. Check your connection and try again.',
        ),
      );
      return false;
    } catch (_) {
      _authOperationInProgress = false;
      emit(
        const AuthState.unauthenticated(
          errorMessage: 'Google sign-in failed. Please try again.',
        ),
      );
      return false;
    }
  }

  void continueAsGuest() {
    _authOperationInProgress = false;
    _hasActiveAuthenticatedSession = false;
    _lastKnownUser = null;
    _isGuestMode = true;
    emit(
      const AuthState(status: AuthStatus.guest, displayName: 'Guest Explorer'),
    );
  }

  Future<void> signOut() async {
    _authOperationInProgress = false;
    _hasActiveAuthenticatedSession = false;
    _lastKnownUser = null;
    _isGuestMode = false;
    await _authRepository.signOut();
  }

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }

    emit(state.copyWith(clearError: true));
  }

  AuthState _authenticatedState(AuthUser user) {
    _authOperationInProgress = false;
    return AuthState(
      status: AuthStatus.authenticated,
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      isLoading: false,
    );
  }

  String _firebaseErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'google-sign-in-cancelled':
        return 'Google sign-in was cancelled.';
      case 'sign_in_failed':
      case '10':
        return 'Google sign-in is not configured correctly. Add the Android SHA-1/SHA-256 fingerprints in Firebase, download google-services.json again, then rebuild the app.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
