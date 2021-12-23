import 'package:flutter/material.dart';

import '../services/auth.dart';

class Home extends StatelessWidget {
  const Home ({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthService auth = AuthService();
    auth.signOut();
    return Center(
      child: Text("Home page"),
    );
  }
}