import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fablab_project_final_work/main.dart';
import 'package:fablab_project_final_work/screens/home_screen.dart';
import 'package:fablab_project_final_work/wrapper/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fablab_project_final_work/decoration/input_decoration.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class addProjectScreen extends StatefulWidget {
  const addProjectScreen({Key key}) : super(key: key);

  @override
  _addProjectScreenState createState() => _addProjectScreenState();
}

class _addProjectScreenState extends State<addProjectScreen> {
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
        Response response = await Dio()
            .get("https://finalworkapi.azurewebsites.net/api/Category");
        categories = response.data["categories"];
        categories.forEach((element) {
          KeyValueModel model =
              KeyValueModel(key: element["id"], value: element["name"]);
          dropdownItems.add(model);
        });
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Voeg Project"),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: inizializeData(valueInit),
          builder: ((context, snapshot) {
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
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
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
                            height: 15,
                          ),
                          getDropdownItemsForPublicOrNot(),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                pickImage();
                              },
                              child: Text("Afbeelding"),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (file == null) {
                                  Fluttertoast.showToast(
                                      msg: "Kies een afbeelding",
                                      fontSize: 18,
                                      gravity: ToastGravity.BOTTOM);
                                } else if (value == null) {
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
                                  try {
                                    var snapshot = await firebaseStorage
                                        .ref()
                                        .child('imageProject/' +
                                            titleController.text)
                                        .putFile(file);

                                    var url =
                                        await snapshot.ref.getDownloadURL();

                                    print(url);

                                    if (valuePrivateOrNot == "true") {
                                      valuePrivateOrNot = true;
                                    } else
                                      valuePrivateOrNot = false;
                                    print("hallo");
                                    User user =
                                        FirebaseAuth.instance.currentUser;
                                    print(user);
                                    var projectData = {
                                      "user_Id": user.uid,
                                      "title": titleController.text.toString(),
                                      "description":
                                          descriptionController.text.toString(),
                                      "coverDescription":
                                          littleDescriptionController.text
                                              .toString(),
                                      "category_Id": value,
                                      "image_Url": url,
                                      "isPublic": valuePrivateOrNot
                                    };
                                    Response response = await Dio().post(
                                      "https://finalworkapi.azurewebsites.net/api/Project",
                                      options: Options(headers: {
                                        HttpHeaders.contentTypeHeader:
                                            "application/json",
                                      }),
                                      data: jsonEncode(projectData),
                                    );
                                    print(response);
                                    Fluttertoast.showToast(
                                        msg: "Project aangemaakt",
                                        fontSize: 18,
                                        gravity: ToastGravity.BOTTOM);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Home()));
                                  } catch (e) {
                                    Fluttertoast.showToast(
                                        msg: e.toString(),
                                        fontSize: 18,
                                        gravity: ToastGravity.BOTTOM);
                                  }
                                }
                              },
                              child: Text("Voeg project"),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          })),
    );
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
            return "Kleine beschrijving mag niet leeg zijn";
          } else
            return null;
        },
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

  Future pickImage() async {
    try {
      final image = await ImagePicker().getImage(source: ImageSource.gallery);

      if (image == null) return;
      final imageTemporary = File(image.path);
      setState(() {
        this.file = imageTemporary;
      });
    } on PlatformException catch (e) {
      print("Failed to image pick: " + e.toString());
    }
  }
}

class KeyValueModel {
  String key;
  String value;

  KeyValueModel({this.key, this.value});
}
