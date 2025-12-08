import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todolist_app/model/user_list.dart';
import 'package:todolist_app/util/message.dart';
import 'package:todolist_app/vm/database_handler.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late TextEditingController idController;      // 아이디 입력 창
  late TextEditingController pwController;      // 비밀번호 입력 창
  late TextEditingController nameController;    // 이름 입력 창
  
  late DatabaseHandler handler;                 // handler
  XFile? imageFile;                             // 이미지 파일

  final ImagePicker picker = ImagePicker();     // Image Picker
  Message message = Message();                  // message

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
    pwController = TextEditingController();
    nameController = TextEditingController();
    handler = DatabaseHandler();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        title: Text('회원가입'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => getImageFromGallery(ImageSource.gallery),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(5)
                  ),
                ),
                child: Text('이미지 가져오기'),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 200,
              color: Colors.grey,
              child: Center(
                child: imageFile == null
                    ? Text('Image is not selected!')
                    : Image.file(File(imageFile!.path)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: idController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '아이디를 입력하세요'
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: pwController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '비밀번호를 입력하세요'
                ),
                obscureText: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '이름을 입력하세요'
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => checkRegister(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(5)
                  ),
                ),
                child: Text('OK')
              ),
            ),
          ],
        ),
      ),
    );
  } // build
  
  // Functions ------------------------------------
  Future getImageFromGallery(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile == null) {
      return;
    } else {
      imageFile = XFile(pickedFile.path);
      setState(() {});
    }
  }

  checkRegister() async{
    int result = checkData(); 
    if(result == 0){
      // File Type을 Byte Type으로 변환
      File imageFile1 = File(imageFile!.path);
      Uint8List getImage = await imageFile1.readAsBytes();

      var userlist = UserList(
        id: idController.text.trim(),
        pw: pwController.text.trim(),
        name: nameController.text.trim(),
        image: getImage
      );

      result = await handler.insertUserList(userlist);
      result == 0
      ? message.snackBar('DB 오류', 'Data저장시 문제가 발생했습니다')
      : message.showDialog('완료', '가입이 완료 되었습니다.');
    }

  }

  // 입력 체크
  int checkData(){
    final List<Map<String, dynamic>> checks = [
      {
        'condition': imageFile == null,
        'title': '이미지',
        'message': '이미지를 선택 하세요',
      },
      {
        'condition': idController.text.trim().isEmpty,
        'title': '아이디',
        'message': '아이디를 입력 하세요',
      },
      {
        'condition': pwController.text.trim().isEmpty,
        'title': '비밀번호',
        'message': '비밀번호를 입력 하세요',
      },
      {
        'condition': nameController.text.trim().isEmpty,
        'title': '이름',
        'message': '이름을 입력 하세요',
      },
    ];

    int result = 0;

    for (var check in checks) {
      if (check['condition']) {
        message.snackBar(check['title'], check['message']);
        result++;
      }
    }
    
    return result;
  }
} // class