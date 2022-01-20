import 'package:fablab_project_final_work/main.dart';
import 'package:fablab_project_final_work/screens/home_screen.dart';
import 'package:fablab_project_final_work/wrapper/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fablab_project_final_work/decoration/input_decoration.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fablab_project_final_work/services/database.dart';

class addProjectScreen extends StatefulWidget {
  const addProjectScreen({Key key}) : super(key: key);

  @override
  _addProjectScreenState createState() => _addProjectScreenState();
}

class _addProjectScreenState extends State<addProjectScreen> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
    //Database service
  final DatabaseServices _databaseServices = DatabaseServices();
  User user = FirebaseAuth.instance.currentUser;
  //input controllers
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController littleDescriptionController = TextEditingController();
  TextEditingController maxPersonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Voeg Project"),
        centerTitle: true,
      ),
      body: Center(
       child: SingleChildScrollView(
         child:   Form(
          key: _formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
              ),getTitleInput(),
              SizedBox(
                height: 15,
              ),getLittleDescriptionInput(),
              SizedBox(
                height: 15,
              ),
              getDescriptionInput(),
              SizedBox(
                height: 15,
              ),
              getMaxPersonInput(),
              SizedBox(
                height: 15,
              ),
              Container(
                child: ElevatedButton(
                  onPressed: ()async{
                      if (_formkey.currentState.validate()){
                            await _databaseServices.createProject(user.uid,titleController.text,littleDescriptionController.text,descriptionController.text,maxPersonController.text);
                            Fluttertoast.showToast(
                                      msg: "Project aangemaakt",
                                      fontSize: 18,
                                      gravity: ToastGravity.BOTTOM);
                            Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Main()));
                      
                      }else{
                        Fluttertoast.showToast(
                                      msg: "Probeer opnieuw",
                                      fontSize: 18,
                                      gravity: ToastGravity.BOTTOM);
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

  Widget getMaxPersonInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: TextFormField(
        keyboardType: TextInputType.number,
        decoration: inputDecoration(Icons.person, "Aantal personen"),
        controller: maxPersonController,
        validator: (value) {
          if (value.toString().isEmpty) {
            return "Aantal personen mag niet leeg zijn";
          } else if (value.toString() == "0") {
            return "Aantal personen mag niet 0 zijn";
          } else
            return null;
        },
      ),
    );
  }
}
