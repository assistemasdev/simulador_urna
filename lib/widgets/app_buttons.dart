import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  static const Color COR_NUMERO = Color(0xFFEFEFEF);
  static const Color COR_BRANCO = Colors.white;
  static const Color COR_CORRIGE = Color(0xFFFF6C00);
  static const Color COR_CONFIRMA = Color(0xFF00A859);

  final String text;
  final void Function(String) cb;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final double width;
  final double height;

  // Tecla numérica
  Button({this.text, this.cb})
      : backgroundColor = COR_NUMERO,
        textColor = Colors.black,
        fontSize = 32,
        width = 74,
        height = 64;

  // BRANCO
  Button.white({this.text, this.cb})
      : backgroundColor = COR_BRANCO,
        textColor = Colors.black,
        fontSize = 14,
        width = 118,
        height = 54;

  // CORRIGE
  Button.orange({this.text, this.cb})
      : backgroundColor = COR_CORRIGE,
        textColor = Colors.white,
        fontSize = 14,
        width = 118,
        height = 54;

  // CONFIRMA
  Button.green({this.text, this.cb})
      : backgroundColor = COR_CONFIRMA,
        textColor = Colors.white,
        fontSize = 14,
        width = 118,
        height = 54;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.all(4),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        elevation: 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => cb(text),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}