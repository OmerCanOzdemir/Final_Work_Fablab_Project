import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fablab_project_final_work/decoration/input_decoration.dart';
import 'package:fablab_project_final_work/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class ProfileUpdate extends StatefulWidget {
  String id;
  ProfileUpdate({this.id});

  @override
  State<ProfileUpdate> createState() => _ProfileUpdateState(id);
}

class _ProfileUpdateState extends State<ProfileUpdate> {
  String id;
  //form key
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  var value;
  //input controllers
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();
  _ProfileUpdateState(this.id);
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
        Response userResponse = await Dio().get(
            "https://finalworkapi.azurewebsites.net/api/User/byId/" + id,
            options: Options(headers: {
              "authorisation": "00000000-0000-0000-0000-000000000000"
            }));
        firstnameController.text = userResponse.data["user"]["firstname"];
        lastnameController.text = userResponse.data["user"]["lastname"];
        aboutMeController.text = userResponse.data["user"]["aboutMe"];

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

  User user = FirebaseAuth.instance.currentUser;

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
          if (snapshot.connectionState == ConnectionState.waiting ||
              _isloading) {
            return Scaffold(
              appBar: AppBar(title: Text("Profiel aanpassen")),
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
                appBar: AppBar(title: Text("Profiel aanpassen")),
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
                                        height: 14,
                                      ),
                                      getFirstnameInput(),
                                      SizedBox(
                                        height: 14,
                                      ),
                                      getLastnameInput(),
                                      SizedBox(
                                        height: 14,
                                      ),
                                      getAboutMeInput(),
                                      SizedBox(
                                        height: 14,
                                      ),
                                      getDropdownItems(),
                                      SizedBox(
                                        height: 14,
                                      ),
                                      getDropDownWithCheckBox(),
                                      Container(
                                        height: 50,
                                        child: ElevatedButton(
                                          child: Text("Profiel aanpassen"),
                                          onPressed: () async {
                                            if (value == null) {
                                              Fluttertoast.showToast(
                                                  msg: "Kies een opleiding",
                                                  fontSize: 18,
                                                  gravity: ToastGravity.BOTTOM);
                                            } else if (_formkey.currentState
                                                .validate()) {
                                              setState(() {
                                                valueInit = false;
                                                _isloading = true;
                                              });
                                              try {
                                                var interestsUser = [];
                                                selectedItemsInterests
                                                    .forEach((element) {
                                                  interestsUser.add(
                                                      {"category_Id": element});
                                                });

                                                var data = {
                                                  "firstname":
                                                      firstnameController.text,
                                                  "lastname":
                                                      lastnameController.text,
                                                  "education_Id": this.value,
                                                  "aboutMe":
                                                      aboutMeController.text,
                                                  "interests": interestsUser,
                                                  "email": user.email
                                                };
                                                Response response =
                                                    await Dio().put(
                                                  "https://finalworkapi.azurewebsites.net/api/User/" +
                                                      id,
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
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Profile(
                                                                userId: id,
                                                              )));
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg: response
                                                          .data["errorMessage"]
                                                          .toString(),
                                                      fontSize: 18,
                                                      gravity:
                                                          ToastGravity.BOTTOM);
                                                }
                                              } catch (e) {
                                                Fluttertoast.showToast(
                                                    msg: e.toString(),
                                                    fontSize: 18,
                                                    gravity:
                                                        ToastGravity.BOTTOM);
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ]))))));
          }
        });
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
}

class KeyValueModel {
  String key;
  String value;

  KeyValueModel({this.key, this.value});
}
