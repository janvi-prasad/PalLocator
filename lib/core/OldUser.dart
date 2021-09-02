class OldUser {
  OldUser({this.EmailId,this.password,this.name,this.locationShare,this.groupsIamin,this.location});
   String EmailId ;
   String password;
   String name;
   bool locationShare;
   String phoneNumber;
  Map<String,double> location=null;
   List<String> groupsIamin=[];


  OldUser.fromJson(Map value){
    EmailId=value["emailid"];
    name=value["name"];
    locationShare=value["locationShare"];
    groupsIamin=value["groupsIamin"];
    phoneNumber=value["phoneNumber"];
    password=value["password"];
  }
   Map toJson(){
     return {"name": name,"locationShare": locationShare,"groupsIamin":groupsIamin,"emailid":EmailId,"location":location,"phoneNumber":phoneNumber,"password":password};
   }
}
