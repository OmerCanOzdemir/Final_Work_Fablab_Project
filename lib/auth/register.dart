import 'package:fablab_project_final_work/auth/login.dart';
import 'package:fablab_project_final_work/navigation/bottom_navigation.dart';
import 'package:fablab_project_final_work/services/auth.dart';
import 'package:fablab_project_final_work/services/database.dart';
import 'package:flutter/material.dart';
import 'package:fablab_project_final_work/decoration/input_decoration.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Register extends StatefulWidget {
  const Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  //Auth service
  final AuthService _auth = AuthService();

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
                          child: Image.network(
                              "https://protocoderspoint.com/wp-content/uploads/2020/10/PROTO-CODERS-POINT-LOGO-water-mark-.png"),
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
                        Container(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formkey.currentState.validate()) {
                                dynamic result =
                                    await _auth.registerWithEmailAndPassword(
                                        emailController.text,
                                        passwordController.text,
                                        firstnameController.text,
                                        lastnameController.text);
                                if (result == "Account aangemaakt") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Login()));
                                } else {
                                  Fluttertoast.showToast(
                                      msg: result,
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

  Widget getEmailInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: TextFormField(
        keyboardType: TextInputType.text,
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
}
