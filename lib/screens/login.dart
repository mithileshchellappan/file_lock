import 'package:file_lock/createPattern.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String emailId = "";
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  String password = "";

  Widget build(context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            emailField(),
            passwordField(),
            Container(margin: EdgeInsets.only(top: 25.0)),
            submitButton(),
          ],
        ),
      ),
    );
  }

  Widget emailField() {
    return Builder(builder: (context) {
      return TextField(
        onChanged: (val) {
          setState(() {
            emailId = val;
          });
        },
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'youremail@example.com',
          labelText: 'Email Address',
        ),
      );
    });
  }

  Widget passwordField() {
    return Builder(
      builder: (
        context,
      ) {
        return TextField(
          onChanged: (val) {
            setState(() {
              password = val;
            });
          },
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'enter pass',
            labelText: 'pass',
          ),
        );
      },
    );
  }

  Widget submitButton() {
    return Builder(
      builder: (
        context,
      ) {
        return RaisedButton(
          child: Text('Login'),
          color: Colors.blue,
          onPressed: (password.isNotEmpty && emailId.isNotEmpty)
              ? () async {
                  print(password + emailId);
                  try {
                    await firebaseAuth.createUserWithEmailAndPassword(
                        email: emailId, password: password);
                    var box = Hive.box('creds');
                    box.put('email', emailId);
                    box.put('pass', password);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreatePattern()));
                    return "Signed up";
                  } on FirebaseAuthException catch (e) {
                    return e.message;
                  }
                }
              : null,
        );
      },
    );
  }
}
