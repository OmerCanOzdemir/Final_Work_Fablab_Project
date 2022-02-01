import 'package:fablab_project_final_work/auth/login.dart';
import 'package:fablab_project_final_work/auth/register.dart';
import 'package:fablab_project_final_work/models/AppUser.dart';
import 'package:fablab_project_final_work/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fablab_project_final_work/navigation/bottom_navigation.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser;
   
    if (user == null) {
      return Login();
    } else {
      return BottomNavigation();
    }
  }
}
