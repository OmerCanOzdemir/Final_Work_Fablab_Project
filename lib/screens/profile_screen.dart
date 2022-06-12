import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:fablab_project_final_work/auth/login.dart';
import 'package:fablab_project_final_work/navigation/dashboard.dart';
import 'package:fablab_project_final_work/screens/joined_projects_screen.dart';
import 'package:fablab_project_final_work/screens/my_projects_screen.dart';
import 'package:fablab_project_final_work/screens/update_profile_screen.dart';
import 'package:fablab_project_final_work/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  String userId;
  Profile({
    this.userId,
  });

  @override
  _ProfileState createState() => _ProfileState(userId);
}

class _ProfileState extends State<Profile> {
  String userId;
  User user = FirebaseAuth.instance.currentUser;
  _ProfileState(this.userId);
  var userData;
  var check;
  var createdProjectLength;
  var joinedProjectLength;
  var interestsUser = [];
  Future<void> inizializeData() async {
    try {
      interestsUser = [];
      Response response = await Dio().get(
          "https://finalworkapi.azurewebsites.net/api/User/byId/" + userId);
      userData = response.data["user"];

      createdProjectLength = userData["created_Projects"].length.toString();
      joinedProjectLength = userData["joined_Projects"].length +
          userData["created_Projects"].length;
      joinedProjectLength = joinedProjectLength.toString();

      var interests = userData["interests"];
      interests.forEach((element) {
        interestsUser.add(element["category"]["name"]);
      });
      if (user.uid == userData["id"]) {
        check = true;
      } else
        check = false;
      //print(userData);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: inizializeData(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            child: Text(snapshot.error),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: Text("Profiel"),leading: IconButton(icon: Icon(Icons.arrow_back),onPressed: (){
               Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Dashboard()));
            },)),
            
            body: Padding(child: ListView(
              physics: BouncingScrollPhysics(),
              children: [
                Center(
                    child: ClipOval(
                        child: Material(
                  color: Colors.transparent,
                  child: Ink.image(
                    image: NetworkImage(userData["imageUrl"]),
                    fit: BoxFit.cover,
                    width: 128,
                    height: 128,
                  ),
                ))),
                const SizedBox(height: 24),
                Column(
                  children: [
                    Text(
                      userData["firstname"] + " " + userData["lastname"],
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      userData["email"],
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      userData["education"]["name"],
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Visibility(
                        visible: check,
                        child: ElevatedButton(
                          child: Text("Profiel aanpassen"),
                          onPressed: () {
                            Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileUpdate(id:userId,)));
                          },
                          style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(), onPrimary: Colors.white),
                        )),
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          onPressed: () {},
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                createdProjectLength,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                "Gemaakte projecten",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                        VerticalDivider(),
                        MaterialButton(
                          onPressed: () {},
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                joinedProjectLength,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                "Deelgenomen projecten",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 48,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mijn interesses",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            interestsUser.join(', '),
                            style: TextStyle(fontSize: 16, height: 1.5),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            "Over Mij",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            userData["aboutMe"],
                            style: TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),padding: EdgeInsets.all(8),)
          );
        }
         if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: Text("Profiel")),
              body: Center(
              
              child: CircularProgressIndicator(
              semanticsLabel: "Loading",
              backgroundColor: Colors.white,
            ),
            ),
            );
          }
      },
    );
  }
}
