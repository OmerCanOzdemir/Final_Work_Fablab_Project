import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fablab_project_final_work/decoration/input_decoration.dart';
import 'package:fablab_project_final_work/screens/my_projects_screen.dart';
import 'package:fablab_project_final_work/screens/task_project_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HandleTaskScreen extends StatefulWidget {
  String taskId;
  HandleTaskScreen({this.taskId});

  @override
  State<HandleTaskScreen> createState() => _HandleTaskScreenState(taskId);
}

class _HandleTaskScreenState extends State<HandleTaskScreen> {
  String taskId;
  _HandleTaskScreenState(this.taskId);
  var data;
  var value;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  var init = true;
  bool _isloading = false;
  Future<void> inizializeData(bool init) async {
    if (init) {
      try {
        Response response = await Dio().get(
            "https://finalworkapi.azurewebsites.net/api/Tasks/" + taskId,
            options: Options(headers: {
              "authorisation": "00000000-0000-0000-0000-000000000000"
            }));
        data = response.data["task"];
        titleController.text = data["title"];
        descriptionController.text = data["description"];
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Beheer taak")),
      body: FutureBuilder(
          future: inizializeData(init),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
                 return Container(
            child: Text(snapshot.error),
          );
            }
            if (snapshot.connectionState == ConnectionState.done ||
                _isloading) {
              return Padding(
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
                                    getDropdownItems(),
                                    SizedBox(
                                      height: 14,
                                    ),
                                    Container(
                                      child: Center(
                                          child: Column(
                                        children: [
                                          ElevatedButton(
                                              onPressed: () async {
                                                if (value == null) {
                                                  Fluttertoast.showToast(
                                                      msg: "Kies Status",
                                                      fontSize: 18,
                                                      gravity:
                                                          ToastGravity.BOTTOM);
                                                } else if (_formkey.currentState
                                                    .validate()) {
                                                  setState(() {
                                                    _isloading = true;
                                                    init = false;
                                                  });
                                                  var data = {
                                                    "title":
                                                        titleController.text,
                                                    "description":
                                                        descriptionController
                                                            .text,
                                                    "status": value
                                                  };
                                                  Response response =
                                                      await Dio().put(
                                                    "https://finalworkapi.azurewebsites.net/api/Tasks/" +
                                                        taskId,
                                                    options: Options(headers: {
                                                      HttpHeaders
                                                              .contentTypeHeader:
                                                          "application/json",
                                                      "authorisation":
                                                          "00000000-0000-0000-0000-000000000000"
                                                    }),
                                                    data: jsonEncode(data),
                                                  );
                                                  if (response
                                              .data["statusCode"] == 200) {
                                                    Fluttertoast.showToast(
                                                        msg: "Taak gewijzigd",
                                                        fontSize: 18,
                                                        gravity: ToastGravity
                                                            .BOTTOM);
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                MyProjects()));
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg: response.data[
                                                                "errorMessage"]
                                                            .toString(),
                                                        fontSize: 18,
                                                        gravity: ToastGravity
                                                            .BOTTOM);
                                                  }
                                                }
                                              },
                                              child: Text("Wijzig taak")),
                                          SizedBox(
                                            height: 14,
                                          ),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary: Colors.red),
                                              onPressed: () async {
                                                Response response = await Dio().put(
                                                    "https://finalworkapi.azurewebsites.net/api/Tasks/unAssign/" +
                                                        taskId,
                                                    options: Options(headers: {
                                                      "authorisation":
                                                          "00000000-0000-0000-0000-000000000000"
                                                    }));
                                                if (response.data[
                                                    "statusCode" == 200]) {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "Doet niet meer deze taak",
                                                      fontSize: 18,
                                                      gravity:
                                                          ToastGravity.BOTTOM);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              MyProjects()));
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg: response
                                                          .data["errorMessage"]
                                                          .toString(),
                                                      fontSize: 18,
                                                      gravity:
                                                          ToastGravity.BOTTOM);
                                                }
                                              },
                                              child: Text("Unassigneer taak"))
                                        ],
                                      )),
                                    )
                                  ])))));
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
          }),
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

  Widget getDropdownItems() {
    var items = [
      KeyValueModel(key: "OPEN", value: "OPEN"),
      KeyValueModel(key: "DOING", value: "DOING"),
      KeyValueModel(key: "RESOLVED", value: "RESOLVED"),
      KeyValueModel(key: "DONE", value: "DONE"),
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
          this.init = false;
          this.value = value;
        }),
        hint: Text("Status taak"),
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
