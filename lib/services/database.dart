import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> createUser(String uid, String firstname, String lastname) async {
    return await userCollection
        .doc(uid)
        .set({'firstname': firstname, 'lastname': lastname});
  }
}
