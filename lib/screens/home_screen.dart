import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:fablab_project_final_work/navigation/dashboard.dart';
import 'package:fablab_project_final_work/screens/add_project_screen.dart';
import 'package:fablab_project_final_work/screens/project_details_screen.dart';
import 'package:fablab_project_final_work/screens/update_project_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/auth.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User user = FirebaseAuth.instance.currentUser;
  var data;
  var allProjects;
  var value;
  List<dynamic> categories = [];
  List<KeyValueModel> dropdownItems = [];
  bool valueInit = true;
  Future<void> inizializeData(bool init) async {
    if (valueInit) {
      try {
        Response response = await Dio().get(
            "https://finalworkapi.azurewebsites.net/api/Project",
            options: Options(headers: {
              "authorisation": "00000000-0000-0000-0000-000000000000"
            }));
        allProjects = response.data["projects"];
        data = allProjects;
        Response responseCategory = await Dio().get(
            "https://finalworkapi.azurewebsites.net/api/Category",
            options: Options(headers: {
              "authorisation": "00000000-0000-0000-0000-000000000000"
            }));
        categories = responseCategory.data["categories"];
        categories.forEach((element) {
          KeyValueModel model =
              KeyValueModel(key: element["id"], value: element["name"]);
          dropdownItems.add(model);
        });
      } catch (e) {
        print(e);
      }
    } else {
      data = allProjects;
      data = data.where((p) => p["category_Id"] == value).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthService auth = AuthService();
    return Scaffold(
        appBar: AppBar(
            title: Text("Projecten"),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Dashboard()));
              },
            )),
        body: FutureBuilder(
          future: inizializeData(valueInit),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Container(
                child: Text(snapshot.error),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  semanticsLabel: "Loading",
                  backgroundColor: Colors.white,
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                children: [
                  getDropdownItems(),
                  SizedBox(
                    height: 14,
                  ),
                  Expanded(
                      child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return Visibility(
                                visible: data[index]["isPublic"],
                                child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            Ink.image(
                                              image: NetworkImage(
                                                  data[index]["image_Url"]),
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
                                          padding: EdgeInsets.all(16)
                                              .copyWith(bottom: 0),
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
                                                              projectId:
                                                                  data[index]
                                                                      ["id"],
                                                            )));
                                              },
                                            )
                                          ],
                                        )
                                      ],
                                    )));
                          }))
                ],
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => addProjectScreen()));
          },
          child: Icon(Icons.add),
        ));
  }

  Widget getDropdownItems() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.only(bottom: 15, left: 10, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(color: Colors.blue, width: 1.5),
      ),
      child: DropdownButton<String>(
        items: dropdownItems
            .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                ))
            .toList(),
        onChanged: (value) => setState(() {
          this.value = value;
          this.valueInit = false;
        }),
        hint: Text("Kies Type"),
        isExpanded: true,
        value: this.value,
      ),
    );
  }
}

class KeyValueModel {
  String key;
  String value;

  KeyValueModel({this.key, this.value});
}
