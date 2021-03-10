import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_lock/login.dart';
import 'themes.dart';
import 'triangle.dart';
import 'circle.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ShapeState { Blank, Circle, Rectangle, Triangle }

class CreatePattern extends StatefulWidget {
  @override
  _CreatePatternState createState() => _CreatePatternState();
}

class _CreatePatternState extends State<CreatePattern>
    with TickerProviderStateMixin {
  var activeShape = ShapeState.Circle;
  var shapeState = ShapeState.Blank;
  var boardState = List<List<ShapeState>>.generate(
      6, (i) => List<ShapeState>.generate(6, (j) => ShapeState.Blank));

  Animation<double> _boardAnimation;
  AnimationController _boardController;
  double _boardOpacity = 1.0;
  bool patternFinished = false, enableReset = false;
  String message = "Enter Pattern";
  int _moveCount = 0, setPatternCounter = 0;
  // List<List<int>> correctPatternMatrix = [
  //       [0, 0],
  //       [1, 1],
  //       [2, 2]
  //     ];
  List<String> firstPatternMatrix = [], confirmPatternMatrix = [];

  @override
  void initState() {
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
    // getPattern();
  }

  // getPattern() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   List<String> foo = prefs.getStringList("pattern");
  //   if (foo == null) {
  //     savePattern();
  //   } else {
  //     print("pattern from prefs - $foo");
  //     setState(() {
  //       correctPatternMatrix = foo;
  //     });
  //   }
  // }

  // removePattern() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.remove("pattern");
  //   print("removed pattern");
  // }

  @override
  void dispose() {
    _boardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              shapeContainer,
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10),
                child: Text(
                    "Please set a pattern with the above three shapes and make sure to remember the order of the shapes, as any mismatch in the order will ultimately cause your login to fail.",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        fontSize: 16)),
              ),
              Stack(
                children: <Widget>[board, shapeStateDisplay],
              ),
              Text(message),
              bottomBar,
            ],
          )),
    );
  }

  Widget get shapeContainer => Container(
        height: 89,
        // color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _moveCount == 0
              ? [circle, buildRectangle(), buildTriangle()]
              : (_moveCount == 1
                  ? [buildRectangle(), buildTriangle()]
                  : (_moveCount == 2 ? [buildTriangle()] : [Container()])),
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
                  eq(firstPatternMatrix, confirmPatternMatrix)
                      ? NavigationHelper(confirmPatternMatrix)
                      : Builder(builder: (context) {
                          return Text(
                            "PATTERNS DOESN'T MATCH",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                              fontSize: 20.0,
                            ),
                          );
                        })
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FloatingActionButton(
              heroTag: 'back',
              child: Icon(Icons.arrow_back),
              backgroundColor: accentColor,
              mini: true,
              onPressed: () => Navigator.pop(context),
            ),
            // Container(
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(50.0),
            //     border: Border.all(color: Colors.grey[300]),
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Text(
            //       '2 Players',
            //       style: TextStyle(
            //         fontSize: 14.0,
            //         color: accentColor,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),
            FloatingActionButton(
              heroTag: 'reset',
              child: Icon(Icons.cached),
              backgroundColor: accentColor,
              mini: true,
              onPressed: enableReset ? () => reset() : null,
            ),
          ],
        ),
      );

  Widget gameButton(int row, int col) {
    return Visibility(
      visible: !patternFinished,
      child: GestureDetector(
        onTap: (boardState[row][col] == ShapeState.Blank &&
                shapeState == ShapeState.Blank)
            ? () {
                _moveCount++;
                boardState[row][col] = activeShape;
                checkWinningCondition(row, col, activeShape);
                toggleActiveShape();
              }
            : null,
        child: Container(
          color: Colors.white,
          child: Center(
            child: shapePiece(row, col),
          ),
        ),
      ),
    );
  }

  void toggleActiveShape() {
    if (activeShape == ShapeState.Circle)
      activeShape = ShapeState.Rectangle;
    else if (activeShape == ShapeState.Rectangle)
      activeShape = ShapeState.Triangle;
    else
      activeShape = ShapeState.Circle;
    print("activeshape in toggle is $activeShape");
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
    setState(() {
      _moveCount = 0;

      patternFinished = false;
      firstPatternMatrix = confirmPatternMatrix = [];
    });
    _boardController.reverse();
  }

  void checkWinningCondition(int row, int col, ShapeState shapeState) {
    setState(() {
      if (setPatternCounter == 0) {
        setState(() {
          firstPatternMatrix.add(row.toString());
          firstPatternMatrix.add(col.toString());
          print("in setstate fpm - $firstPatternMatrix");
        });
      } else if ((setPatternCounter == 1)) {
        setState(() {
          confirmPatternMatrix.add(row.toString());
          confirmPatternMatrix.add(col.toString());
          print("in setstate cfm - $confirmPatternMatrix");
        });
      }
      if (_moveCount == 3) {
        print("initally spc - $setPatternCounter");
        setPatternCounter++;
        print("spc set to - $setPatternCounter");
        if (setPatternCounter == 1) {
          message = "Confirm Pattern";
          partialReset();
        }
      }

      if (_moveCount == 3 && confirmPatternMatrix.length == 6) {
        message = "";
        toggleBoardOpacity();
        enableReset = true;
      }
    });
  }

  partialReset() {
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 6; j++) {
        boardState[i][j] = ShapeState.Blank;
      }
    }

    shapeState = ShapeState.Blank;
    setState(() {
      _moveCount = 0;
    });

    _boardController.reverse();
  }

  void toggleBoardOpacity() {
    print("triggered");
    if (_boardOpacity == 0.0) {
      setState(() {
        patternFinished = false;
      });
      _boardController.reverse();
    } else if (_boardOpacity == 1.0) {
      _boardController.forward();
      setState(() {
        patternFinished = true;
        print("set to true");
      });
    }
  }
}

class NavigationHelper extends StatefulWidget {
  final List<String> pattern;
  NavigationHelper(this.pattern);

  @override
  _NavigationHelperState createState() => _NavigationHelperState();
}

class _NavigationHelperState extends State<NavigationHelper> {
  @override
  void initState() {
    startTimer();
    super.initState();
  }

  startTimer() {
    return Timer(Duration(seconds: 1), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList('pattern', widget.pattern);
      print("saved to shared prefs");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "PATTERN SET SUCCESSFULLY",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: accentColor,
        fontSize: 20.0,
      ),
    );
  }
}
