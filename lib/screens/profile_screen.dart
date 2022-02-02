import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fablab_project_final_work/auth/login.dart';
import 'package:fablab_project_final_work/screens/joined_projects_screen.dart';
import 'package:fablab_project_final_work/screens/my_projects_screen.dart';
import 'package:fablab_project_final_work/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User user = FirebaseAuth.instance.currentUser;

  var firstname;
  var lastname;
  var imageUrl;
  Future<void> getUserInfo() async {
    firstname = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get()
        .then((value) => firstname = value.get("firstname").toString());

    lastname = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get()
        .then((value) => lastname = value.get("lastname").toString());

    imageUrl = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get()
        .then((value) => imageUrl = value.get('image').toString());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserInfo(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Image(
                    image: AssetImage("assets/informatica.jpg"),
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height / 3,
                  ),
                  Positioned(
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(imageUrl),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              ListTile(
                title: Text(firstname + " " + lastname),
                subtitle: Text("Toegepaste informatica"),
              ),
                 FlatButton.icon(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyProjects()));
                },
                icon: Icon(Icons.construction),
                label: Text(
                  "Mijn projecten",
                ),
                color: Colors.blue,
              ),
                   FlatButton.icon(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => JoinedProjects()));
                },
                icon: Icon(Icons.construction),
                label: Text(
                  "Deelgenomen projecten",
                ),
                color: Colors.blue,
              ),
              FlatButton.icon(
                onPressed: () {
                  AuthService auth = AuthService();
                  auth.signOut();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Login()));
                },
                icon: Icon(Icons.logout),
                label: Text(
                  "Uitloggen",
                ),
                color: Colors.red,
              ),     
              
           
            ],
          );
        }
        return Container();
      },
    );
  }
}
