import 'package:dio/dio.dart';
import 'package:fablab_project_final_work/navigation/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

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
    print(projectId);
    Response response = await Dio()
        .get("https://finalworkapi.azurewebsites.net/api/Project/" + projectId);

    print(response.data["project"]["tasks"]);
    data = response.data["project"]["tasks"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Taken project"),
      ),
      body: FutureBuilder(
          future: inizializeData(),
          builder: ((context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
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
                            subtitle:
                                Text("Geassigneerd aan:" +"\nStatus: "+ data[index]["status"]),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Visibility(
                                  visible: false, child: Icon(Icons.person)),
                              Visibility(
                                  visible: false,
                                  child: ElevatedButton(
                                    child: Text("Assign to me"),
                                    onPressed: () {
                                      print("object");
                                    },
                                  )),
                              Visibility(
                                  visible: true,
                                  child: ElevatedButton(
                                    child: Text("Change status"),
                                    onPressed: () {
                                      print("status changed");
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
                context, MaterialPageRoute(builder: (context) => Dashboard()));
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
