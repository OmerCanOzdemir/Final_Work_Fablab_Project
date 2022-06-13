import 'package:fablab_project_final_work/auth/login.dart';
import 'package:fablab_project_final_work/screens/chatbot.dart';
import 'package:fablab_project_final_work/screens/home_screen.dart';
import 'package:fablab_project_final_work/screens/my_invitation_screen.dart';
import 'package:fablab_project_final_work/screens/my_projects_screen.dart';
import 'package:fablab_project_final_work/screens/my_tasks_screen.dart';
import 'package:fablab_project_final_work/screens/profile_screen.dart';
import 'package:fablab_project_final_work/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  User user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            child: GridView(
              children: [
                InkWell(
                  onTap: () => {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Home()))
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder, size: 50, color: Colors.white),
                          Text(
                            "Projecten",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          )
                        ]),
                  ),
                ),
                InkWell(
                  onTap: () => {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyProjects()))
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory, size: 50, color: Colors.white),
                          Text(
                            "Mijn projecten",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          )
                        ]),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyInvitationScreen(userId: user.uid,)));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email, size: 50, color: Colors.white),
                          Text(
                            "Uitnodigingen",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          )
                        ]),
                  ),
                ),InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyTasksScreen()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task, size: 50, color: Colors.white),
                          Text(
                            "Mijn taken",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          )
                        ]),
                  ),
                ),
                InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatbotScreen()));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.smart_toy,
                                size: 50, color: Colors.white),
                            Text(
                              "Chatbot",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 30),
                            )
                          ]),
                    )),
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Profile(userId: user.uid,)));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_circle,
                              size: 50, color: Colors.white),
                          Text(
                            "Profiel",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          )
                        ]),
                  ),
                ),
                InkWell(
                  onTap: () {
                    AuthService auth = AuthService();
                    auth.signOut();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Login()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 50, color: Colors.white),
                          Text(
                            "Uitloggen",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          )
                        ]),
                  ),
                ),
              ],
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
            ),
          )
        ],
      ),
    );
  }
}
