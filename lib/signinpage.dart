import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trovami/helpers/RoutesHelper.dart';
import 'package:trovami/httpClient/httpClient.dart';
//import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'InputTextField.dart';
import 'Roundedbutton.dart';
import 'Strings.dart';
import 'main.dart';
import 'core/OldUser.dart';
import 'signuppage.dart';
import 'homepage.dart';
import 'functionsForFirebaseApiCalls.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:crypt/crypt.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'managers/UsersManager.dart';
import 'core/OldUser.dart';
import 'phoneNumber.dart';

final googleSignIn = new GoogleSignIn();
String loggedinUser;
var loggedInUsername;
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

final FirebaseAuth auth = FirebaseAuth.instance;


TextStyle textStyle = new TextStyle(
    color: const Color.fromRGBO(255, 255, 255, 0.4), //doesnt make a diff
    fontSize: 16.0,
    fontWeight: FontWeight.normal);

Color textFieldColor = const Color.fromRGBO(0, 0, 0, 0.7); //doesnt make a diff
ScrollController scrollController = new ScrollController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initializing the firebase app
  await Firebase.initializeApp();
  googleSignIn.signOut();
  auth.signOut();
  // calling of runApp
  runApp(SignInForm());
}
class SignInForm extends StatefulWidget {
  @override
  SigninFormState createState() => new SigninFormState();
}

// ignore: mixin_inherits_from_not_object
class SigninFormState extends State<SignInForm>
    with SingleTickerProviderStateMixin {
  bool _isgooglesigincomplete = true;
  bool _first = true;
//  var httpClient = HttpClientFireBase();

  final IconData mail = const IconData(0xe158, fontFamily: 'MaterialIcons');
  final IconData lock_outline =
      const IconData(0xe899, fontFamily: 'MaterialIcons');
  final IconData signinicon =
      const IconData(0xe315, fontFamily: 'MaterialIcons');
  final IconData signupicon =
      const IconData(0xe316, fontFamily: 'MaterialIcons');
  bool _autovalidate = false;
  bool _formWasEdited = false;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey =
      new GlobalKey<FormFieldState<String>>();
  Animation<Color> animation;
  AnimationController controller;

  String email = '';
  String password = '';

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }


  _handleSubmitted1() async {
    print("Inside handlesubmitted1");
    setState(() {
      _isgooglesigincomplete = false;
    });
    
    
  }


  _handleSubmitted() async {
    

    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true;
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      final DataSnapshot usrmap = await getUsers();
      Map usrs = usrmap.value as Map;

      usrs.values.forEach((us) async {
        final decrypt=Crypt(us["password"]);
        // if (decrypt.match(password)) {
        //   print('Matches');
        // }
        if (email == us["emailid"] && decrypt.match(password)) {

          print("Loged In");
          loggedinUser = email;
          loggedInUsername = us["name"];
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Homepagelayout(users: usrmap),
            ),
          );
        }

      });
      showInSnackBar(
          'Login EmailID or Password is incorrect. Please Try again.');
    }
  }

  String _validateName(String value) {
    _formWasEdited = true;
    if (value.isEmpty) return 'EmailID is required.';
    return null;
    final nameExp = new RegExp(r'^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$');
    if (!nameExp.hasMatch(value)) return 'Please enter correct EmailID';
    return null;
  }

  setGoogleSigninListener() {
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount account) async {
    });
    _googleSignIn.signInSilently();
  }

  @override
  void initState() {
    setGoogleSigninListener();

    controller = new AnimationController(
        duration: const Duration(seconds: 10), vsync: this);
    animation =
        new ColorTween(begin: Colors.red, end: Colors.blue).animate(controller)
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return new Scaffold(
      key: _scaffoldKey,
      body: new SingleChildScrollView(
        controller: scrollController,
        child: new Container(

          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('assets/back.jpg'),
              fit: BoxFit.cover,
              alignment: Alignment.topLeft,
            ),
          ),
          child: new Column(
            children: <Widget>[
              new Container(
                height: screenSize.height / 4,
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      child: new Text(
                        Strings.appName,
                        textAlign: TextAlign.center,
                        style: new TextStyle(fontSize: 50.0),
                      ),
                    ),
                  ],
                ),
              ),
              new Container(
                height: 3 * screenSize.height / 4,
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Form(
                      key: _formKey,
                      autovalidate: _autovalidate,
                      child: new Column(
                        children: <Widget>[
                          new Container(

                            child: new InputField(
                                hintText: 'Email',
                                obscureText: false,
                                textInputType: TextInputType.text,
                                textStyle: textStyle,
                                hintStyle: textStyle,
                                textFieldColor: textFieldColor,
                                icon: Icons.mail_outline,
                                iconColor:
                                    const Color.fromRGBO(255, 255, 255, 0.4), //no diff
                                bottomMargin: 20.0,
                                validateFunction: _validateName,
                                onSaved: (String value) {
                                  email = value;
                                }),
                          ),
                          new InputField(
                              hintText: 'Password',
                              obscureText: true,
                              textInputType: TextInputType.text,
                              textStyle: textStyle,
                              hintStyle: textStyle,
                              textFieldColor: textFieldColor,
                              icon: Icons.lock_outline,
                              iconColor: Colors.white,
                              bottomMargin: 20.0,
                              onSaved: (String value) {
                                password = value;
                              }),
                        ],
                      ),
                    ),
                    new Column(

                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new RoundedButton(
                          buttonName: 'Sign-In',
                          onTap: _handleSubmitted,
                          width: screenSize.width,
                          height: 50.0,
                          bottomMargin: 10.0,
                          borderWidth: 0.0,
                          buttonColor: const Color.fromRGBO(25, 186, 255, 1.0),//made a diff
                        ),
                        new RoundedButton(
                          buttonName: 'Sign-up',
                          onTap: () {
                            RoutesHelper.pushRoute(context, ROUTE_SIGNUP);
                          },
                          highlightColor:
                              const Color.fromRGBO(255, 255, 255, 0.1),
                          width: screenSize.width,
                          height: 50.0,
                          bottomMargin: 10.0,
                          borderWidth: 0.0,
                          buttonColor: const Color.fromRGBO(12, 143, 199, 1.0), //made a diff
                        ),

                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: MaterialButton(
                    onPressed: () {
                      signup(context);
                    },
                    color: Colors.teal[100],
                    elevation: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 30.0,
                          width: 30.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image:
                                AssetImage('assets/google-logo.jpg'),
                                fit: BoxFit.cover),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text("Sign In with Google")
                      ],

                    ),
                  )
                )



                  ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signup(BuildContext context) async {
    googleSignIn.signOut();
    auth.signOut();
    // final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      // Getting users credential
      UserCredential result = await auth.signInWithCredential(authCredential);
      User user = result.user;

      if (result != null) {
        print("Logged in using google");

        loggedinUser = user.email;
        loggedInUsername = user.displayName;
        final DataSnapshot usrmap = await getUsers();
        OldUser user1 = new OldUser();
        var phoneNumberExists = false;
        user1.EmailId=loggedinUser;
        user1.name=loggedInUsername;
        user1.password="SignInViaGoogle";
        user1.phoneNumber = user.phoneNumber;
        //user1.phoneNumber="";
        user1.location = null;
        user1.locationShare = false;
        user1.groupsIamin = [];
        UsersManager().users.putIfAbsent(user1.EmailId, () => user1);
        var userjson = jsonCodec.encode(user1);
        //print("Janvi");
        // print(user1.password);
        final c1 = Crypt.sha256(user1.password);
        // print(c1);
        print("userjson:${userjson}"); // works
        //final DataSnapshot usrmap = await getUsers();
        Map usrs = usrmap.value as Map;
        print("usrmap:${usrs.values}");

        //usrs.values.forEach((x){print(x["emailid"]);});
        usrs.values.forEach((x) {
          if (x["emailid"] == user1.EmailId) {
            userexists = true;
            if(x["phoneNumber"]==null ||x["phoneNumber"]==""){
               phoneNumberExists = false;
            }
            else{
              phoneNumberExists = true;
            }
          }
        });
        //var userexists = false;
        if (userexists == false) {
          //print("IN HTTP POST CONDITION");
          HttpClientFireBase httpClient = HttpClientFireBase();
          print(userjson);
          await httpClient.post(url: 'https://pallocator-8fe3e.firebaseio.com/users.json', body: userjson);
          await Future.delayed(Duration(seconds: 5));
          if(user1.phoneNumber==null ||user1.phoneNumber ==""){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PhoneNumberLayout(emailId: loggedinUser),
              ),
            );
          }
          else{
            final DataSnapshot usrmap_withNewAccount = await getUsers();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Homepagelayout(users: usrmap_withNewAccount),
              ),
            );
          }
        } else {
          // print("IN ELSE CONDITION");
          if(!phoneNumberExists){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PhoneNumberLayout(emailId: loggedinUser),
              ),
            );
          }
          else{
            await Future.delayed(Duration(seconds: 2));
            final DataSnapshot usrmap_withNewAccount = await getUsers();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Homepagelayout(users: usrmap_withNewAccount),
              ),
            );
          }
          print('User already exits');
        }

      //   Navigator.pushReplacement(
      //       //context, MaterialPageRoute(builder: (context) => HomePage()));
       }  // if result not null we simply call the MaterialpageRoute,
      // for go to the HomePage screen
    }
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
