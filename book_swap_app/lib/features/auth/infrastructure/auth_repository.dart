import 'package:firebase_auth/firebase_auth.dart';
import 'package:book_swap_app/features/auth/domain/auth_exception.dart';

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository(this._auth);

  /// Provides a stream of the current authentication state (logged in or out).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Gets the current user, if one exists.
  User? get currentUser => _auth.currentUser;

  /// Signs up a new user with email and password.
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      // These are the errors you should screenshot for your reflection!
      if (e.code == 'weak-password') {
        throw AuthException('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('An account already exists for that email.');
      } else {
        throw AuthException(e.message ?? 'An unknown error occurred.');
      }
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  /// Sends the email verification link to the current user.
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      // Screenshot this!
      throw AuthException(e.message ?? 'Could not send verification email.');
    }
  }

  /// Signs in an existing user with email and password.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      // Screenshot this!
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw AuthException('Invalid email or password.');
      } else {
        throw AuthException(e.message ?? 'An unknown error occurred.');
      }
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }
}