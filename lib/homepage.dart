import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/services.dart';
import 'package:contacts_service/contacts_service.dart';
import 'UnitTests.dart';
import 'groupdetails.dart';
import 'helpers/RoutesHelper.dart';
import 'main.dart';
import 'core/Group.dart';
import 'core/OldUser.dart';
import 'signinpage.dart';
import 'functionsForFirebaseApiCalls.dart';
import 'package:http/http.dart' as http;
import 'httpClient/httpClient.dart';

var temp=[];
String pageName='';
var groupStatusGroupname='';
double animValue=0.0;
List<OldUser> membersToShow=new List<OldUser>();
List<String> groupNamesToShow=new List<String>();
List<Group> groupsToShow=new List<Group>();
Group grps=new Group();
const jsonCodec2=const JsonCodec();
List<OldUser> membersToShowHomepage=new List<OldUser>();
final groupref = FirebaseDatabase.instance.reference().child('groups');
final usrref = FirebaseDatabase.instance.reference().child('users');
//var _httpClient = createHttpClient();
const _jsonCodec=const JsonCodec(reviver: _reviver);
var reference;
List<String> groupIamIn=new List<String>();
List<String> inactiveGroups=new List<String>();


bool _first=true;

_reviver( key, value) {
  if(key!=null&& value is Map && key.contains('-')){
    return new OldUser.fromJson(value);
  }
  return value;
}

  class Homepagelayout extends StatelessWidget {
    dynamic users;
    Homepagelayout({this.users});
    @override
    Widget build(BuildContext context) {
      //rebuildAllChildren(context);
      final Size screenSize = MediaQuery
          .of(context)
          .size;

      return
        new Container(
            child: new Homepage(users:users),
            width: screenSize.width,
            height: screenSize.height,
          );
    }


  }
class groupBox extends StatelessWidget {
  groupBox({
    this.snapshot, this.animation,this.index
  });
  final DataSnapshot snapshot;
  final Animation animation;
  final int index;



  @override
  Widget build(BuildContext context) {
//    print(snapshot.value);
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
          parent: animation, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 16.0,bottom: 16.0),
              child: new CircleAvatar(child: new IconButton(
                  icon: new Icon(Icons.group), onPressed: null),
                backgroundColor: const Color.fromRGBO(0, 0, 0, 0.2),
              ),
            ),
            new FlatButton(onPressed: () {
              groupStatusGroupname = snapshot.value;
              RoutesHelper.pushRoute(context, ROUTE_GROUP);
            }, child: new Text(
              snapshot.value,))
          ],
        ),
        decoration: new BoxDecoration(
          border: new Border(
            bottom: new BorderSide(width: 1.0, color: const Color.fromRGBO(0, 0, 0, 0.2)),
          ),
        ),
      ),

    );
  }
}
  class Homepage extends StatefulWidget{
    dynamic users;
    Homepage({this.users});
    @override
    HomePageState createState() => new HomePageState(users:users);
  }

  class HomePageState extends State<Homepage> with TickerProviderStateMixin {
    dynamic users;
    var userkey;

    HomePageState({this.users});



    Future<void> getgroups() async{

      groupsToShow=new List<Group>();
      print("Logged in User Now");
      print(loggedinUser);
        users.value.forEach((k,v){
          print(v["emailid"]);
          if(v["emailid"]==loggedinUser) {

            userkey=k;
            print("User key found");
            print(userkey);
          }
        });

      HttpClientFireBase httpClient = HttpClientFireBase();
      final DataSnapshot groupresmap=await getGroups();
      Map grps = groupresmap.value as Map;

      setState(()  {
        reference=  usrref.child(userkey).child("groupsIamin");
        
      });
    }

    //@override
    //void initState() => getgroups();
    @override
    void initState() {
      super.initState();
      getgroups();
    }


    @override
    Widget build(BuildContext context) {
      return new Scaffold(
        appBar: new AppBar(
        leading: new Container(),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.group_add), onPressed: ()async{

            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddGroup(users: users),
            ),).then((value) => setState(() {}));
              }
            ,iconSize: 42.0,
          ),
          new IconButton(
            icon: new Icon(Icons.person),

            onPressed:
              (){
              //TODO
                Animation<double> alpha;

                final AnimationController controller = new AnimationController(
                    duration: const Duration(milliseconds: 500), vsync: this);
                alpha = new Tween(begin: 0.0, end: 255.0).animate(controller)
                  ..addListener(() {
                  });
                controller.forward();
              },
            iconSize: 35.0,),
          new IconButton(
            icon: new Icon(Icons.edit),
            onPressed: () => handleMoreMenu(),
            iconSize: 35.0,),
        ],
          title: new Text('Trips'),
        ),
        body: new Column(children: <Widget>[
      
        new Flexible(
        child:
        ((reference!=null)?
        // ListView.builder(
        //     padding: const EdgeInsets.all(8),
        //     itemCount: groupIamIn.length,
        //     itemBuilder: (BuildContext context, int index) {
        //       return Container(
        //         height: 50,
        //         margin: EdgeInsets.all(2),
        //         color: Colors.white,
        //         //msgCount[index]>3? Colors.white24: Colors.white10,
        //         child: ListTile(
        //             // child: Text('${groupIamIn[index]} ',
        //               title: Text('${groupIamIn[index]}'),
        //               onTap:(){
        //                 groupStatusGroupname = groupIamIn[index];
        //                 RoutesHelper.pushRoute(context, ROUTE_GROUP);
        //                 print(groupIamIn[index]);
        //               },
        //               //style: TextStyle(fontSize: 18),
        //
        //
        //         ),
        //        );
        //      }
        //  ):
        new FirebaseAnimatedList(                            //new
          query: reference,                                       //new
          sort: (a, b) => b.key.compareTo(a.key),                 //new
          padding: new EdgeInsets.all(8.0),                       //new
          reverse: false,                                          //new
          itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation,index) {
            return new groupBox(
                snapshot: snapshot,
                animation: animation,
              index: index,
            );
          },

        ):
         new Container()),                                                        //new
      ),
      ])
      );
    }

  handleMoreMenu() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => UnitTests(),
    ),);
  }
}



