import 'package:file_lock/createPattern.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String emailId = "";

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
              ? () {
                  print(password + emailId);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CreatePattern()));
                }
              : null,
        );
      },
    );
  }
}
