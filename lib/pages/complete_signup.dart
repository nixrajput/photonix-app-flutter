import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photonix_app/common/custom_date_chooser.dart';
import 'package:photonix_app/model/Authentication.dart';
import 'package:photonix_app/model/DatabaseService.dart';
import 'package:photonix_app/pages/home_page.dart';
import 'package:photonix_app/styles/colors.dart';

class CompleteSignup extends StatefulWidget {
  final AuthImplementation auth;
  final String userId;

  CompleteSignup({Key key, this.auth, this.userId}) : super(key: key);

  @override
  _CompleteSignupState createState() => _CompleteSignupState();
}

class _CompleteSignupState extends State<CompleteSignup> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading;
  bool _autoValidate = false;
  String _dob = "Select Birthday";

  List<String> _sex = <String>['Select Sex', 'Male', 'Female', 'Others'];
  String _selectedSex = 'Select Sex';

  List<String> _country = <String>[
    'Select Country',
    'India',
    'Afghanistan',
    'Albania',
    'Algeria',
    'Andorra',
    'Angola',
    'Antigua & Deps',
    'Argentina',
    'Armenia',
    'Australia',
    'Austria',
    'Azerbaijan',
    'Bahamas',
    'Bahrain',
    'Bangladesh',
    'Barbados',
    'Belarus',
    'Belgium',
    'Belize',
    'Benin',
    'Bhutan',
    'Bolivia',
    'Bosnia Herzegovina',
    'Botswana',
    'Brazil',
    'Brunei',
    'Bulgaria',
    'Burkina',
    'Burundi',
    'Cambodia',
    'Cameroon',
    'Canada',
    'Cape Verde',
    'Central African Rep',
    'Chad',
    'Chile',
    'China',
    'Colombia',
    'Comoros',
    'Congo',
    'Congo {Democratic Rep}',
    'Costa Rica',
    'Croatia',
    'Cuba',
    'Cyprus',
    'Czech Republic',
    'Denmark',
    'Djibouti',
    'Dominica',
    'Dominican Republic',
    'East Timor',
    'Ecuador',
    'Egypt',
    'El Salvador',
    'Equatorial Guinea',
    'Eritrea',
    'Estonia',
    'Ethiopia',
    'Fiji',
    'Finland',
    'France',
    'Gabon',
    'Gambia',
    'Georgia',
    'Germany',
    'Ghana',
    'Greece',
    'Grenada',
    'Guatemala',
    'Guinea',
    'Guinea-Bissau',
    'Guyana',
    'Haiti',
    'Honduras',
    'Hungary',
    'Iceland',
    'Indonesia',
    'Iran',
    'Iraq',
    'Ireland {Republic}',
    'Israel',
    'Italy',
    'Ivory Coast',
    'Jamaica',
    'Japan',
    'Jordan',
    'Kazakhstan',
    'Kenya',
    'Kiribati',
    'Korea North',
    'Korea South',
    'Kosovo',
    'Kuwait',
    'Kyrgyzstan',
    'Laos',
    'Latvia',
    'Lebanon',
    'Lesotho',
    'Liberia',
    'Libya',
    'Liechtenstein',
    'Lithuania',
    'Luxembourg',
    'Macedonia',
    'Madagascar',
    'Malawi',
    'Malaysia',
    'Maldives',
    'Mali',
    'Malta',
    'Marshall Islands',
    'Mauritania',
    'Mauritius',
    'Mexico',
    'Micronesia',
    'Moldova',
    'Monaco',
    'Mongolia',
    'Montenegro',
    'Morocco',
    'Mozambique',
    'Myanmar',
    'Namibia',
    'Nauru',
    'Nepal',
    'Netherlands',
    'New Zealand',
    'Nicaragua',
    'Niger',
    'Nigeria',
    'Norway',
    'Oman',
    'Pakistan',
    'Palau',
    'Panama',
    'Papua New Guinea',
    'Paraguay',
    'Peru',
    'Philippines',
    'Poland',
    'Portugal',
    'Qatar',
    'Romania',
    'Russian Federation',
    'Rwanda',
    'St Kitts & Nevis',
    'St Lucia',
    'Saint Vincent & the Grenadines',
    'Samoa',
    'San Marino',
    'Sao Tome & Principe',
    'Saudi Arabia',
    'Senegal',
    'Serbia',
    'Seychelles',
    'Sierra Leone',
    'Singapore',
    'Slovakia',
    'Slovenia',
    'Solomon Islands',
    'Somalia',
    'South Africa',
    'South Sudan',
    'Spain',
    'Sri Lanka',
    'Sudan',
    'Suriname',
    'Swaziland',
    'Sweden',
    'Switzerland',
    'Syria',
    'Taiwan',
    'Tajikistan',
    'Tanzania',
    'Thailand',
    'Togo',
    'Tonga',
    'Trinidad & Tobago',
    'Tunisia',
    'Turkey',
    'Turkmenistan',
    'Tuvalu',
    'Uganda',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Uruguay',
    'Uzbekistan',
    'Vanuatu',
    'Vatican City',
    'Venezuela',
    'Vietnam',
    'Yemen',
    'Zambia',
    'Zimbabwe',
  ];
  String _selectedCountry = 'Select Country';

  validateAndSubmit() async {
    setState(() {
      _isLoading = true;
    });

    if (_dob != "Select Birthday" &&
        _selectedSex != "Select Sex" &&
        _selectedCountry != "Select Country") {
      String userId = widget.userId;
      try {
        await DatabaseService(uid: userId)
            .completeSignupData(_dob, _selectedSex, _selectedCountry);
        print("Data Saved Successfully: $userId");
        moveToHomePage(userId);
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        print("Error = " + e.toString());
        setState(() {
          _isLoading = false;
          _formKey.currentState.reset();
        });
        showErrorDialog();
      }
    } else {
      setState(() {
        _isLoading = false;
        _formKey.currentState.reset();
      });
    }
    SnackBar snackBar = SnackBar(content: Text("Choose all fields correctly"));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  void initState() {
    _isLoading = false;
    super.initState();
  }

  void moveToHomePage(String userId) {
    _formKey.currentState.reset();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => HomePage()));
  }

  Future<Null> _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime(2000),
        firstDate: DateTime(1900),
        lastDate: DateTime(2010));
    if (picked != null) {
      setState(() {
        _dob = DateFormat.yMMMd().format(picked);
      });

    }
  }

  void showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Error"),
          content: new Text("Error occured, please try again"),
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
                                        child: Icon(Icons.arrow_back,
                                            color:
                                                Theme.of(context).accentColor))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: height / 20,
                        ),
                        Container(
                            child: Column(
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Container(
                                child: Text(
                                  "Setup Your Profile",
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: height / 30,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: height / 20,
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
                                    SizedBox(
                                      height: height / 10,
                                    ),
                                    createButtons(),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ))
                      ],
                    ),
                  ),
                ],
              ),
              showCircularProgress(),
            ],
          )),
        ));
  }

  Widget showCircularProgress() {
    if (_isLoading) {
      return Container(
        color: Theme.of(context).canvasColor,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(secondColor)),
        ),
      );
    }
    return Center();
  }

  Widget createInputs() {
    double height = MediaQuery.of(context).size.height;
    return Container(
      child: Column(
        children: <Widget>[
          InputDropdown(
            labelText: "Birthday",
            valueText: _dob,
            onPressed: _selectDate,
          ),
          SizedBox(
            height: height / 20,
          ),
          Container(
            padding: EdgeInsets.all(height / 45),
            height: height / 15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Color(0xFFE5E5E5),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButton(
                    isExpanded: true,
                    underline: SizedBox(),
                    icon: Icon(Icons.expand_more),
                    items: _sex
                        .map((value) => DropdownMenuItem(
                              child: Text(
                                value,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).accentColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              value: value,
                            ))
                        .toList(),
                    onChanged: (selectedGender) {
                      setState(() {
                        _selectedSex = selectedGender;
                      });
                    },
                    value: _selectedSex,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: height / 20,
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            height: height / 15,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Color(0xFFE5E5E5),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButton(
                    isExpanded: true,
                    underline: SizedBox(),
                    icon: Icon(Icons.expand_more),
                    items: _country
                        .map((value) => DropdownMenuItem(
                              child: Text(
                                value,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).accentColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              value: value,
                            ))
                        .toList(),
                    onChanged: (selectedRegion) {
                      setState(() {
                        _selectedCountry = selectedRegion;
                      });
                    },
                    value: _selectedCountry,
                  ),
                ),
              ],
            ),
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
          RaisedButton(
            padding: EdgeInsets.all(height / 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            onPressed: _isLoading ? null : validateAndSubmit,
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
