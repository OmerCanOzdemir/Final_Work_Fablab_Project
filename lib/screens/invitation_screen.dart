import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fablab_project_final_work/navigation/dashboard.dart';
import 'package:fablab_project_final_work/screens/created_project_screen.dart';
import 'package:fablab_project_final_work/screens/my_projects_screen.dart';
import 'package:fablab_project_final_work/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class InvitationScreen extends StatefulWidget {
  String id;
  InvitationScreen({this.id});

  @override
  _InvitationScreen createState() => _InvitationScreen(id);
}

class _InvitationScreen extends State<InvitationScreen> {
  String id;
  _InvitationScreen(this.id);
  User user = FirebaseAuth.instance.currentUser;
  var data;
  var projectData;
  bool _isloading = false;
  bool _init = true;
  Future<void> inizializeData(bool init) async {
    if (init) {
      try {
        Response response = await Dio().get(
            "https://finalworkapi.azurewebsites.net/api/User",
            options: Options(headers: {
              "authorisation": "00000000-0000-0000-0000-000000000000"
            }));
        data = response.data["users"];
        data = data.where((item) => item["id"] != user.uid).toList();
        Response projectResponse = await Dio().get(
            "https://finalworkapi.azurewebsites.net/api/Project/" + id,
            options: Options(headers: {
              "authorisation": "00000000-0000-0000-0000-000000000000"
            }));
        projectData = projectResponse.data["project"];
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: inizializeData(true),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            child: Text(snapshot.error),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting || _isloading) {
          return Scaffold(
            appBar: AppBar(title: Text("Gebruikers uitnodigen")),
            body: Center(
              child: CircularProgressIndicator(
                semanticsLabel: "Loading",
                backgroundColor: Colors.white,
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
              appBar: AppBar(
                title: Text("Gebruikers uitnodigen"),
              ),
              body: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) => Card(
                        child: ListTile(
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundImage: data[index]["imageUrl"] != null
                                  ? NetworkImage(data[index]["imageUrl"])
                                  : AssetImage("assets/profile.png"),
                            ),
                            title: Text(data[index]["firstname"] +
                                " " +
                                data[index]["lastname"]),
                            subtitle: Text(data[index]["email"]),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Profile(
                                                  userId: data[index]["id"],
                                                )));
                                  },
                                  icon: Icon(Icons.person)),
                              IconButton(
                                  onPressed: () async {
                                    var dataInvitation = {
                                      "from": user.email,
                                      "projectDescription":
                                          projectData["description"],
                                      "titleProject": projectData["title"],
                                      "userId": data[index]["id"],
                                      "projectId": id
                                    };
                                    setState(() {
                                      _init = false;
                                      _isloading = true;
                                    });
                                    Response response = await Dio().post(
                                      "https://finalworkapi.azurewebsites.net/api/User/invite",
                                      options: Options(headers: {
                                        HttpHeaders.contentTypeHeader:
                                            "application/json",
                                        "authorisation":
                                            "00000000-0000-0000-0000-000000000000"
                                      }),
                                      data: jsonEncode(dataInvitation),
                                    );
                                    if (response.data["statusCode" == 200]) {
                                      Fluttertoast.showToast(
                                          msg: "Gebruiker uitgenodigd",
                                          fontSize: 18,
                                          gravity: ToastGravity.BOTTOM);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MyProjects()));
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: response.data["errorMessage"]
                                              .toString(),
                                          fontSize: 18,
                                          gravity: ToastGravity.BOTTOM);
                                    }
                                  },
                                  icon: Icon(Icons.email)),
                            ])),
                      )));
        }
      },
    );
  }
}
