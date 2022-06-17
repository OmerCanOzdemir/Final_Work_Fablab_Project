import 'package:dio/dio.dart';
import 'package:fablab_project_final_work/navigation/dashboard.dart';
import 'package:fablab_project_final_work/screens/add_task_screen.dart';
import 'package:fablab_project_final_work/screens/handle_taks_screen.dart';
import 'package:fablab_project_final_work/screens/my_projects_screen.dart';
import 'package:fablab_project_final_work/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TaskProject extends StatefulWidget {
  String projectId;
  bool creator;
  TaskProject({this.projectId, this.creator});

  @override
  TaskProjectState createState() => TaskProjectState(projectId, creator);
}

class TaskProjectState extends State<TaskProject> {
  User user = FirebaseAuth.instance.currentUser;
  String projectId;
  bool creator;
  TaskProjectState(this.projectId, this.creator);
  var data;

  Future<void> inizializeData() async {
    try {
      Response response = await Dio().get(
          "https://finalworkapi.azurewebsites.net/api/Project/" + projectId,
          options: Options(headers: {
            "authorisation": "00000000-0000-0000-0000-000000000000"
          }));

      data = response.data["project"]["tasks"];
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Taken project"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyProjects()));
            },
          )),
      body: FutureBuilder(
          future: inizializeData(),
          builder: ((context, snapshot) {
            if (snapshot.hasError) {
              return Container(
                child: Text(snapshot.error),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: "Loading",
                    backgroundColor: Colors.white,
                  ),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) => Card(
                        child: ListTile(
                            title: Text(data[index]["title"]),
                            subtitle: data[index]["user"] == null
                                ? Text("Status: " + data[index]["status"])
                                : Text("Status: " +
                                    data[index]["status"] +
                                    "\nGeassigneerd aan:" +
                                    data[index]["user"]["email"]),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Visibility(
                                  visible: data[index]["user"] != null,
                                  child: IconButton(
                                      onPressed: (() {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Profile(
                                                      userId: data[index]
                                                          ["user"]["id"],
                                                    )));
                                      }),
                                      icon: Icon(
                                        Icons.person,
                                      ))),
                              Visibility(
                                  visible: data[index]["user"] == null,
                                  child: ElevatedButton(
                                    child: Text("Assign to me"),
                                    onPressed: () async {
                                      Response response = await Dio().put(
                                          "https://finalworkapi.azurewebsites.net/api/Tasks/assign/" +
                                              data[index]["id"] +
                                              "/" +
                                              user.uid,
                                          options: Options(headers: {
                                            "authorisation":
                                                "00000000-0000-0000-0000-000000000000"
                                          }));
                                      if (response
                                              .data["statusCode"] == 200) {
                                        setState(() {});
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: response.data["errorMessage"]
                                                .toString(),
                                            fontSize: 18,
                                            gravity: ToastGravity.BOTTOM);
                                      }
                                    },
                                  )),
                              Visibility(
                                  visible: creator ||
                                      data[index]["user"]["id"] == user.uid,
                                  child: ElevatedButton(
                                    child: Text("Beheer taak"),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HandleTaskScreen(
                                                    taskId: data[index]["id"],
                                                  )));
                                    },
                                  )),
                            ])),
                      ));
            }
          })),
      floatingActionButton: Visibility(
        visible: creator,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddTaskToProject(
                          id: projectId,
                        )));
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
