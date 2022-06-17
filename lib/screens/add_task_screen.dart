import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fablab_project_final_work/decoration/input_decoration.dart';
import 'package:fablab_project_final_work/screens/project_details_screen.dart';
import 'package:fablab_project_final_work/screens/task_project_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddTaskToProject extends StatefulWidget {
  String id;
  AddTaskToProject({this.id});

  @override
  State<AddTaskToProject> createState() => _AddTaskToProjectState(id);
}

class _AddTaskToProjectState extends State<AddTaskToProject> {
  String id;
  _AddTaskToProjectState(this.id);
  //input controllers
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool _isloading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Voeg taak")),
      body: _isloading
          ? Center(
              child: CircularProgressIndicator(
                semanticsLabel: "Loading",
                backgroundColor: Colors.white,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: SingleChildScrollView(
                      child: Form(
                          key: _formkey,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                getTitleInput(),
                                SizedBox(
                                  height: 14,
                                ),
                                getDescriptionInput(),
                                Container(
                                    child: ElevatedButton(
                                  child: Text("Voeg taak"),
                                  onPressed: () async {
                                    if (_formkey.currentState.validate()) {
                                      setState(() {
                                        _isloading = true;
                                      });
                                      var taskData = {
                                        "title": titleController.text,
                                        "description":
                                            descriptionController.text,
                                        "projectId": id
                                      };
                                      Response response = await Dio().post(
                                        "https://finalworkapi.azurewebsites.net/api/Tasks/" +
                                            id,
                                        options: Options(headers: {
                                          HttpHeaders.contentTypeHeader:
                                              "application/json",
                                          "authorisation":
                                              "00000000-0000-0000-0000-000000000000"
                                        }),
                                        data: jsonEncode(taskData),
                                      );
                                      if (response
                                              .data["statusCode"] == 200) {
                                        Fluttertoast.showToast(
                                            msg: "Taak aangemaakt",
                                            fontSize: 18,
                                            gravity: ToastGravity.BOTTOM);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    TaskProject(
                                                      projectId: id,
                                                      creator: true,
                                                    )));
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: response.data["errorMessage"]
                                                .toString(),
                                            fontSize: 18,
                                            gravity: ToastGravity.BOTTOM);
                                      }
                                    }
                                  },
                                ))
                              ]))))),
    );
  }

  Widget getTitleInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: TextFormField(
        keyboardType: TextInputType.text,
        decoration: inputDecoration(Icons.title, "Titel taak"),
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
}
