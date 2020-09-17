import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photonix_app/pages/login_page.dart';
import 'package:photonix_app/pages/signup_page.dart';
import 'package:photonix_app/styles/colors.dart';
import 'package:photonix_app/widgets/rounded_button.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 5));
    _controller.repeat(reverse: true);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 200.0,
                padding: EdgeInsets.only(top: height / 20),
                child: SvgPicture.asset(
                  'assets/images/smartphone.svg',
                  color: Theme.of(context).accentColor,
                ),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ShaderMask(
                child: Text(
                  'WELCOME TO\nPHOTONIX',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: height / 20,
                      fontWeight: FontWeight.bold),
                ),
                shaderCallback: (rect) {
                  return LinearGradient(stops: [
                    _animation.value - 0.2,
                    _animation.value,
                    _animation.value + 0.2
                  ], colors: [
                    firstColor,
                    darkColor,
                    Colors.white,
                  ]).createShader(rect);
                },
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.all(height / 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RoundedButton(
                  text: "GET STARTED",
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderColor: Theme.of(context).accentColor,
                  textColor: Theme.of(context).accentColor,
                  onPress: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignupPage()));
                  },
                ),
                SizedBox(
                  height: height / 60,
                ),
                RoundedButton(
                  text: "LOGIN",
                  color: Theme.of(context).accentColor,
                  borderColor: Theme.of(context).accentColor,
                  textColor: Theme.of(context).scaffoldBackgroundColor,
                  onPress: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                )
              ],
            ),
          )
        ],
      ),
    ));
  }
}
