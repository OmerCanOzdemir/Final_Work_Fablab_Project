import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fablab_project_final_work/decoration/input_decoration.dart';
import 'package:fablab_project_final_work/screens/comments_project_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddCommentScreen extends StatefulWidget {
  String id;
  AddCommentScreen({this.id});

  @override
  State<AddCommentScreen> createState() => _AddCommentScreenState(id);
}

class _AddCommentScreenState extends State<AddCommentScreen> {
  String id;
  _AddCommentScreenState(this.id);
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController messageController = TextEditingController();
  bool _isloading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Voeg mening"),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _isloading
              ? Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: "Loading",
                    backgroundColor: Colors.white,
                  ),
                )
              : Center(
                  child: SingleChildScrollView(
                      child: Form(
                          key: _formkey,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                getMessageInput(),
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  child: ElevatedButton(
                                    child: Text("Voeg mening"),
                                    onPressed: () async {
                                      if (_formkey.currentState.validate()) {
                                        try {
                                          setState(() {});
                                          User user =
                                              FirebaseAuth.instance.currentUser;
                                          var data = {
                                            "userId": user.uid,
                                            "projectId": id,
                                            "message": messageController.text
                                          };
                                          Response response = await Dio().post(
                                            "https://finalworkapi.azurewebsites.net/api/Project/putComment/" +
                                                id,
                                            options: Options(headers: {
                                              HttpHeaders.contentTypeHeader:
                                                  "application/json",
                                              "authorisation":
                                                  "00000000-0000-0000-0000-000000000000"
                                            }),
                                            data: jsonEncode(data),
                                          );
                                          if (response
                                              .data["statusCode" == 200]) {
                                            Fluttertoast.showToast(
                                                msg: "Mening aangemaakt",
                                                fontSize: 18,
                                                gravity: ToastGravity.BOTTOM);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CommentProjectScreen(
                                                          id: id,
                                                        )));
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
                                      }
                                    },
                                  ),
                                )
                              ]))))),
    );
  }

  Widget getMessageInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: TextFormField(
        keyboardType: TextInputType.text,
        decoration: inputDecoration(Icons.title, "Mening"),
        controller: messageController,
        validator: (value) {
          if (value.toString().isEmpty) {
            return "Mening mag niet leeg zijn";
          } else
            return null;
        },
      ),
    );
  }
}
