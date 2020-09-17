import 'package:flutter/material.dart';

class Counter extends StatelessWidget {
  final int number;
  final String title;

  const Counter({
    Key key,
    this.number,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          "$number",
          style: TextStyle(
              fontSize: 20.0,
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 4.0,
        ),
        Text(
          title,
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
