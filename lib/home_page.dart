import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'createPattern.dart';
import 'login.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          SharedPreferences preferences = snapshot.data;
          List<String> pattern = preferences.getStringList("pattern");
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              else {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ButtonTheme(
                      minWidth: MediaQuery.of(context).size.width * 0.8,
                      height: 60.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0)),
                      child: pattern == null
                          ? ElevatedButton(
                              child: Text(
                                'Create Pattern',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20.0),
                              ),
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CreatePattern())),
                            )
                          : ElevatedButton(
                              child: Text(
                                'Login',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20.0),
                              ),
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Login())),
                            ),
                    ),
                  ),
                );
              }
          }
        },
      ),
    );
  }
}
