import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:olearn/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email address.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = 'Invalid email address format.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;
        default:
          message = 'Login failed: ${e.message}';
      }
      throw AuthException(message);
    } catch (e) {
      throw AuthException('An unexpected error occurred. Please try again.');
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw AuthException('Google sign in was cancelled');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      // Strictly use Google displayName as the user's name
      if (userCredential.user != null) {
        await _createOrUpdateUser(userCredential.user!, name: googleUser.displayName ?? '');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message = 'An account already exists with the same email address but different sign-in credentials.';
          break;
        case 'invalid-credential':
          message = 'Invalid Google sign-in credentials.';
          break;
        case 'operation-not-allowed':
          message = 'Google sign-in is not enabled.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        case 'user-not-found':
          message = 'No user found for that email address.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;
        default:
          message = 'Google sign-in failed: ${e.message}';
      }
      throw AuthException(message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Google sign-in failed. Please try again.');
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update user profile with the real name
        await userCredential.user!.updateDisplayName(name);
        
        // Strictly use the provided name
        await _createOrUpdateUser(userCredential.user!, name: name);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account with this email address already exists.';
          break;
        case 'invalid-email':
          message = 'Invalid email address format.';
          break;
        case 'weak-password':
          message = 'Password is too weak. Please use at least 6 characters.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password sign up is not enabled.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;
        default:
          message = 'Registration failed: ${e.message}';
      }
      throw AuthException(message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('An unexpected error occurred. Please try again.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('Sign out failed. Please try again.');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email address.';
          break;
        case 'invalid-email':
          message = 'Invalid email address format.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;
        default:
          message = 'Password reset failed: ${e.message}';
      }
      throw AuthException(message);
    } catch (e) {
      throw AuthException('An unexpected error occurred. Please try again.');
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? photoUrl,
    String? bio,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AuthException('No user logged in');

      // Update Firebase Auth profile
      if (name != null) {
        await user.updateDisplayName(name);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Update Firestore document
      final userData = <String, dynamic>{};
      if (name != null) userData['name'] = name;
      if (photoUrl != null) userData['photoUrl'] = photoUrl;
      if (bio != null) userData['bio'] = bio;

      if (userData.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(userData);
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Profile update failed. Please try again.');
    }
  }

  // Create or update user document in Firestore
  Future<void> _createOrUpdateUser(User user, {required String name}) async {
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    
    if (!userDoc.exists) {
      // Create new user document with the real name
      final newUser = UserModel(
        id: user.uid,
        email: user.email!,
        name: name,
        photoUrl: user.photoURL,
        bio: '',
        progress: <String, dynamic>{},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(newUser.toJson());
    } else {
      // Update existing user document
      final userData = userDoc.data() as Map<String, dynamic>;
      if (name != userData['name'] || user.photoURL != userData['photoUrl']) {
        await _firestore.collection('users').doc(user.uid).update({
          'name': name,
          'photoUrl': user.photoURL ?? userData['photoUrl'],
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw AuthException('Failed to load user data. Please try again.');
    }
  }

  // Create admin user (for testing purposes)
  Future<void> createAdminUser(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update user profile
        await userCredential.user!.updateDisplayName(name);
        
        // Create admin user document in Firestore
        final adminUser = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          name: name,
          photoUrl: userCredential.user!.photoURL,
          bio: 'System Administrator',
          role: 'admin', // Set as admin
          progress: <String, dynamic>{},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(userCredential.user!.uid).set(adminUser.toJson());
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account with this email address already exists.';
          break;
        case 'invalid-email':
          message = 'Invalid email address format.';
          break;
        case 'weak-password':
          message = 'Password is too weak. Please use at least 6 characters.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password sign up is not enabled.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;
        default:
          message = 'Admin creation failed: ${e.message}';
      }
      throw AuthException(message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('An unexpected error occurred. Please try again.');
    }
  }
}

// Custom exception class for authentication errors
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
} 