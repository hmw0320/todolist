import 'package:flutter/material.dart';
import 'package:todolist_app/model/user_list.dart';
import 'package:todolist_app/vm/database_handler.dart';

class DetailView extends StatefulWidget {
  final String userid;

  const DetailView({super.key, required this.userid});

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {

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
            Text('Detail view'),
          ],
        ),
      ),
    );
  }
}