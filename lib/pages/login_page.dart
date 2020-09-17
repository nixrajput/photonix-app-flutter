import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photonix_app/model/Authentication.dart';
import 'package:photonix_app/pages/home_page.dart';
import 'package:photonix_app/pages/signup_page.dart';
import 'package:photonix_app/widgets/rounded_button.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Auth auth = Auth();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _email;
  String _password;
  bool _isLoading;
  bool _obscureText = true;
  bool _autoValidate = false;

  @override
  void initState() {
    _isLoading = false;
    super.initState();
  }

  bool validateAndSave() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      return true;
    } else {
      _isLoading = false;
      setState(() {
        _autoValidate = true;
      });
      return false;
    }
  }

  void validateAndSubmit() async {
    setState(() {
      _isLoading = true;
    });

    if (validateAndSave()) {
      String userId = "";

      userId = await auth.signInUser(_email, _password).catchError((err) {
        var e = err;
        var authError = "";
        print("Caught Error ${e.code}");
        switch (e.code) {
          case "ERROR_WRONG_PASSWORD":
            authError = "Your password is wrong.";
            break;
          case "ERROR_USER_NOT_FOUND":
            authError = "User with this email doesn't exist.";
            break;
          case "ERROR_USER_DISABLED":
            authError = "User with this email has been disabled.";
            break;
          case "ERROR_TOO_MANY_REQUESTS":
            authError = "Too many requests. Try again later.";
            break;
          case "ERROR_OPERATION_NOT_ALLOWED":
            authError = "Signing in with Email and Password is not enabled.";
            break;
          case "ERROR_NETWORK_REQUEST_FAILED":
            authError = "Network error. Connect to internet.";
            break;
          default:
            authError = 'An undefined Error happened.';
            break;
        }
        setState(() {
          _isLoading = false;
        });
        SnackBar snackBar = SnackBar(content: Text(authError));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      });

      setState(() {
        _isLoading = false;
      });

      if (userId != null) {
        print("Logged In Successfully: $userId");
        moveToHomePage();
      }
    }
  }

  moveToHomePage() {
    _formKey.currentState.reset();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => HomePage()));
  }

  moveToRegister() {
    _formKey.currentState.reset();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => SignupPage()));
  }

  void toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String _validateEmail(String value) {
    if (value.isEmpty) {
      return "Email is required!";
    }

    String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
        "\\@" +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
        "(" +
        "\\." +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
        ")+";
    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(value)) {
      return null;
    }

    return "Email is not valid!";
  }

  String _validatePassword(String value) {
    if (value.isEmpty) {
      return "Password is required!";
    }

    if (value.length < 8) {
      return "Password must be more than 8 characters!";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: _isLoading ? showCircularProgress() : signInScreen(),
      ),
    );
  }

  Widget signInScreen() {
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: height / 50, vertical: height / 50),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(FontAwesomeIcons.arrowAltCircleLeft,
                          color: Theme.of(context).accentColor)),
                ],
              ),
              SizedBox(
                height: height / 10,
              ),
              Center(
                child: Text(
                  "Sign In To Photonix",
                  style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: height / 30,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: height / 10,
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: height / 50, vertical: height / 20),
            decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0))),
            child: Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: height / 40,
                        ),
                        TextFormField(
                          style: TextStyle(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              fontSize: height / 45),
                          maxLines: 1,
                          keyboardType: TextInputType.emailAddress,
                          autofocus: false,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.mail_outline,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor),
                            labelText: "Email",
                            labelStyle: TextStyle(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                fontSize: height / 50,
                                fontWeight: FontWeight.bold),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.red)),
                          ),
                          validator: _validateEmail,
                          onSaved: (value) => _email = value.trim(),
                        ),
                        SizedBox(height: 40.0),
                        TextFormField(
                          maxLines: 1,
                          autofocus: false,
                          obscureText: _obscureText,
                          style: TextStyle(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              fontSize: height / 45),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor),
                            labelText: "Password",
                            labelStyle: TextStyle(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                fontSize: height / 50,
                                fontWeight: FontWeight.bold),
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor),
                              onPressed: toggle,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.red)),
                          ),
                          validator: _validatePassword,
                          onSaved: (value) => _password = value.trim(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      "New To Photonix? ",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          fontSize: height / 60,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    InkWell(
                                      onTap: moveToRegister,
                                      child: Text(
                                        "SIGN UP",
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: height / 60,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            InkWell(
                              onTap: () {},
                              child: Text(
                                "FORGOT PASSWORD",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: height / 60,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: height / 40,
                        ),
                        RoundedButton(
                          text: "LOG IN",
                          color: Theme.of(context).accentColor,
                          borderColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          textColor: Theme.of(context).scaffoldBackgroundColor,
                          onPress: _isLoading ? null : validateAndSubmit,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget showCircularProgress() {
    return Container(
      color: Theme.of(context).canvasColor,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor)),
      ),
    );
  }
}
