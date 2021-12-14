import 'package:flutter/material.dart';
import 'navigation/bottom_navigation.dart';
void main() {
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Fablab project",
      home: BottomNavigation(),
    );
  }
}



  