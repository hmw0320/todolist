import 'dart:typed_data';

class UserList {

  String id;
  String pw;
  String name;
  Uint8List image;

  UserList(
    {
      required this.id,
      required this.pw,
      required this.name,
      required this.image,
    }
  );

  UserList.fromMap(Map<String, dynamic> res)
  : id = res['id'],
    pw = res['pw'],
    name = res['name'],
    image = res['image'];

}