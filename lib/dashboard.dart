import 'dart:async';

import 'package:notify/Utilities/DBHelper.dart';
import 'package:notify/model/NotifyModel.dart';
import 'package:notify/model/user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Dashboard extends StatefulWidget {
  final User user;

  Dashboard(this.user);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DBHelper helper = DBHelper();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  List<ModelNotification> notiList;
  int count = 0;
  int result;
  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        setState(() async {
          String msg = message['notification']['body'];

          var noti = new ModelNotification(msg);

          if (noti.notifyid != null) {
            result = await helper.updateNotificationInfo(noti);
          } else {
            result = await helper.insertNotificationInfo(noti);
          }

          updateListView();

          _showItemDialog(message);
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        setState(() async {
          String msg = message['notification']['body'];
          print(msg);
          var noti = new ModelNotification(msg);

          if (noti.notifyid != null) {
            result = await helper.updateNotificationInfo(noti);
          } else {
            result = await helper.insertNotificationInfo(noti);
          }

          updateListView();

          //_showItemDialog(message);
        });
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  Widget _buildDialog(BuildContext context, Map<String, dynamic> message) {
    return AlertDialog(
        title: Text('Leave Applied Successfullt'),
        content: Text(message['notification']['body']),
        actions: <Widget>[
          FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context, false);
              })
        ]);
  }

  void _showItemDialog(Map<String, dynamic> message) async {
    showDialog<bool>(
      context: context,
      builder: (_) => _buildDialog(context, message),
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      if (notiList == null) {
        notiList = List<ModelNotification>();
        updateListView(); // get renter information
      }
    });
    return Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          elevation: .1,
          centerTitle: true,
          leading: Container(),
          backgroundColor: Color.fromRGBO(49, 87, 110, 1.0),
        ),
        body: getNotifyListView());
  }

  ListView getNotifyListView() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            title: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 16, left: 16, top: 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                              child: Text(this.notiList[position].message)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.red)),
                      onPressed: () {
                        _delete(context, this.notiList[position]);
                      },
                      color: Colors.red,
                      textColor: Colors.white,
                      child: Text("Delete".toUpperCase(),
                          style: TextStyle(fontSize: 14)),
                    ),
                  ],
                )
              ],
            ),
            onTap: () {
              print("List Item Tapped");
            },
          ),
        );
      },
    );
  }

  void _delete(BuildContext context, ModelNotification note) async {
    int result = await helper.deleteNotificationInfo(note.notifyid);
    if (result != 0) {
      updateListView();
    }
  }

  void updateListView() {
    var dbFuture = helper.initDb();
    dbFuture.then((database) {
      Future<List<ModelNotification>> noteListFuture =
          helper.getNotificationInfoList();
      noteListFuture.then((notifyList) {
        setState(() {
          this.notiList = notifyList;
          this.count = notifyList.length;
        });
      });
    });
  }
}
