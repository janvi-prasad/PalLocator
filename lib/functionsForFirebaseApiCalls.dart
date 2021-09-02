import 'package:firebase_database/firebase_database.dart';

final usrRef = FirebaseDatabase.instance.reference().child('users');
final groupsRef = FirebaseDatabase.instance.reference().child('groups');

getUsers() async {

  var docs= await usrRef.once();
  return docs;

}

getUserById(id)async{
  dynamic resp=await usrRef.child(id).once();
  print("user: ${resp.value}");
  return resp;
}

getGroupsIamIn(userId)async{
  return await usrRef.child(userId).child("groupsIamin").once();
}

getGroups()async{
  dynamic resp=await groupsRef.orderByKey().once();
  return resp;
}

getAGroupAndAMember(groupKey,memberIndex)async{
  return await groupsRef.child(groupKey).child("members").once();
}
getGroupMembers(groupName){

}
