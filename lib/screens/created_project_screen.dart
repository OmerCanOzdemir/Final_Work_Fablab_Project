import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:fablab_project_final_work/screens/invitation_screen.dart';
import 'package:fablab_project_final_work/screens/project_details_screen.dart';
import 'package:fablab_project_final_work/screens/task_project_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreatedProject extends StatefulWidget {
  const CreatedProject({Key key}) : super(key: key);

  @override
  _CreatedProjectState createState() => _CreatedProjectState();
}

class _CreatedProjectState extends State<CreatedProject> {
  User user = FirebaseAuth.instance.currentUser;
  var data;
  Future<void> inizializeData() async {
    Response response = await Dio().get(
        "https://finalworkapi.azurewebsites.net/api/User/byId/" + user.uid);

    data = response.data["user"]["created_Projects"];
    print(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: inizializeData(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                Fluttertoast.showToast(
                    msg: snapshot.error.toString(),
                    fontSize: 18,
                    gravity: ToastGravity.BOTTOM);
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: "Loading",
                  ),
                );
              }
              return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Ink.image(
                                  image: NetworkImage(data[index]["image_Url"]),
                                  height: 240,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                    bottom: 16,
                                    right: 16,
                                    left: 16,
                                    child: Text(
                                      data[index]["title"],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 24,
                                      ),
                                    ))
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.all(16).copyWith(bottom: 0),
                              child: Text(
                                data[index]["coverDescription"],
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            ButtonBar(
                              alignment: MainAxisAlignment.start,
                              children: [
                                FlatButton(
                                  child: Text("Meer informatie"),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProjectDetails(
                                                  projectId: data[index]["id"],
                                                )));
                                  },
                                ),
                                FlatButton(
                                  child: Text("Beheer taken"),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => TaskProject(
                                                  projectId: data[index]["id"],
                                                  creator: true,
                                                )));
                                  },
                                ),
                                FlatButton(
                                  child: Text("Nodig andere gebruikers"),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                InvitationScreen(
                                                  id: data[index]["id"],
                                                )));
                                  },
                                )
                              ],
                            )
                          ],
                        ));
                  });
            }));
  }
}
