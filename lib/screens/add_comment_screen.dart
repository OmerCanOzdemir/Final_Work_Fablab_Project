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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Voeg mening"),),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
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
                                    User user =
                                        FirebaseAuth.instance.currentUser;
                                    var data = {
                                      "userId": user.uid,
                                      "projectId": id,
                                      "message": messageController.text
                                    };
                                    Response response =await  Dio().post(
                                        "https://finalworkapi.azurewebsites.net/api/Project/putComment/" + id,  options: Options(headers: {
                                        HttpHeaders.contentTypeHeader:
                                            "application/json",
                                      }),
                                      data: jsonEncode(data),);
                                     Fluttertoast.showToast(
                                        msg: "Mening aangemaakt",
                                        fontSize: 18,
                                        gravity: ToastGravity.BOTTOM);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => CommentProjectScreen(id: id,)));
                                  } catch (e) {}
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
