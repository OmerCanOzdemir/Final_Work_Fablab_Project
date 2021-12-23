import 'package:fablab_project_final_work/auth/register.dart';
import 'package:fablab_project_final_work/decoration/input_decoration.dart';
import 'package:fablab_project_final_work/navigation/bottom_navigation.dart';
import 'package:fablab_project_final_work/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  //input controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AuthService _auth = AuthService();
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
                        Container(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formkey.currentState!.validate()) {
                                dynamic result =
                                    await _auth.loginWithEmailAndPassword(
                                        emailController.text,
                                        passwordController.text);
                                if (result == "U bent ingelogd") {
                                  Fluttertoast.showToast(
                                      msg: result,
                                      fontSize: 18,
                                      gravity: ToastGravity.BOTTOM);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BottomNavigation()));
                                } else {
                                  Fluttertoast.showToast(
                                      msg: result.toString(),
                                      fontSize: 18,
                                      gravity: ToastGravity.BOTTOM);
                                }
                              }
                            },
                            child: Text('Login'),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Register()));
                            },
                            child: Text('Geen account? Registreer'))
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
          } else
            return null;
        },
      ),
    );
  }
}
