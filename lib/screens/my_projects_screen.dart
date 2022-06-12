import 'package:fablab_project_final_work/screens/created_project_screen.dart';
import 'package:fablab_project_final_work/screens/joined_projects_screen.dart';
import 'package:flutter/material.dart';

class MyProjects extends StatelessWidget {
  const MyProjects({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
        title: Text("Mijn projecten"),
        bottom: TabBar(
          tabs: [
            Tab(
              text: "Aangemaakte projecten",
            ),
            Tab(
              text: "Deelgenomen projecten",
            )
          ],
        ),
      ),
      body: TabBarView(
        children: [
         CreatedProject(),
          JoinedProject()
        ],
      ),
      ),
    );
  }
}
