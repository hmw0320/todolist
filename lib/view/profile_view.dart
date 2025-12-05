import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todolist_app/model/user_list.dart';
import 'package:todolist_app/util/message.dart';
import 'package:todolist_app/vm/database_handler.dart';

class ProfileView extends StatefulWidget {
  final String userid;
  const ProfileView({super.key, required this.userid});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {

  late TextEditingController nameController;
  late DatabaseHandler handler;
  XFile? imageFile;
  UserList? user;

  final ImagePicker picker = ImagePicker();
  Message message = Message();

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    nameController = TextEditingController();
    loadUserData();
  }

  loadUserData() async {
    List<UserList> list = await handler.queryUserList(widget.userid);
    if (list.isNotEmpty) {
      user = list.first;
      nameController.text = user!.name;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[700],
        foregroundColor: Colors.white,
        title: Text('정보 수정'),
        centerTitle: true,
      ),
      body: user == null
      ? CircularProgressIndicator() 
      : Center(
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
            CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.3,
                backgroundImage: imageFile == null
                    ? MemoryImage(user!.image)
                    : FileImage(File(imageFile!.path)),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('이름: '),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => profileEdit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(5)
                  ),
                ),
                child: Text('수정완료')
              ),
            ),
          ],
        ),
      ),
    );
  } // build

  Future getImageFromGallery(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile == null) {
      return;
    } else {
      imageFile = XFile(pickedFile.path);
      setState(() {});
    }
  } // getImageFromGallery

  profileEdit() async{
    int result = checkData(); 
    if(result == 0){

    Uint8List getImage;

    if (imageFile == null) {
      getImage = user!.image;
    } else {
      File imageFile1 = File(imageFile!.path);
      getImage = await imageFile1.readAsBytes();
    }

      var userlist = UserList(
        id: user!.id,
        pw: user!.pw,
        name: nameController.text.trim(),
        image: getImage
      );

      result = await handler.updateUserListAll(userlist);
      result == 0
      ? message.snackBar('DB 오류', 'Data저장시 문제가 발생했습니다')
      :   
      Get.defaultDialog(
        title: '완료',
        middleText: '수정이 완료되었습니다.',
        backgroundColor: const Color.fromARGB(255, 193, 197, 201),
        barrierDismissible: false,
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(result: true);
            },
            style: TextButton.styleFrom(
                foregroundColor: Colors.black,
            ),
            child: const Text('OK'),
          ),
        ],
      );
    }

  } // insertAction

  // 입력 체크 : Error 조건 구성
  int checkData(){
    final List<Map<String, dynamic>> checks = [
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
  } // checkData

} // class