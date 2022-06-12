import 'package:dio/dio.dart';
import 'package:fablab_project_final_work/screens/add_comment_screen.dart';
import 'package:fablab_project_final_work/screens/add_project_screen.dart';
import 'package:fablab_project_final_work/screens/profile_screen.dart';
import 'package:fablab_project_final_work/screens/project_details_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:matcher/matcher.dart';

class CommentProjectScreen extends StatefulWidget {
  String id;
  CommentProjectScreen({this.id});

  @override
  State<CommentProjectScreen> createState() => _CommentProjectScreenState(id);
}

class _CommentProjectScreenState extends State<CommentProjectScreen> {
  String id;
  _CommentProjectScreenState(this.id);
  var data;
  @override
  Widget build(BuildContext context) {
    Future<void> inizializeData() async {
      Response response = await Dio()
          .get("https://finalworkapi.azurewebsites.net/api/Project/" + id);

      data = response.data["project"]["comments"];
      
    }

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
            appBar: AppBar(
                title: Text("Mijn uitnodigingen"),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProjectDetails(
                                  projectId: id,
                                )));
                  },
                )),
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
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddCommentScreen(
                                id: id,
                              )));
                },child: Icon(Icons.add)),
              appBar: AppBar(title: Text("Meningen"),leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProjectDetails(
                                  projectId: id,
                                )));
                  },
                )),
              body: Center(child: Text("Geen meningen")),
            );
          } else
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddCommentScreen(
                                id: id,
                              )));
                },
                child: Icon(Icons.add),
              ),
              appBar: AppBar(title: Text("Meningen")),
              body: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) => Card(
                        child: ListTile(
                            title: Text(data[index]["message"]),
                            subtitle:
                                Text("Gestuurd door: "+ data[index]["user"]["email"]),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                  onPressed: () {

                                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Profile(
                                userId: data[index]["user"]["id"],
                              )));
                                  },
                                  icon: Icon(Icons.person)),
                            ])),
                      )),
            );
        }
      }),
    );
  }
}
