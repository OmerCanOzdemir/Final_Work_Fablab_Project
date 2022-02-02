import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fablab_project_final_work/screens/updata_project_screen.dart';
import 'package:fablab_project_final_work/services/auth.dart';
import 'package:fablab_project_final_work/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyProjects extends StatelessWidget {
  const MyProjects({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mijn Projecten"),
        centerTitle: true,
      ),
      body: MyProjectsBody(),
    );
  }
}

class MyProjectsBody extends StatelessWidget {
  User user = FirebaseAuth.instance.currentUser;
  //Database service
  final DatabaseServices _databaseServices = DatabaseServices();

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> projects = FirebaseFirestore.instance
        .collection('project')
        .where('author', isEqualTo: user.uid)
        .snapshots();
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: projects,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            Fluttertoast.showToast(
                msg: snapshot.error.toString(),
                fontSize: 18,
                gravity: ToastGravity.BOTTOM);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }
          final data = snapshot.requireData;
          
          return ListView.builder(
            itemCount: data.size,
            itemBuilder: (context, index) {
             
              var persons = [];
              for (var person in data.docs[index]['joinedPersons']) {
                persons.add(person);
              }
              var own_project = false;
              if (user.uid == data.docs[index]['author']) {
                own_project = true;
              }

              return Container(
                  child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 16,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          Ink.image(
                              height: 200,
                              image: AssetImage('assets/image.png'),
                              fit: BoxFit.fitWidth)
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16, top: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              data.docs[index]['title'],
                              style: TextStyle(
                                  color: Color.fromARGB(137, 22, 22, 22)),
                              textAlign: TextAlign.left,
                            ),
                            Text(
                              data.docs[index]['littleDescription'],
                              textAlign: TextAlign.left,
                            ),
                            Text(
                              'Aantal deelnemende personen:${persons.length}/${data.docs[index]['maxPerson']}',
                              textAlign: TextAlign.left,
                            )
                          ],
                        ),
                      ),
               
                      Center(
                        child: Visibility(
                          visible: own_project,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _databaseServices
                                  .deleteProject(data.docs[index].id);
                            },
                            child: Text("Verwijder project"),
                          ),
                        ),
                      ),
                      Center(
                        child: Visibility(
                          visible: own_project,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UpdataProject(
                                            id: data.docs[index].id,
                                          )));
                            },
                            child: Text("Project aanpassen"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
            },
          );
        },
      ),
    );
  }
}
