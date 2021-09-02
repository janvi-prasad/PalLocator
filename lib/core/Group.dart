import 'package:trovami/core/OldUser.dart';

class Group {
  Group({this.groupname,this.groupmembers});
  String groupname = "";
  String startdate ="";
  String enddate="";
  List<OldUser> groupmembers=[];

  Group.fromJson(Map value){
    groupname=value["groupname"];
//    print("value of members:${value["members"]}");
    groupmembers=value["members"];
    startdate=value["startdate"];
    enddate=value["enddate"];

  }
  Map toJson(){
    return {"groupname": groupname,"members":groupmembers, "startdate":startdate, "enddate":enddate};
  }

}