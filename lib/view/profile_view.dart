import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todolist_app/model/user_list.dart';
import 'package:todolist_app/util/message.dart';
import 'package:todolist_app/vm/database_handler.dart';
import 'package:todolist_app/view/login_view.dart';

class ProfileView extends StatefulWidget {
  final String userid;

  const ProfileView({super.key, required this.userid});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late TextEditingController nameController;
  late TextEditingController deleteIdController;
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
    deleteIdController = TextEditingController();
    loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    deleteIdController.dispose();
    super.dispose();
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
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: () => getImageFromGallery(ImageSource.gallery),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text('이미지 가져오기'),
                    ),
                  ),
                  CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.3,
                    backgroundImage: imageFile == null
                        ? MemoryImage(user!.image)
                        : FileImage(File(imageFile!.path)) as ImageProvider,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('이름: '),
                        SizedBox(
                          width: 200,
                          child: TextField(
                            controller: nameController,
                            decoration: InputDecoration(border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: profileEdit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text('수정 완료'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: _showDeleteIdDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text('탈퇴하기'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future getImageFromGallery(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      imageFile = XFile(pickedFile.path);
      setState(() {});
    }
  }

  profileEdit() async {
    int result = checkData();
    if (result == 0) {
      Uint8List getImage = imageFile == null
          ? user!.image
          : await File(imageFile!.path).readAsBytes();

      var userlist = UserList(
        id: user!.id,
        pw: user!.pw,
        name: nameController.text.trim(),
        image: getImage,
      );

      result = await handler.updateUserListAll(userlist);

      result == 0
          ? message.snackBar('DB 오류', 'Data 저장시 문제가 발생했습니다')
          : Get.defaultDialog(
              title: '완료',
              middleText: '수정이 완료되었습니다.',
              barrierDismissible: false,
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                    Get.back(result: true);
                  },
                  child: Text('OK'),
                ),
              ],
            );
    }
  }

  int checkData() {
    int result = 0;

    nameController.text.trim().isEmpty
        ? () { message.snackBar('이름', '이름을 입력하세요'); result++; }()
        : null;

    return result;
  }

  _showDeleteIdDialog() {
    deleteIdController.text = '';

    Get.defaultDialog(
      title: '회원 탈퇴 확인',
      content: Padding(
        padding: EdgeInsets.all(8),
        child: TextField(
          controller: deleteIdController,
          decoration: InputDecoration(
            labelText: '아이디 입력',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      textCancel: '취소',
      textConfirm: '확인',
      confirmTextColor: Colors.white,
      onConfirm: () {
        final inputId = deleteIdController.text.trim();

        inputId.isEmpty
            ? message.snackBar('오류', '아이디를 입력하세요')
            : inputId != user!.id
                ? message.snackBar('오류', '아이디가 일치하지 않습니다')
                : {
                    Get.back(),
                    _showFinalDeleteConfirm(),
                  };
      },
    );
  }

  void _showFinalDeleteConfirm() {
    Get.defaultDialog(
      title: '정말 탈퇴하시겠습니까?',
      middleText: '계정의 모든 정보가 삭제되며 복구할 수 없습니다.',
      textCancel: '취소',
      textConfirm: '탈퇴',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await handler.deleteUserAll(user!.id);
        Get.back();
        Get.offAll(() => LoginView());
      },
    );
  }
}
