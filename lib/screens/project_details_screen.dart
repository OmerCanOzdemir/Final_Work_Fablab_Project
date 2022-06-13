import 'package:dio/dio.dart';
import 'package:fablab_project_final_work/navigation/dashboard.dart';
import 'package:fablab_project_final_work/screens/comments_project_screen.dart';
import 'package:fablab_project_final_work/screens/home_screen.dart';
import 'package:fablab_project_final_work/screens/profile_screen.dart';
import 'package:fablab_project_final_work/screens/update_project_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProjectDetails extends StatefulWidget {
  String projectId;
  ProjectDetails({this.projectId});

  @override
  State<ProjectDetails> createState() => _ProjectDetailsState(projectId);
}

class _ProjectDetailsState extends State<ProjectDetails> {
  String projectId;
  _ProjectDetailsState(this.projectId);
  var data;
  bool creator;
  bool creatorAndParticipate;
  bool unparticipate = false;
  User user = FirebaseAuth.instance.currentUser;
  String idUnparticipate;
  Future<void> inizializeData() async {
    print(projectId);
    Response response = await Dio()
        .get("https://finalworkapi.azurewebsites.net/api/Project/" + projectId);

    data = response.data["project"];
    if (data["user_Id"] == user.uid) {
      creator = true;
    } else
      creator = false;

    Response userResponse = await Dio().get(
        "https://finalworkapi.azurewebsites.net/api/User/byId/" + user.uid);

    userResponse.data["user"]["joined_Projects"].forEach((element) {
      if (projectId == element["project_Id"]) {
        unparticipate = true;
        idUnparticipate = element["id"];
      }
    });
    if (creator || !unparticipate) {
      creatorAndParticipate = true;
    } else
      creatorAndParticipate = false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: inizializeData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            Fluttertoast.showToast(
                msg: snapshot.error.toString(),
                fontSize: 18,
                gravity: ToastGravity.BOTTOM);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Project details"),
              ),
              body: Center(
                child: CircularProgressIndicator(
                  semanticsLabel: "Loading",
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(title: Text("Project details")),
              body: Container(
                padding: EdgeInsets.all(0),
                child: ListView(
                  children: [
                    Image(
                      fit: BoxFit.cover,
                      image: NetworkImage(data["image_Url"]),
                      height: 250,
                    ),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data["title"],
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                "Project type: " + data["category"]["name"],
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                "Beschrijving project",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                data["description"],
                                style: TextStyle(fontSize: 14),
                              ),
                              ButtonBar(
                                alignment: MainAxisAlignment.start,
                                children: [
                                  Visibility(
                                      visible: creatorAndParticipate,
                                      child: FlatButton(
                                        child: Text("Neem deel"),
                                        onPressed: () async {
                                          Response response = await Dio().post(
                                              "https://finalworkapi.azurewebsites.net/api/UserProject/participate/" +
                                                  user.uid +
                                                  "/" +
                                                  projectId);
                                          Fluttertoast.showToast(
                                              msg:
                                                  "U neemt deel aan het project",
                                              fontSize: 18,
                                              gravity: ToastGravity.BOTTOM);

                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProjectDetails(
                                                        projectId: projectId,
                                                      )));
                                        },
                                      )),
                                  Visibility(
                                      visible: unparticipate,
                                      child: FlatButton(
                                        child: Text("Deel uit project"),
                                        onPressed: () async {
                                          Response response = await Dio().post(
                                              "https://finalworkapi.azurewebsites.net/api/UserProject/unParticipate/" +
                                                  idUnparticipate);
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Uit nemen van het project",
                                              fontSize: 18,
                                              gravity: ToastGravity.BOTTOM);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProjectDetails(
                                                        projectId: projectId,
                                                      )));
                                        },
                                      )),
                                  FlatButton(
                                    child: Text("Meningen"),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CommentProjectScreen(
                                                    id: projectId,
                                                  )));
                                    },
                                  ),
                                  Visibility(
                                      visible: !creator,
                                      child: FlatButton(
                                        child: Text(
                                            "Bekijk profiel projectleider"),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Profile(
                                                        userId: data["user_Id"],
                                                      )));
                                        },
                                      )),
                                  Visibility(
                                      visible: creator,
                                      child: FlatButton(
                                        child: Text("Project aanpassen"),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      UpdateProject(
                                                        id: data["id"],
                                                      )));
                                        },
                                      ))
                                ],
                              )
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
         
        });
  }
}
