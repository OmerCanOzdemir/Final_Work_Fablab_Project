import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference projectCollection =
      FirebaseFirestore.instance.collection('project');

  Future<void> createUser(String uid, String firstname, String lastname) async {
    return await userCollection.doc(uid).set({
      'firstname': firstname,
      'lastname': lastname,
      "Degree": "Toegepaste informatica",
      "joined projects": []
    });
  }

  Future<void> createProject(String userUid, String title,
      String littleDescription, String description, String maxPerson) async {
    return await projectCollection.add({
      "title": title,
      "littleDescription": littleDescription,
      "description": description,
      "maxPerson": maxPerson,
      "author": userUid,
      "joinedPersons": [userUid]
    });
  }

  Future<void> addPersonToProject(List persons, String id, String uid) async {
    List<dynamic> ids = [id];
    await projectCollection.doc(id).update({"joinedPersons": persons});
    await userCollection
        .doc(uid)
        .update({"joined projects": FieldValue.arrayUnion(ids)});
  }

  Future<void> deleteProject(String id) async {
    return await projectCollection.doc(id).delete();
  }
}
