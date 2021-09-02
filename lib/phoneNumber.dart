import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:trovami/httpClient/httpClient.dart';
import 'package:trovami/model/userModel.dart';

import 'Roundedbutton.dart';
import 'functionsForFirebaseApiCalls.dart';
import 'managers/UsersManager.dart';
import 'core/OldUser.dart';
import 'package:crypt/crypt.dart';
import 'homepage.dart';

//bool userexists = false;
OldUser user1 = new OldUser();
//const jsonCodec = const JsonCodec(reviver: _reviver);

_reviver(key, value) {
  if (key != null && value is Map && key.contains('-')) {
    return new OldUser.fromJson(value);
  }
  return value;
}

TextStyle textStyle = new TextStyle(color: const Color.fromRGBO(255, 255, 255, 0.4), fontSize: 16.0, fontWeight: FontWeight.bold);

class PhoneNumberLayout extends StatefulWidget {
  dynamic emailId;
  PhoneNumberLayout({this.emailId});
  @override
  PhoneNumberLayoutState createState() => new PhoneNumberLayoutState(emailId : emailId);
}

class PhoneNumberLayoutState extends State<PhoneNumberLayout> {
  dynamic emailId;
  PhoneNumberLayoutState({this.emailId});
  @override
  Widget build(BuildContext context) => defaultTargetPlatform == TargetPlatform.iOS
      ? new CupertinoPageScaffold(child: new PhoneNumber()
//        ,navigationBar: new CupertinoNavigationBar(middle: new Text("Sign-up"),backgroundColor:const Color.fromRGBO(0, 0, 0, 0.7),),
  )
      : new Scaffold(
    body: new Container(
      child: new PhoneNumber(emailId : emailId),
    ),
  );
}

class PhoneNumber extends StatefulWidget {
  dynamic emailId;
  PhoneNumber({this.emailId});
  @override
  PhoneNumberstate createState() => new PhoneNumberstate(emailId : emailId);
}

class PhoneNumberstate extends State<PhoneNumber> {
  dynamic emailId;
  PhoneNumberstate({this.emailId});
  final GlobalKey<ScaffoldState> _scaffoldKeySecondary = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKeySeondary = new GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKeySecondary = new GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _phoneFieldKeySecondary = new GlobalKey<FormFieldState<String>>();

  bool _autovalidate1 = false;
  bool _formWasEdited = false;

  final IconData mail = const IconData(0xe158, fontFamily: 'MaterialIcons');
  final IconData lock_outline = const IconData(0xe899, fontFamily: 'MaterialIcons');
  final IconData signupicon = const IconData(0xe316, fontFamily: 'MaterialIcons');
  var phoneNumber="";

  void showInSnackBar(String value) {
    _scaffoldKeySecondary.currentState.showSnackBar(new SnackBar(content: new Text(value)));
  }

  _handleSubmitted1() async {
    var httpClient = HttpClientFireBase();
    final DataSnapshot users = await getUsers();
    final FormState form = _formKeySeondary.currentState;
    form.save();
    print("PRINTING PHONE NUMBER NOW");
    print(phoneNumber);
    print(emailId);
    users.value.forEach((k, v) async {
      if (v["emailid"] == emailId) {

        print("v['groupsIamin'] : ${v["groupsIamin"]}");
        if (v["phoneNumber"] == null) {
          print("Phone number to be entered");
          // List<String> groupsIamin = [];
          // groupsIamin.add(GroupsManager().currentGroup().groupname);
          //var groupsIaminjson = jsonCodec.encode(groupsIamin);
          await httpClient.put(
              url: 'https://pallocator-8fe3e.firebaseio.com/users/${k}/phoneNumber.json?',
              body: phoneNumber);
          await Future.delayed(Duration(seconds: 5));
          final DataSnapshot usrmap_withNewAccount = await getUsers();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Homepagelayout(users: usrmap_withNewAccount),
            ),
          );
        } else {

        
        }
      }
    });
   
  }

  String _validateName(String value) {
    _formWasEdited = true;
    if (value.isEmpty) return 'EmailID is required.';
    return null;
    final RegExp nameExp = new RegExp(r'^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$');
    if (!nameExp.hasMatch(value)) return 'Please enter correct EmailID';
    return null;
  }

  String _validatePassword(String value) {
    _formWasEdited = true;
    final FormFieldState<String> passwordField1 = _passwordFieldKeySecondary.currentState;
    if (passwordField1.value == null || passwordField1.value.isEmpty) return 'Please choose a password.';
    if (passwordField1.value != value) return 'Passwords don\'t match';
    return null;
  }

  @override
  Widget build(BuildContext context) {

    final Size screenSize = MediaQuery.of(context).size;
    return new Scaffold(
      key: _scaffoldKeySecondary,
      body: new Container(
        child: new Form(
          key: _formKeySeondary,
          autovalidate: _autovalidate1,
          child: new ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: <Widget>[

              new Container(
                child: new Container(
                  child: new TextFormField(
                    key: _phoneFieldKeySecondary,
                    decoration: new InputDecoration(
                      hintText: 'Type your number here',
                      labelText: 'Phone number *',
                      icon: new Icon(lock_outline),
                    ),
                    obscureText: false,
                    onSaved: (String value) {
                      phoneNumber = value;
                      print("Inside Onsaved printing number");
                      print(phoneNumber);
                    },
                  ),
                  padding: const EdgeInsets.only(bottom: 15.0, top: 0.0, right: 20.0),
                ),
                padding: const EdgeInsets.only(top: 10.0),
              ),
              new Container(
                child: new Container(
                  padding: const EdgeInsets.only(bottom: 15.0, top: 0.0, right: 20.0),
                ),
                padding: const EdgeInsets.only(top: 10.0),
              ),
              new Container(

                padding: const EdgeInsets.only(top: 10.0),
              ),
              Consumer<UserModel>(builder: (context, user, child) {
                return RoundedButton(
                  buttonName: 'Submit',
                  onTap: _handleSubmitted1,
                  //onTap: (){
                  //  user.signUp(user1);
                  //},
                  width: screenSize.width,
                  height: 50.0,
                  bottomMargin: 10.0,
                  borderWidth: 0.0,
                  buttonColor: Colors.blue[800],
                );
              }),
              new Container(
                padding: const EdgeInsets.only(top: 20.0),
                child: new Text('* indicates required field', style: Theme.of(context).textTheme.caption),
              ),
            ],
          ),
        ),
        padding: const EdgeInsets.only(top: 50.0),
      ),
      backgroundColor: const Color.fromRGBO(255, 255, 255, 0.7),
    );
  }
}
