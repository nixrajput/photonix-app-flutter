import 'package:flutter/material.dart';

class InputDropdown extends StatelessWidget {
  const InputDropdown(
      {Key key, this.child, this.labelText, this.valueText, this.onPressed})
      : super(key: key);

  final String labelText;
  final String valueText;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return new InkWell(
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: height / 45,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                valueText,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.arrow_drop_down, color: Theme.of(context).accentColor),
            ],
          ),
        ),
      ),
    );
  }
}
