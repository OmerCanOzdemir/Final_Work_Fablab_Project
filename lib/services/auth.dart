import 'package:firebase_auth/firebase_auth.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Register in with email and password
  Future registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
          
      return userCredential.user.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return "Zwakke wachtwoord probeer opnieuw";
      } else if (e.code == 'email-already-in-use') {
        return "Deze email is al registreerd";
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
      return "U bent ingelogd";
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
