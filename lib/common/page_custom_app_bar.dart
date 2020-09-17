import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PageCustomAppBar extends StatelessWidget {
  final String title;

  PageCustomAppBar({this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                padding: EdgeInsets.only(left: 16.0),
                onPressed: () => Navigator.pop(context),
                icon: Icon(FontAwesomeIcons.arrowAltCircleLeft),
                color: Theme.of(context).accentColor,
              ),
              Container(
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 16.0),
                height: 0.0,
                width: 40.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
