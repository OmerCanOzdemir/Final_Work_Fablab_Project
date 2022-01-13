import 'package:fablab_project_final_work/models/AppUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //Database service
  final DatabaseServices _databaseServices = DatabaseServices();
  //Register in with email and password
  Future registerWithEmailAndPassword(
      String email, String password, String firstname, String lastname) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await _databaseServices.createUser(
          userCredential.user.uid, firstname, lastname);
      return "Account aangemaakt";
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
