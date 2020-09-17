import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final Color color, textColor, borderColor;
  final String text;
  final Function onPress;

  RoundedButton(
      {this.color, this.text, this.onPress, this.textColor, this.borderColor});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.8,
      child: FlatButton(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 40),
        onPressed: onPress,
        color: color,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: borderColor)),
        child: Text(
          text,
          style: TextStyle(
              fontSize: size.height / 45,
              color: textColor,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
