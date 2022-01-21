import 'package:fablab_project_final_work/screens/chatbot.dart';
import 'package:fablab_project_final_work/screens/profile_screen.dart';
import 'package:fablab_project_final_work/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:fablab_project_final_work/screens/home_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key key}) : super(key: key);

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  
  int _selectedItem = 0;

  List<Widget> _widgetOptions = <Widget>[
    Home(),
    ChatbotScreen(),
   Profile()
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedItem = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Final Work Fablab"),
        centerTitle: true,
      ),
      body: _widgetOptions.elementAt(_selectedItem),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Chatbot"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: _selectedItem,
        onTap: _onItemTap,
      ),
    );
  }
}
