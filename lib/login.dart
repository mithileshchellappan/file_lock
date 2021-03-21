import 'dart:async';
import 'dart:math';

import 'package:file_lock/screens/foldersView.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:hive/hive.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'summa.dart';
import 'themes.dart';
import 'triangle.dart';
import 'circle.dart';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum ShapeState { Blank, Circle, Rectangle, Triangle }

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

User loggedInUser;

class _LoginState extends State<Login> with TickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  var activeShape = ShapeState.Circle;
  var shapeState = ShapeState.Blank;
  var boardState = List<List<ShapeState>>.generate(
      6, (i) => List<ShapeState>.generate(6, (j) => ShapeState.Blank));

  Animation<double> _boardAnimation;
  AnimationController _boardController;
  double _boardOpacity = 1.0;
  bool patternFinished = false;
  int _moveCount = 0;
  List<String> correctPatternMatrix = [], enteredPatternMatrix = [];

  @override
  void initState() {
    getCurrentUser();
    getPattern();
    _boardController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _boardAnimation = Tween(begin: 1.0, end: 0.0).animate(_boardController)
      ..addListener(() {
        setState(() {
          _boardOpacity = _boardAnimation.value;
        });
      });
    super.initState();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _boardController.dispose();
    super.dispose();
  }

  getPattern() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      correctPatternMatrix = prefs.getStringList("pattern");
    });
  }

  removePattern() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("pattern");
    print("pattern deleted");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // removePattern();
              //reset();
            },
            child: Icon(Icons.cached),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              shapeContainer,
              Center(
                child: Text(
                  "LOGIN",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                    fontSize: 30.0,
                  ),
                ),
              ),
              Stack(
                children: <Widget>[
                  board,
                  shapeStateDisplay,
                ],
              ),
              forgotPassword,
            ],
          )),
    );
  }

  Widget get shapeContainer => Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Container(
          height: 89,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _moveCount == 0
                ? [circle, buildRectangle(), buildTriangle()]
                : (_moveCount == 1
                    ? [buildRectangle(), buildTriangle()]
                    : (_moveCount == 2 ? [buildTriangle()] : [Container()])),
          ),
        ),
      );

  SizedBox buildTriangle() {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: TrianglePainter(
          strokeColor: Colors.blue,
          strokeWidth: 10,
          paintingStyle: PaintingStyle.fill,
        ),
        child: Container(
          height: 180,
          width: 200,
        ),
      ),
    );
  }

  SizedBox buildRectangle() {
    return SizedBox(
      width: 70.0,
      height: 40.0,
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.red),
      ),
    );
  }

  Widget get shapeStateDisplay => Builder(builder: (context) {
        Function eq = const DeepCollectionEquality().equals;

        return Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Visibility(
            visible: patternFinished,
            child: Opacity(
              opacity: 1.0 - _boardOpacity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  eq(enteredPatternMatrix, correctPatternMatrix)
                      ? NavigationUtil()
                      : Text(
                          "WRONG PATTERN",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                            fontSize: 30.0,
                          ),
                        )
                ],
              ),
            ),
          ),
        );
      });

  Widget get circle => SizedBox(
        width: 40.0,
        height: 40.0,
        child: Container(
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Colors.purple),
        ),
      );

  Widget get board => Opacity(
        opacity: _boardOpacity,
        child: Padding(
          padding: const EdgeInsets.only(left: 32.0, right: 32.0),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              color: Colors.grey[300],
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: 36,
                itemBuilder: (context, index) {
                  int row = index ~/ 6;
                  int col = index % 6;
                  return gameButton(row, col);
                },
              ),
            ),
          ),
        ),
      );

  Widget get bottomBar => Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: FloatingActionButton(
          heroTag: 'reset',
          child: Icon(Icons.cached),
          backgroundColor: accentColor,
          mini: true,
          onPressed: () => reset(),
        ),
      );
  Widget get forgotPassword => Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: RaisedButton(
          child: Container(
            child: Text('Forgot Pattern?'),
          ),
          onPressed: () async {
            try {
              //await _auth.sendPasswordResetEmail(email: loggedInUser.email);
              var box = Hive.box('creds');
              String email = box.get('email');
              String pass = box.get('pass');
              String enterEmail = '';
              String enterPass = '';
              int min = 100000; //min and max values act as your 6 digit range
              int max = 999999;
              var randomizer = new Random();
              var rNum = min + randomizer.nextInt(max - min);
              Alert(
                  context: context,
                  title: 'Enter your login email and password',
                  content: Column(
                    children: [
                      TextField(
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (val) {
                            setState(() {
                              enterEmail = val;
                            });
                          }),
                      TextField(
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        onChanged: (val) {
                          setState(() {
                            enterPass = val;
                          });
                        },
                      ),
                    ],
                  ),
                  buttons: [
                    DialogButton(
                        child: Text('Submit'),
                        onPressed: () async {
                          if (enterEmail != null && enterPass != null) {
                            if (enterEmail == email && enterPass == pass) {
                              final Email email = Email(
                                body:'Your recovery code for File Lock app is $rNum',
                                subject: 'Forgot Pattern in File Lock app'
                              );
                              print(rNum);
                              
                              await FlutterEmailSender.send(email); 
                            }
                          }
                        })
                  ]).show();
            } catch (e) {
              print(e);
            }
          },
        ),
      );

  Widget gameButton(int row, int col) {
    return GestureDetector(
      onTap: (boardState[row][col] == ShapeState.Blank &&
              shapeState == ShapeState.Blank)
          ? () {
              _moveCount++;
              boardState[row][col] = activeShape;
              checkWinningCondition(row, col, activeShape);
              toggleActiveShape();
              setState(() {
                enteredPatternMatrix.add(row.toString());
                enteredPatternMatrix.add(col.toString());
                print(enteredPatternMatrix);
              });
            }
          : null,
      child: Container(
        color: Colors.white,
        child: Center(
          child: shapePiece(row, col),
        ),
      ),
    );
  }

  void toggleActiveShape() {
    if (activeShape == ShapeState.Circle)
      activeShape = ShapeState.Rectangle;
    else
      activeShape = ShapeState.Triangle;
  }

  shapePiece(int row, int col) {
    if (boardState[row][col] == ShapeState.Circle)
      return circle;
    else if (boardState[row][col] == ShapeState.Rectangle)
      return buildRectangle();
    else if (boardState[row][col] == ShapeState.Triangle)
      return buildTriangle();
    else
      return null;
  }

  void reset() {
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 6; j++) {
        boardState[i][j] = ShapeState.Blank;
      }
    }
    activeShape = ShapeState.Circle;
    shapeState = ShapeState.Blank;
    _moveCount = 0;
    setState(() {
      patternFinished = false;
      enteredPatternMatrix = [];
    });
    _boardController.reverse();
  }

  void checkWinningCondition(int row, int col, ShapeState shapeState) {
    if (_moveCount == 3) {
      setState(() {
        toggleBoardOpacity();
        patternFinished = true;
      });
    }
  }

  void toggleBoardOpacity() {
    if (_boardOpacity == 0.0) {
      setState(() {
        patternFinished = false;
      });
      _boardController.reverse();
    } else if (_boardOpacity == 1.0) {
      _boardController.forward();
      setState(() {
        patternFinished = true;
      });
    }
  }
}

class NavigationUtil extends StatefulWidget {
  NavigationUtil({Key key}) : super(key: key);

  @override
  _NavigationUtilState createState() => _NavigationUtilState();
}

class _NavigationUtilState extends State<NavigationUtil> {
  @override
  void initState() {
    startTimer();
    super.initState();
  }

  startTimer() {
    return Timer(Duration(seconds: 1), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => FolderView()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "LOGGED IN",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: accentColor,
        fontSize: 30.0,
      ),
    );
  }
}
