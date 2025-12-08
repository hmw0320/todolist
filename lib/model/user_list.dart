import 'dart:typed_data';

class UserList {

  String id;         // 아이디
  String pw;         // 비밀번호
  String name;       // 이름
  Uint8List image;   // 프로필 이미지

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