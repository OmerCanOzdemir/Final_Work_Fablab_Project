import 'dart:io';

import 'package:fablab_project_final_work/navigation/bottom_navigation.dart';
import 'package:fablab_project_final_work/services/auth.dart';
import 'package:fablab_project_final_work/services/database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fablab_project_final_work/decoration/input_decoration.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import 'login.dart';

class Register extends StatefulWidget {
  const Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  //Firebase storage
  final firebaseStorage = FirebaseStorage.instance;
  //Auth service
  final AuthService _auth = AuthService();
  //Dropdown items
  final items = [
    "Toegepaste Informatica",
    "Graduaat Programmeren",
    "Graduaat Internet of Things",
    "Graduaat Systeem- & Netwerkbeheer"
  ];
  String value = "Toegepaste Informatica";
  File file;
  //form key
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  //input controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: SingleChildScrollView(
                child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 70,
                          child: Image.asset("assets/discord.png"),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        getEmailInput(),
                        SizedBox(
                          height: 15,
                        ),
                        getPasswordInput(),
                        SizedBox(
                          height: 15,
                        ),
                        getConfirmPasswordInput(),
                        SizedBox(
                          height: 15,
                        ),
                        getFirstnameInput(),
                        SizedBox(
                          height: 15,
                        ),
                        getLastnameInput(),
                        SizedBox(
                          height: 15,
                        ),
                        getDropdownItems(),
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
                        ), SizedBox(
                          height: 15,
                        ),
                        Container(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (file == null) {
                                Fluttertoast.showToast(
                                    msg: "Kies een profiel photo",
                                    fontSize: 18,
                                    gravity: ToastGravity.BOTTOM);
                              } else if (_formkey.currentState.validate()) {
                                var snapshot = await firebaseStorage
                                    .ref()
                                    .child('imageuser/'+emailController.text)
                                    .putFile(file);

                                var url = await snapshot.ref.getDownloadURL();

                                dynamic result =
                                    await _auth.registerWithEmailAndPassword(
                                        emailController.text,
                                        passwordController.text,
                                        firstnameController.text,
                                        lastnameController.text,
                                        value,
                                        url);
                                if (result == "Account aangemaakt") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Login()));
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Some problems",
                                      fontSize: 18,
                                      gravity: ToastGravity.BOTTOM);
                                }
                              }
                            },
                            child: Text('Registreer'),
                          ),
                        )
                      ],
                    )))));
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

  Widget getEmailInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: inputDecoration(Icons.email, "Email adres"),
        controller: emailController,
        validator: (value) {
          if (value.toString().isEmpty) {
            return "Email mag niet leeg zijn";
          } else
            return null;
        },
      ),
    );
  }

  Widget getFirstnameInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: TextFormField(
        keyboardType: TextInputType.text,
        decoration: inputDecoration(Icons.person, "Voornaam"),
        controller: firstnameController,
        validator: (value) {
          if (value.toString().isEmpty) {
            return "Voornaam mag niet leeg zijn";
          } else
            return null;
        },
      ),
    );
  }

  Widget getLastnameInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: TextFormField(
        keyboardType: TextInputType.text,
        decoration: inputDecoration(Icons.person, "Naam"),
        controller: lastnameController,
        validator: (value) {
          if (value.toString().isEmpty) {
            return "Naam mag niet leeg zijn";
          } else
            return null;
        },
      ),
    );
  }

  Widget getPasswordInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: TextFormField(
        obscureText: true,
        keyboardType: TextInputType.text,
        decoration: inputDecoration(Icons.password, "Wachtwoord"),
        controller: passwordController,
        validator: (value) {
          if (value.toString().isEmpty) {
            return "Wachtwoord mag niet leeg zijn";
          } else if (value.toString().length < 6) {
            return "Wachtwoord moet langer zijn dan 6 karakters";
          } else
            return null;
        },
      ),
    );
  }

  Widget getConfirmPasswordInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: TextFormField(
        obscureText: true,
        keyboardType: TextInputType.text,
        decoration: inputDecoration(Icons.password, "Bevistig wachtwoord"),
        controller: confirmPasswordController,
        validator: (value) {
          if (value.toString().isEmpty) {
            return "Bevestig wachtwoord mag niet leeg zijn";
          } else if (value.toString() != passwordController.text) {
            return "Wachtwoorden zijn niet gelijk";
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
        items: items.map(buildMenuItem).toList(),
        onChanged: (value) => setState(() => this.value = value),
        value: this.value,
        isExpanded: true,
      ),
    );
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ));
}
