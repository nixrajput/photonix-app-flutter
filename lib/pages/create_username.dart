import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photonix_app/styles/colors.dart';

class CreateUsername extends StatefulWidget {
  @override
  _CreateUsernameState createState() => _CreateUsernameState();
}

class _CreateUsernameState extends State<CreateUsername> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String _username;

  String _validateUsername(String value) {
    if (value.isEmpty) {
      return "Username is required!";
    }

    if (value.length < 5) {
      return "Username must be more than 5 characters!";
    }

    if (value.length > 15) {
      return "Username must be less than 15 characters!";
    }

    return null;
  }

  validateAndSubmit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      SnackBar snackBar = SnackBar(content: Text("Welcome " + _username));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 1), () {
        Navigator.pop(context, _username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: SingleChildScrollView(
              child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0,
                                left: 16.0,
                                right: 16.0,
                                bottom: 16.0),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Icon(
                                            FontAwesomeIcons.arrowAltCircleLeft,
                                            color:
                                                Theme.of(context).accentColor))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                            child: Padding(
                          padding: EdgeInsets.only(top: height / 20),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32.0),
                                child: Container(
                                  child: Text(
                                    "Create Your Username",
                                    style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                        fontSize: height / 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: height / 5,
                              ),
                              Container(
                                margin: EdgeInsets.all(16.0),
                                child: Form(
                                  key: _formKey,
                                  autovalidate: _autoValidate,
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: <Widget>[
                                      createInputs(),
                                      createButtons(),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ))
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )),
        ));
  }

  Widget createInputs() {
    double height = MediaQuery.of(context).size.height;
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 16.0,
          ),
          TextFormField(
            maxLines: 1,
            keyboardType: TextInputType.emailAddress,
            autofocus: false,
            decoration: InputDecoration(
                labelText: "Username",
                labelStyle: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontSize: height / 45,
                    fontWeight: FontWeight.bold),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).accentColor)),
                border: OutlineInputBorder()),
            validator: _validateUsername,
            onSaved: (value) => _username = value.trim(),
          ),
          SizedBox(
            height: 32.0,
          ),
        ],
      ),
    );
  }

  Widget createButtons() {
    double height = MediaQuery.of(context).size.height;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 48.0,
          ),
          RaisedButton(
            padding: EdgeInsets.symmetric(vertical: height / 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            onPressed: validateAndSubmit,
            color: secondColor,
            child: Text(
              "CONTINUE",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: height / 45,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
