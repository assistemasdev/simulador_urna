import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  static const DEFAULT = Colors.black;
  static const NUM = Colors.white;
  static const NUMOP = Colors.black;
  static const ACTION = Colors.black;
  static const WHITE = Colors.white;
  static const ORANGE = Colors.deepOrange;
  static const GREEN = Colors.green;

  final String text;
  final void Function(String) cb;
  final Color color;
  final Color textColor;
  final double fontSize;
  final double minWidth;
  final double height;
  final EdgeInsets padding;

  Button(
      {@required this.text,
      @required this.cb,
      this.color = DEFAULT,
      this.textColor = NUM,
      this.fontSize = 50,
      this.minWidth = 110,
      this.height = 90,
      this.padding = const EdgeInsets.all(8.0)});

  Button.white(
      {@required this.text,
      @required this.cb,
      this.color = WHITE,
      this.textColor = ACTION,
      this.fontSize = 20,
      this.minWidth = 110,
      this.height = 70,
      this.padding = const EdgeInsets.fromLTRB(8, 22, 8, 0)});

  Button.orange(
      {@required this.text,
      @required this.cb,
      this.color = ORANGE,
      this.textColor = ACTION,
      this.fontSize = 20,
      this.minWidth = 110,
      this.height = 70,
      this.padding = const EdgeInsets.fromLTRB(8, 22, 8, 0)});

  Button.green(
      {@required this.text,
      @required this.cb,
      this.color = GREEN,
      this.textColor = ACTION,
      this.fontSize = 20,
      this.minWidth = 110,
      this.height = 90,
      this.padding = const EdgeInsets.all(8.0)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: this.padding,
      child: ButtonTheme(
        minWidth: minWidth,
        height: height,
        child: RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 15,
          onPressed: () => cb(text),
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize),
          ),
          textColor: this.textColor,
          color: this.color,
        ),
      ),
    );
  }
}
