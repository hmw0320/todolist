import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todolist_app/util/message.dart';
import 'package:todolist_app/view/home.dart';
import 'package:todolist_app/view/register.dart';
import 'package:todolist_app/vm/database_handler.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  late TextEditingController idController;        // 아이디 입력 창
  late TextEditingController pwController;        // 비밀번호 입력 창
  late DatabaseHandler handler;                   // handler
  late bool i;                                    // 로그인 성공 여부

  Message message = Message();                    // message

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
    pwController = TextEditingController();
    handler = DatabaseHandler();
    i = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[700],
        foregroundColor: Colors.white,
        title: Text('Log In'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => checkLogin(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(5)
                  ),
                  minimumSize: Size(100, 40)
                ),
                child: Text('Log In')
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => Get.to(
                  Register()
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(5)
                  ),
                  minimumSize: Size(100, 40)
                ),
                child: Text('회원가입')
              ),
            ),
          ],
        ),
      ),
    );
  } // build

  checkLogin() async{
    // id, pw가 비어있을 경우
    if(idController.text.trim().isEmpty ||
       pwController.text.trim().isEmpty){
      i=true;
      message.snackBar('오류', '아이디 또는 비밀번호가 틀렸습니다.');
    }else{
    // 정상적인 경우
    final id = idController.text.trim();
    final pw = pwController.text.trim();
    final result = await handler.login(id, pw);
      if(result){
        Get.defaultDialog(
          title: '로그인',
          middleText: '로그인 되었습니다.',
          backgroundColor: const Color.fromARGB(255, 193, 197, 201),
          barrierDismissible: false,
          actions: [
            TextButton(
              onPressed: () {
                Get.offAll(Home(userid: id));
              },
              style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      }else{
    // id, pw가 틀렸을 경우
        i=false;
        message.snackBar('오류', '아이디 또는 비밀번호가 틀렸습니다.');
      }
    }
    setState(() {});
  }


} // class