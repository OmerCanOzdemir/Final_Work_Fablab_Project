import 'package:dio/dio.dart';
import 'package:fablab_project_final_work/screens/project_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyInvitationScreen extends StatefulWidget {
  String userId;
  MyInvitationScreen({this.userId});

  @override
  _MyInvitationScreen createState() => _MyInvitationScreen(userId);
}

class _MyInvitationScreen extends State<MyInvitationScreen> {
  String userId;
  var data;
  _MyInvitationScreen(this.userId);
  Future<void> inizializeData() async {
    try {
      Response response = await Dio().get(
          "https://finalworkapi.azurewebsites.net/api/User/byId/" + userId,
          options: Options(headers: {
            "authorisation": "00000000-0000-0000-0000-000000000000"
          }));

      data = response.data["user"]["invitations"];
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: inizializeData(),
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return Container(
              child: Text(snapshot.error),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: Text("Mijn uitnodigingen")),
              body: Center(
                child: CircularProgressIndicator(
                  semanticsLabel: "Loading",
                  backgroundColor: Colors.white,
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            if (data.length == 0) {
              return Scaffold(
                appBar: AppBar(title: Text("Mijn uitnodiginen")),
                body: Center(child: Text("Geen uitnodigingen")),
              );
            } else
              return Scaffold(
                appBar: AppBar(title: Text("Mijn uitnodigingen")),
                body: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) => Card(
                          child: ListTile(
                              title:
                                  Text(data[index]["titleProject"].toString()),
                              subtitle: Text("Gestuurd door: " +
                                  data[index]["from"].toString()),
                              trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        onPressed: () async {
                                          User user =
                                              FirebaseAuth.instance.currentUser;
                                          Response response = await Dio().post(
                                              "https://finalworkapi.azurewebsites.net/api/UserProject/participate/" +
                                                  user.uid +
                                                  "/" +
                                                  data[index]["projectId"],
                                              options: Options(headers: {
                                                "authorisation":
                                                    "00000000-0000-0000-0000-000000000000"
                                              }));
                                          await Dio().post(
                                              "https://finalworkapi.azurewebsites.net/api/User/acceptInvitation/" +
                                                  data[index]["id"],
                                              options: Options(headers: {
                                                "authorisation":
                                                    "00000000-0000-0000-0000-000000000000"
                                              }));
                                          if (response
                                              .data["statusCode" == 200]) {
                                            Fluttertoast.showToast(
                                                msg: "Uitnodiging geaccepteerd",
                                                fontSize: 18,
                                                gravity: ToastGravity.BOTTOM);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProjectDetails(
                                                          projectId: data[index]
                                                              ["projectId"],
                                                        )));
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: response
                                                    .data["errorMessage"]
                                                    .toString(),
                                                fontSize: 18,
                                                gravity: ToastGravity.BOTTOM);
                                          }
                                        },
                                        icon: Icon(Icons.done)),
                                    IconButton(
                                        onPressed: () async {
                                          setState(() {});
                                          Response response = await Dio().post(
                                              "https://finalworkapi.azurewebsites.net/api/User/acceptInvitation/" +
                                                  data[index]["id"],
                                              options: Options(headers: {
                                                "authorisation":
                                                    "00000000-0000-0000-0000-000000000000"
                                              }));
                                          if (response
                                              .data["statusCode" == 200]) {
                                            Fluttertoast.showToast(
                                                msg: "Uitnodiging geweigerd",
                                                fontSize: 18,
                                                gravity: ToastGravity.BOTTOM);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: response
                                                    .data["errorMessage"]
                                                    .toString(),
                                                fontSize: 18,
                                                gravity: ToastGravity.BOTTOM);
                                          }
                                        },
                                        icon: Icon(Icons.close)),
                                  ])),
                        )),
              );
          }
        }));
  }
}
