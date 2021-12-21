import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Get current state of user
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  //Register in with email and password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return "Account aangemaakt";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return "Zwakke wachtwoord probeer opnieuw";
      } else if (e.code == 'email-already-in-use') {
        return "Deze email is registreerd";
      }
    } catch (e) {
      return e;
    }
  }

  //Login with email and password
  Future loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "Account bestaat niet";
      } else if (e.code == 'wrong-password') {
        return "Foute wachtwoord probeer opnieuw";
      }
    }
  }

  //Logout
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return e.toString();
    }
  }
}
