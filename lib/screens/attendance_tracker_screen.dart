import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glug_app/resources/firestore_provider.dart';
import 'package:glug_app/widgets/drawer_items.dart';
import 'package:glug_app/widgets/error_widget.dart';
import 'package:glug_app/widgets/subject_form.dart';

class AttendanceTrackerScreen extends StatefulWidget {
  @override
  _AttendanceTrackerScreenState createState() =>
      _AttendanceTrackerScreenState();
}

class _AttendanceTrackerScreenState extends State<AttendanceTrackerScreen> {
  FirestoreProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = FirestoreProvider();
  }

  @override
  void dispose() {
    super.dispose();
    _provider = null;
  }

  _addSubjectDialog(context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          elevation: 5.0,
          backgroundColor: Colors.transparent,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.45,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 5), blurRadius: 10),
              ],
            ),
            child: SubjectForm(),
          ),
        );
      },
    );
  }

  _buildTiles(List<dynamic> subjects) {
    List<Widget> data;
    data = subjects.map((sub) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sub["name"].toString().length <= 12
                        ? sub["name"]
                        : sub["name"].toString().substring(0, 12) + "...",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    iconSize: 20.0,
                    onPressed: () {
                      _provider.deleteSubject(sub.documentID);
                    },
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                height: 30.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle),
                      iconSize: 18.0,
                      onPressed: () {
                        _provider.addNotAttended(sub);
                      },
                      color: Colors.red,
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle),
                      iconSize: 20.0,
                      onPressed: () {
                        _provider.addAttended(sub);
                      },
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              Text(
                "Total Classes: ${sub["total"]}",
                style: TextStyle(fontSize: 12.0),
              ),
              Text(
                "Classes Attended: ${sub["attended"]}",
                style: TextStyle(fontSize: 12.0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: LinearProgressIndicator(
                      value: sub["total"] != 0
                          ? sub["attended"] / sub["total"]
                          : 0,
                      backgroundColor: Colors.red,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  Text(
                    "${sub["total"] != 0 ? (sub["attended"] / sub["total"] * 100).round() : 0}%",
                    style: TextStyle(fontSize: 14.0),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
        childAspectRatio: 1.2,
        // shrinkWrap: true,
        children: data,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progDim = MediaQuery.of(context).size.width * 0.3;

    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance Tracker"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _addSubjectDialog(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: DrawerItems(),
      ),
      body: StreamBuilder(
          stream: _provider.fetchSubjectData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<dynamic> subs = snapshot.data.documents;

              var attended = 0;
              var total = 0;
              subs.forEach((sub) {
                attended += sub["attended"];
                total += sub["total"];
              });

              var percentage =
                  total != 0 ? (attended / total * 100).round() : 0;

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: progDim,
                        width: progDim,
                        child: Stack(
                          children: [
                            Center(
                              child: Container(
                                height: progDim,
                                width: progDim,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.green),
                                  backgroundColor: Colors.red,
                                  value: percentage / 100,
                                  strokeWidth: 8.0,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                "$percentage%",
                                style: TextStyle(
                                  fontSize: 22.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            "Total Classes: $total",
                            style: TextStyle(fontSize: 18.0),
                          ),
                          Text(
                            "Classes Attended: $attended",
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Expanded(child: _buildTiles(snapshot.data.documents)),
                ],
              );
            } else if (snapshot.hasError) {
              return errorWidget(snapshot.error);
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
