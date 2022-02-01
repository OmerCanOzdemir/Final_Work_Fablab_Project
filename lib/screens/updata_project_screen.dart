import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fablab_project_final_work/services/database.dart';
import '../decoration/input_decoration.dart';
import '../main.dart';

class UpdataProject extends StatefulWidget {
  String id;
  UpdataProject({this.id});

  @override
  _UpdataProjectState createState() => _UpdataProjectState(id);
}

class _UpdataProjectState extends State<UpdataProject> {
  String id;
  var project;
  _UpdataProjectState(this.id);

  //Database service
  final DatabaseServices _databaseServices = DatabaseServices();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  //input controllers
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController littleDescriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getProjectInfo(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Project aanpassen"),
              centerTitle: true,
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
                      Container(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formkey.currentState.validate()) {
                              await _databaseServices.updataProject(
                                  id,
                                  titleController.text,
                                  descriptionController.text,
                                  littleDescriptionController.text);
                              Fluttertoast.showToast(
                                  msg: "Project aangepast",
                                  fontSize: 18,
                                  gravity: ToastGravity.BOTTOM);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Main()));
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
        return Container();
      },
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
        decoration: inputDecoration(Icons.description, "Kleine beschrijving"),
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

  Future<void> getProjectInfo() async {
    project =
        await FirebaseFirestore.instance.collection("project").doc(id).get();
    titleController.text = project["title"];
    descriptionController.text = project["description"];
    littleDescriptionController.text = project["littleDescription"];
  }
}
