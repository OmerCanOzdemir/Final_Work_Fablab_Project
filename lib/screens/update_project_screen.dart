import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:fablab_project_final_work/screens/project_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../decoration/input_decoration.dart';
import '../main.dart';

class UpdateProject extends StatefulWidget {
  String id;
  UpdateProject({this.id});

  @override
  _UpdateProjectState createState() => _UpdateProjectState(id);
}

class _UpdateProjectState extends State<UpdateProject> {
  String id;
  var project;
  _UpdateProjectState(this.id);

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  //Database service
  User user = FirebaseAuth.instance.currentUser;
  //Firebase storage
  final firebaseStorage = FirebaseStorage.instance;
  //input controllers
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController littleDescriptionController = TextEditingController();
  TextEditingController maxPersonController = TextEditingController();
  bool valueInit = true;
  var value;
  var valuePrivateOrNot;
  File file;
  List<dynamic> categories = [];
  List<KeyValueModel> dropdownItems = [];
  var data;
  Future<void> inizializeData(bool value) async {
    if (value) {
      dropdownItems = [];
      try {
        Response projectResponse = await Dio().get(
            "https://finalworkapi.azurewebsites.net/api/Project/" + id,
            options: Options(headers: {
              "authorisation": "00000000-0000-0000-0000-000000000000"
            }));

        data = projectResponse.data["project"];
        Response categoriesResponse = await Dio().get(
            "https://finalworkapi.azurewebsites.net/api/Category",
            options: Options(headers: {
              "authorisation": "00000000-0000-0000-0000-000000000000"
            }));
        categories = categoriesResponse.data["categories"];
        categories.forEach((element) {
          KeyValueModel model =
              KeyValueModel(key: element["id"], value: element["name"]);
          dropdownItems.add(model);
        });

        titleController.text = data["title"];
        descriptionController.text = data["description"];
        littleDescriptionController.text = data["coverDescription"];
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: inizializeData(valueInit),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container(
              child: Text(snapshot.error),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: Text("Project Aanpassen")),
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
                title: Text("Project Aanpassen"),
              ),
              body: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(),
                        getTitleInput(),
                        SizedBox(
                          height: 15,
                        ),
                        getLittleDescriptionInput(),
                        SizedBox(
                          height: 15,
                        ),
                        getDescriptionInput(),
                        SizedBox(
                          height: 15,
                        ),
                        getDropdownItems(),
                        SizedBox(
                          height: 14,
                        ),
                        getDropdownItemsForPublicOrNot(),
                        Container(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (value == null) {
                                Fluttertoast.showToast(
                                    msg: "Kies een Categorie",
                                    fontSize: 18,
                                    gravity: ToastGravity.BOTTOM);
                              } else if (valuePrivateOrNot == null) {
                                Fluttertoast.showToast(
                                    msg: "Private of niet?",
                                    fontSize: 18,
                                    gravity: ToastGravity.BOTTOM);
                              } else if (_formkey.currentState.validate()) {
                                if (valuePrivateOrNot == "true") {
                                  valuePrivateOrNot = true;
                                } else
                                  valuePrivateOrNot = false;

                                try {
                                  var projectData = {
                                    "title": titleController.text.toString(),
                                    "description":
                                        descriptionController.text.toString(),
                                    "coverDescription":
                                        littleDescriptionController.text
                                            .toString(),
                                    "category_Id": value,
                                    "isPublic": valuePrivateOrNot
                                  };
                                  Response response = await Dio().put(
                                    "https://finalworkapi.azurewebsites.net/api/Project/" +
                                        id,
                                    options: Options(headers: {
                                      HttpHeaders.contentTypeHeader:
                                          "application/json",
                                      "authorisation":
                                          "00000000-0000-0000-0000-000000000000"
                                    }),
                                    data: jsonEncode(projectData),
                                  );
                                  if (response
                                              .data["statusCode"] == 200) {
                                    Fluttertoast.showToast(
                                        msg: "Project aangepast",
                                        fontSize: 18,
                                        gravity: ToastGravity.BOTTOM);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProjectDetails(
                                                  projectId: data["id"],
                                                )));
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: response.data["errorMessage"]
                                            .toString(),
                                        fontSize: 18,
                                        gravity: ToastGravity.BOTTOM);
                                  }
                                } catch (e) {
                                  Fluttertoast.showToast(
                                      msg: e.toString(),
                                      fontSize: 18,
                                      gravity: ToastGravity.BOTTOM);
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Probeer opnieuw",
                                    fontSize: 18,
                                    gravity: ToastGravity.BOTTOM);
                              }
                            },
                            child: Text("Pas project aan"),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }

  Widget getTitleInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: TextFormField(
        keyboardType: TextInputType.text,
        decoration: inputDecoration(Icons.title, "Titel project"),
        controller: titleController,
        validator: (value) {
          if (value.toString().isEmpty) {
            return "Titel mag niet leeg zijn";
          } else
            return null;
        },
      ),
    );
  }

  Widget getDescriptionInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: TextFormField(
        keyboardType: TextInputType.text,
        decoration: inputDecoration(Icons.description, "Beschrijving"),
        controller: descriptionController,
        validator: (value) {
          if (value.toString().isEmpty) {
            return "Beschrijving mag niet leeg zijn";
          } else
            return null;
        },
      ),
    );
  }

  Widget getLittleDescriptionInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: TextFormField(
        keyboardType: TextInputType.text,
        decoration: inputDecoration(Icons.description, "Cover beschrijving"),
        controller: littleDescriptionController,
        validator: (value) {
          if (value.toString().isEmpty) {
            return "Cover beschrijving mag niet leeg zijn";
          } else
            return null;
        },
      ),
    );
  }

  Widget getDropdownItemsForPublicOrNot() {
    var items = [
      KeyValueModel(key: "true", value: "Publiek"),
      KeyValueModel(key: "false", value: "Private")
    ];
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.only(bottom: 15, left: 10, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(color: Colors.blue, width: 1.5),
      ),
      child: DropdownButton<String>(
        items: items
            .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                ))
            .toList(),
        onChanged: (value) => setState(() {
          this.valuePrivateOrNot = value;
          this.valueInit = false;
        }),
        hint: Text("Publiek of niet"),
        isExpanded: true,
        value: this.valuePrivateOrNot,
      ),
    );
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
