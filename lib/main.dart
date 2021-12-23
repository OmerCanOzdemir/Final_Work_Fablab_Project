import 'package:fablab_project_final_work/auth/login.dart';
import 'package:fablab_project_final_work/models/AppUser.dart';
import 'package:fablab_project_final_work/services/auth.dart';
import 'package:fablab_project_final_work/wrapper/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation/bottom_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Wrapper(),
        title: "Fablab project",
      );
  }
}
