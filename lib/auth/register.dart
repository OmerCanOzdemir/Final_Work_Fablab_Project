import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fablab_project_final_work/services/auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fablab_project_final_work/decoration/input_decoration.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'login.dart';

class Register extends StatefulWidget {
  const Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // this variable holds the selected items
  List<String> selectedItemsInterests = [];

  List<dynamic> educations = [];
  List<KeyValueModel> dropdownItems = [];

  List<dynamic> interests = [];
  List<KeyValueModel> checkBoxDropDownItems = [];
  bool valueInit = true;
  bool _isloading = false;
  Future<void> inizializeData(bool value) async {
    if (value) {
      dropdownItems = [];
      checkBoxDropDownItems = [];

      try {
        Response educationResponse = await Dio().get(
            "https://finalworkapi.azurewebsites.net/api/Education",
            options: Options(headers: {
              "authorisation": "00000000-0000-0000-0000-000000000000"
            }));
        Response interestsResponse = await Dio().get(
            "https://finalworkapi.azurewebsites.net/api/Category",
            options: Options(headers: {
              "authorisation": "00000000-0000-0000-0000-000000000000"
            }));

        educations = educationResponse.data["educations"];
        educations.forEach((element) {
          KeyValueModel model =
              KeyValueModel(key: element["id"], value: element["name"]);
          dropdownItems.add(model);
        });
        interests = interestsResponse.data["categories"];
        interests.forEach((element) {
          print(element["name"]);
          KeyValueModel model =
              KeyValueModel(key: element["id"], value: element["name"]);
          checkBoxDropDownItems.add(model);
        });
      } catch (e) {
        print(e);
      }
    }
  }

  // This function is triggered when a checkbox is checked or unchecked
  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedItemsInterests.add(itemValue);
      } else {
        selectedItemsInterests.remove(itemValue);
      }
    });
  }

  // this function is called when the Cancel button is pressed
  void _cancel() {
    Navigator.pop(context);
  }

// this function is called when the Submit button is tapped
  void _submit() {
    Navigator.pop(context, selectedItemsInterests);
  }

  //Firebase storage
  final firebaseStorage = FirebaseStorage.instance;
  //Auth service
  final AuthService _auth = AuthService();

  File file;
  //form key
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  var value;
  //input controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: inizializeData(this.valueInit),
      builder: (context, snapshot) {
        //Check for errors
        if (snapshot.hasError) {
          return Text(snapshot.error);
        }
        if (snapshot.connectionState == ConnectionState.waiting || _isloading) {
          return Scaffold(
            appBar: AppBar(title: Text("Registreer")),
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
              appBar: AppBar(title: Text("Registreer")),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: SingleChildScrollView(
                        child: Form(
                            key: _formkey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
                                getAboutMeInput(),
                                SizedBox(
                                  height: 15,
                                ),
                                getDropdownItems(),
                                SizedBox(
                                  height: 15,
                                ),
                                getDropDownWithCheckBox(),
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
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (file == null) {
                                        Fluttertoast.showToast(
                                            msg: "Kies een profiel photo",
                                            fontSize: 18,
                                            gravity: ToastGravity.BOTTOM);
                                      } else if (value == null) {
                                        Fluttertoast.showToast(
                                            msg: "Kies een opleiding",
                                            fontSize: 18,
                                            gravity: ToastGravity.BOTTOM);
                                      } else if (_formkey.currentState
                                          .validate()) {
                                        setState(() {
                                          _isloading = true;
                                          valueInit = false;
                                        });

                                        var snapshot = await firebaseStorage
                                            .ref()
                                            .child('imageuser/' +
                                                emailController.text)
                                            .putFile(file);

                                        var url =
                                            await snapshot.ref.getDownloadURL();

                                        dynamic result = await _auth
                                            .registerWithEmailAndPassword(
                                          emailController.text,
                                          passwordController.text,
                                        );

                                        if (result != null) {
                                          try {
                                            var interestsUser = [];
                                            selectedItemsInterests
                                                .forEach((element) {
                                              interestsUser.add(
                                                  {"category_Id": element});
                                            });

                                            var data = {
                                              "id": result.toString(),
                                              "firstname":
                                                  firstnameController.text,
                                              "lastname":
                                                  lastnameController.text,
                                              "email": emailController.text,
                                              "imageUrl": url,
                                              "education_Id": this.value,
                                              "aboutMe": aboutMeController.text,
                                              "interests": interestsUser
                                            };

                                            Response response =
                                                await Dio().post(
                                              "https://finalworkapi.azurewebsites.net/api/User",
                                              options: Options(headers: {
                                                HttpHeaders.contentTypeHeader:
                                                    "application/json",
                                                "authorisation":
                                                    "00000000-0000-0000-0000-000000000000"
                                              }),
                                              data: jsonEncode(data),
                                            );
                                            if (response.data["statusCode"] ==
                                                200) {
      
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Login()));
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg: response
                                                      .data["errorMessage"]
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
                                              msg: "Some problems",
                                              fontSize: 18,
                                              gravity: ToastGravity.BOTTOM);
                                        }
                                      }
                                    },
                                    child: Text('Registreer'),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                              ],
                            )))),
              ));
        }
      },
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

  Widget getAboutMeInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: TextFormField(
        keyboardType: TextInputType.text,
        decoration: inputDecoration(Icons.info, "Over mij"),
        controller: aboutMeController,
        validator: (value) {
          if (value.toString().isEmpty) {
            return "Over mij mag niet leeg zijn";
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
        hint: Text("Kies opleiding"),
        isExpanded: true,
        value: this.value,
      ),
    );
  }

  Widget getDropDownWithCheckBox() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: MultiSelectDialogField(
        height: 250,
        items: checkBoxDropDownItems
            .map((e) => MultiSelectItem(e.key, e.value))
            .toList(),
        listType: MultiSelectListType.CHIP,
        onConfirm: (values) {
          selectedItemsInterests = values;
        },
        title: Text("Selecteer interesses"),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(30)),
            border: Border.all(
              color: Colors.black,
              width: 2,
            )),
        buttonIcon: Icon(
          Icons.arrow_drop_down,
          color: Colors.blue,
        ),
        buttonText: Text(
          "Selecteer interesses",
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}

class KeyValueModel {
  String key;
  String value;

  KeyValueModel({this.key, this.value});
}
