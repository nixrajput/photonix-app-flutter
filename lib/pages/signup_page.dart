import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photonix_app/model/Authentication.dart';
import 'package:photonix_app/pages/login_page.dart';
import 'package:photonix_app/widgets/rounded_button.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  Auth auth = Auth();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _email;
  String _password;
  String _name;
  bool _isLoading;
  bool _autoValidate = false;

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

  validateAndSubmit() async {
    setState(() {
      _isLoading = true;
    });

    if (validateAndSave()) {
      String userId = "";

      userId = await auth.signUpUser(_email, _password).catchError((err) {
        var e = err;
        var authError = "";
        print("Caught Error ${e.code}");
        switch (e.code) {
          case 'ERROR_EMAIL_ALREADY_IN_USE':
            authError = 'Email is already in use on different account.';
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

      if (userId != null) {
        UserUpdateInfo updateInfo = UserUpdateInfo();
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        updateInfo.displayName = _name;
        user.updateProfile(updateInfo);
        auth.sendEmailVerification();
        showVerifyEmailSentDialog();
        print("User Registered Successfully: $userId");
        setState(() {
          _isLoading = false;
          _formKey.currentState.reset();
        });
      }
    }
  }

  void showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content:
              new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                _formKey.currentState.reset();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void moveToLogin() {
    _formKey.currentState.reset();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
  }

  void showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Error"),
          content: new Text("Error occured during signup, please try again"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _validateName(String value) {
    if (value.isEmpty) {
      return "Name is required!";
    }

    if (value.length > 20) {
      return "Name should be less than 20 characters!";
    }

    return null;
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
      return "Password should be more than 8 characters!";
    }

    return null;
  }

  @override
  void initState() {
    _isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: buildAppBar(),
        body: _isLoading ? showCircularProgress() : signUpScreen());
  }

  AppBar buildAppBar() {
    return AppBar(
      elevation: 0.0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).accentColor),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      /*title: Text(
        _countryName,
        style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor),
      ),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: SvgPicture.asset("assets/icons/search.svg"),
          onPressed: searchCountry,
        ),
      ],*/
    );
  }

  Widget signUpScreen() {
    double height = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: height / 30,
          ),
          Container(
            child: Center(
              child: Text(
                "Sign Up To Photonix",
                style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontSize: height / 30,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            height: height / 10,
          ),
          Column(
            children: <Widget>[
              Form(
                key: _formKey,
                autovalidate: _autoValidate,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      maxLines: 1,
                      autofocus: false,
                      style: TextStyle(color: Theme.of(context).accentColor),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person_outline,
                            color: Theme.of(context).accentColor),
                        labelText: "Name",
                        labelStyle: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).accentColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).accentColor)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.red)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.red)),
                      ),
                      validator: _validateName,
                      onSaved: (value) => _name = value.trim(),
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    TextFormField(
                      style: TextStyle(color: Theme.of(context).accentColor),
                      maxLines: 1,
                      keyboardType: TextInputType.emailAddress,
                      autofocus: false,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.mail_outline,
                            color: Theme.of(context).accentColor),
                        labelText: "Email",
                        labelStyle: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).accentColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).accentColor)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.red)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.red)),
                      ),
                      validator: _validateEmail,
                      onSaved: (value) => _email = value.trim(),
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    TextFormField(
                      style: TextStyle(color: Theme.of(context).accentColor),
                      maxLines: 1,
                      autofocus: false,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline,
                            color: Theme.of(context).accentColor),
                        labelText: "Password",
                        labelStyle: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).accentColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).accentColor)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.red)),
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
            ],
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
                              "Already Registered? ",
                              style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontSize: height / 60,
                                  fontWeight: FontWeight.bold),
                            ),
                            InkWell(
                              onTap: moveToLogin,
                              child: Text(
                                "LOG IN",
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
                  ],
                ),
                SizedBox(
                  height: height / 40,
                ),
                Container(
                    child:
                        Text("By Signing Up, You agree to our User Agreement, "
                            "Privacy Policy and Content Policy.")),
                SizedBox(
                  height: height / 40,
                ),
                RoundedButton(
                  text: "SIGN UP",
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderColor: Theme.of(context).accentColor,
                  textColor: Theme.of(context).accentColor,
                  onPress: _isLoading ? null : validateAndSubmit,
                )
              ],
            ),
          )
        ],
      ),
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
