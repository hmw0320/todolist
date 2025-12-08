import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todolist_app/model/todo_list.dart';
import 'package:todolist_app/model/user_list.dart';
import 'package:todolist_app/vm/database_handler.dart';
import 'package:todolist_app/view/edit_view.dart';

class DetailView extends StatefulWidget {
  final String userid;

  const DetailView({super.key, required this.userid});

  @override
  State<DetailView> createState() => DetailViewState();
}

class DetailViewState extends State<DetailView> {

  // Property
  late DatabaseHandler handler;                     // handler
  UserList? user;                                   // 유저 정보

  late TextEditingController searchController;      // 검색 TextField
  String _keyword = '';                             // 검색 창 키워드

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    searchController = TextEditingController();
    loadUserData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // 유저 정보 가져오기
  loadUserData() async {
    List<UserList> list = await handler.queryUserList(widget.userid);
    if (list.isNotEmpty) {
      user = list.first;
    }
    setState(() {});
  }

  // 검색
  _onSearch() {
    setState(() {
      _keyword = searchController.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text('일정 검색'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: '제목 또는 내용을 입력하세요',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _onSearch(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _onSearch,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: FutureBuilder<List<TodoList>>(
                  future: () async {
                    if (_keyword.isEmpty) {
                      return <TodoList>[];
                    }
                    return handler.searchTodoList(widget.userid, _keyword);
                  }(),
                  builder: (context, snapshot) {
                    return snapshot.hasData && snapshot.data!.isNotEmpty
                        ? ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final todo = snapshot.data![index];
                              return GestureDetector(
                                onTap: () async {
                                  final result = await Get.to(
                                    () => EditView(
                                      todo: todo,
                                      onUpdated: () async {
                                        setState(() {});
                                      },
                                    ),
                                  );
                                  result == true ? setState(() {}) : null;
                                },
                                child: SizedBox(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(10, 12, 15, 12),
                                              child: Icon(
                                                Icons.circle,
                                                color: todo.end ? Colors.grey : Colors.orange,
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  todo.title,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold, fontSize: 16),
                                                ),
                                                if (todo.task.isNotEmpty) Text(todo.task),
                                                Text(
                                                  '${todo.startdate} ${todo.starttime} ~ ${todo.enddate} ${todo.endtime}',
                                                  style: TextStyle(
                                                      fontSize: 12, color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: MediaQuery.of(context).size.width * 0.25,
                            child: Center(
                              child: Text(
                                _keyword.isEmpty
                                    ? '검색어를 입력하세요.'
                                    : '검색 결과가 없습니다.',
                              ),
                            ),
                          );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } // build
} // class
