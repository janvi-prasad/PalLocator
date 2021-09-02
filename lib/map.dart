import 'dart:convert';
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:trovami/groupdetails.dart';

import 'groupstatus.dart';
import 'homepage.dart';
import 'httpClient/httpClient.dart';
import 'main.dart';
import 'signinpage.dart';
import 'functionsForFirebaseApiCalls.dart';

final userref = FirebaseDatabase.instance.reference().child('users'); // new
final groupref = FirebaseDatabase.instance.reference().child('groups');
int nouserflag;
var twenty;
var sec = const Duration(seconds: 1);
Timer t2;
//var httpClient = HttpClient();

class MapSample extends StatefulWidget {
  List currentLocations = [];
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{}; // CLASS MEMBER, MAP OF MARKS

  Map<MarkerId, Marker> _add(locData) {
    var markerIdVal = locData["emailid"];
    final MarkerId markerId = MarkerId(markerIdVal);

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        locData["latitude"],
        locData["longitude"],
      ),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () {
//        _onMarkerTapped(markerId);
      },
    );

      // adding a new marker to map
      markers[markerId] = marker;
      return markers;
  }
  StreamSubscription _getChangesSubscription;
  @override
  void initState() {
    listenTochanges();
  }
  @override
  void dispose() {
    _getChangesSubscription?.cancel();
    print("Groups listener disposed");
    super.dispose();
  }
  void listenTochanges(){
    print("Groups lister inistialised");
    _getChangesSubscription = groupref.onChildChanged.listen((event) async{
      if(groupStatusGroupname == event.snapshot.value["groupname"]){
        List<dynamic> groupMems = event.snapshot.value["members"];
        print("groupMems -> ${groupMems}");

        for(var grpmem in groupMems){
          print("mem -> ${grpmem["locationShare"]}");
          if(grpmem["locationShare"]==true) {
            for (var i = 0; i < widget.currentLocations.length; i++) {
              if (widget.currentLocations[i]["emailid"] == grpmem["emailid"]) {
                widget.currentLocations[i] = {
                  "latitude": grpmem["location"]["latitude"],
                  "longitude": grpmem["location"]["longitude"],
                  "emailid": grpmem["emailid"]
                };
              }
            }
          }
        }
        setState(() {

        });

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: FutureBuilder(
          future: getLocsOfMembers(),
//          initialData: widget.currentLocations,
          builder: (BuildContext context, snapshot) {
            print("snapshot.data ${snapshot.data}");
            if (snapshot.data == null || snapshot.data.length == 0) {
              return Center(
                child: Text(
                    "No Live location sharing users, Go back and try again"),
              );
            } else {
               widget.currentLocations.forEach((curr){
                 markers = _add(curr);
               });
              return GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(snapshot.data[0]["latitude"], snapshot.data[0]["longitude"]),
                  zoom: 14.4746,

                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                markers: Set<Marker>.of(markers.values),
              );
            }
          }),
    );
  }

  Future getLocsOfMembers() async {
    HttpClientFireBase httpClient = HttpClientFireBase();
    String groupkey;
    int memcount = 0;
    final DataSnapshot grps = await getGroups();
    Map groupresmap = grps.value as Map;
    groupresmap.forEach((k, v) {
      if (v["groupname"] == groupStatusGroupname) {
        memcount = v["members"].length;
        print("groupstatusgroupname:${groupStatusGroupname}");
        groupkey = k;
      }
    });
    for (var i = 0; i < memcount; i++) {
      var response1 = await http.get(Uri.parse(
          "https://pallocator-8fe3e.firebaseio.com/groups/${groupkey}/members/${i}.json"));
      Map result1 = jsonDecode(response1.body);
      print(result1["emailid"]);
      print(result1["locationShare"]);
      if (result1["locationShare"] == true) {

        if(widget.currentLocations.length == 0) {
          widget.currentLocations.add({"latitude":result1["location"]["latitude"],"longitude":result1["location"]["longitude"],"emailid":result1["emailid"]});
          print("here 1 ${widget.currentLocations}");

        }else{
          var flag = 0;
          for (var i = 0; i < widget.currentLocations.length; i++) {
            print("check hereee ${result1["emailid"]}");
            if (widget.currentLocations[i]["emailid"] == result1["emailid"]) {
              flag=1;
              print("curr loc ${widget.currentLocations}");
              print("${result1["emailid"]}");
              widget.currentLocations.removeAt(i);
              widget.currentLocations.add({"latitude":result1["location"]["latitude"],"longitude":result1["location"]["longitude"],"emailid":result1["emailid"]});

            }
          }
          if(flag==0){
            widget.currentLocations.add({"latitude":result1["location"]["latitude"],"longitude":result1["location"]["longitude"],"emailid":result1["emailid"]});
          }

        }


      } else {
        print("works till here");

        for (var i = 0; i < widget.currentLocations.length; i++) {
          if (widget.currentLocations[i]["emailid"] == result1["emailid"]) {
            widget.currentLocations.removeAt(i);
          }
        }
      }
    }
    print("here 2 ${widget.currentLocations}");

    return widget.currentLocations;
  }





