import 'package:dio/dio.dart';
import 'package:fablab_project_final_work/navigation/dashboard.dart';
import 'package:fablab_project_final_work/screens/handle_taks_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({Key key}) : super(key: key);

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  User user = FirebaseAuth.instance.currentUser;
  var data;
  Future<void> inizializeData() async {
    try {
      Response response = await Dio().get(
          "https://finalworkapi.azurewebsites.net/api/User/byId/" + user.uid,
            options: Options(headers: {
              "authorisation": "00000000-0000-0000-0000-000000000000"
            }));

      data = response.data["user"]["tasks"];
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mijn taken") ,leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Dashboard(
                                
                                )));
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
                            subtitle: Text(data[index]["project"]["title"] + "\nStatus taak: "+data[index]["status"]),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              ElevatedButton(
                                child: Text("Beheer taak"),
                                onPressed: () {
                                   Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => HandleTaskScreen(
                                                      taskId: data[index]["id"],
                                                    )));
                                },
                              ),
                            ])),
                      ));
            }
          })),
    );
  }
}
