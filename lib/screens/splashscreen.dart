import 'package:file_lock/home_page.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

class SplashScreenView extends StatefulWidget {
  @override
  _SplashScreenViewState createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      loaderColor: Colors.white,
      useLoader: true,
      seconds: 2,
      backgroundColor: Colors.blue,
      navigateAfterSeconds: HomePage(),
      title: new Text('<S>',style: TextStyle(color:Colors.white,fontSize: 90.0,fontWeight: FontWeight.bold),),
    );
  }
}