import 'package:flutter/material.dart';
import 'package:notify/Animation/FadeAnimation.dart';
import 'package:notify/dashboard.dart';
import 'package:notify/model/user.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MainPage(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue));
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  final String apiUrl = 'http://182.176.157.77:7018/api/';
  bool _progressController = false;
  String loadingMessage = 'Login User...';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();

    // _nameController = new TextEditingController();
    // _passwordController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Container(
                child: Column(children: <Widget>[
          Container(
              height: 400,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/background.png'),
                      fit: BoxFit.fill)),
              child: Stack(children: <Widget>[
                Positioned(
                    left: 30,
                    width: 80,
                    height: 200,
                    child: FadeAnimation(
                        1,
                        Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/light-1.png')))))),
                Positioned(
                    left: 140,
                    width: 80,
                    height: 150,
                    child: FadeAnimation(
                        1.3,
                        Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/light-2.png')))))),
                Positioned(
                    right: 40,
                    top: 40,
                    width: 80,
                    height: 150,
                    child: FadeAnimation(
                        1.5,
                        Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/clock.png')))))),
                Positioned(
                    child: FadeAnimation(
                        1.6,
                        Container(
                            margin: EdgeInsets.only(top: 50),
                            child: Center(
                                child: Text("Login",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold))))))
              ])),
          Padding(
              padding: EdgeInsets.all(30.0),
              child: Column(children: <Widget>[
                FadeAnimation(
                    1.8,
                    Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromRGBO(143, 148, 251, .2),
                                  blurRadius: 20.0,
                                  offset: Offset(0, 10))
                            ]),
                        child: Column(children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[100]))),
                            child: TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              focusNode: _nameFocus,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Username",
                                  hintStyle:
                                      TextStyle(color: Colors.grey[400])),
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.all(8.0),
                              child: TextFormField(
                                  controller: _passwordController,
                                  textInputAction: TextInputAction.done,
                                  focusNode: _passwordFocus,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Password",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400]))))
                        ]))),
                SizedBox(height: 30),
                FadeAnimation(
                    2,
                    GestureDetector(
                        onTap: () {
                          authenticateFromServer(
                              _nameController.text, _passwordController.text);
                        },
                        child: _progressController
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    CircularProgressIndicator(
                                        backgroundColor: Colors.white),
                                    Container(
                                        margin: EdgeInsets.only(left: 8),
                                        child: Text(loadingMessage,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)))
                                  ])
                            : Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(colors: [
                                      Color.fromRGBO(143, 148, 251, 1),
                                      Color.fromRGBO(143, 148, 251, .6)
                                    ])),
                                child: Center(
                                    child: Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )))))
              ]))
        ]))));
  }

  void authenticateFromServer(String email, String password) async {
    /*isDeviceConnected().then((internet) {
      if (internet == null || !internet) {
        Toast.show(
            "Device is not connected to internet. Retry Login after connected.",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM);
        return;
      }
    });*/

    String deviceToken = await _firebaseMessaging.getToken();
    print(deviceToken);

    final response = await http.post(apiUrl + 'user/authenticate',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "UserName": email,
          "Password": password,
          "DeviceToken": deviceToken
        }));

    print(response.statusCode);
    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      String token = parsedJson['token'];
      int userId = parsedJson['userId'];
      int instituteId = parsedJson['instituteId'];
      String userName = parsedJson['urName'];
      String name = parsedJson['name'];

      print(instituteId);

      _navigateToHome(new User(userId, instituteId, userName, name, token));
    } else {
      Toast.show("Email/Password is incorrect.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  /*Future<bool> isDeviceConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }*/

  void _navigateToHome(User user) {
    Navigator.pop(context);
    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => Dashboard(user)));
  }
}
