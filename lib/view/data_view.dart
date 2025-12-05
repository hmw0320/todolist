import 'package:flutter/material.dart';
import 'package:todolist_app/model/user_list.dart';
import 'package:todolist_app/vm/database_handler.dart';

class DataView extends StatefulWidget {
  final String userid;
  const DataView({super.key, required this.userid});

  @override
  State<DataView> createState() => DataViewState();
}

class DataViewState extends State<DataView> {

  late DatabaseHandler handler;
  UserList? user;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    loadUserData();
  }

  loadUserData() async {
    List<UserList> list = await handler.queryUserList(widget.userid);
    if (list.isNotEmpty) {
      user = list.first;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Data View'),
          ],
        ),
      ),
    );
  }
}