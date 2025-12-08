import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todolist_app/model/user_list.dart';
import 'package:todolist_app/util/datetime.dart';
import 'package:todolist_app/view/edit_view.dart';
import 'package:todolist_app/view/profile_view.dart';
import 'package:todolist_app/vm/database_handler.dart';

class Overview extends StatefulWidget {
  final String userid;
  const Overview({super.key, required this.userid});

  @override
  State<Overview> createState() => OverviewState();
}

class OverviewState extends State<Overview> {
  late DatabaseHandler handler;      // handler
  UserList? user;                    // 유저 정보

  int _todayTotal = 0;               // 오늘 끝나는 일정 총 개수
  int _todayCompleted = 0;           // 오늘 끝나는 일정 중 완료 개수

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    loadUserData();
    reFresh();
  }

  // 새로고침
  Future<void> reFresh() async {
    await handler.updateEnd(widget.userid);
    await loadTodayCounts(); 
    setState(() {});
  }

  // 오늘 종료 일정 개수
  Future<void> loadTodayCounts() async {
    final counts = await handler.getTodayTaskCounts(widget.userid);
    _todayTotal = counts['total'] ?? 0;
    _todayCompleted = counts['completed'] ?? 0;
  }

  // 유저 정보 가져오기
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
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[700],
        foregroundColor: Colors.white,
        toolbarHeight: 225,
        leadingWidth: MediaQuery.of(context).size.width,
        leading: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: user == null
              ? null
              : () => Get.to(
                ProfileView(userid: widget.userid)
                )!.then((value) {
                  if(value==true){loadUserData();}
                  },
                ),
              child: user == null
              ? CircularProgressIndicator()
              : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(radius: 25, backgroundImage: MemoryImage(user!.image)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      user!.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      ),
                    ),
                  ),
                ],
              )
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 0, 20),
              child: Text(
                '${DateTime.now().month}월 ${DateTime.now().day}일', 
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                )
              ),
            ),
          ],
        ),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                child: Row(
                  children: [
                    Text(
                      '$_todayCompleted / $_todayTotal',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '완료',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () async {
                  await reFresh();
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.yellow[200],
              width: MediaQuery.of(context).size.width,
              height: 45,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('가까운 일정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange[700])),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width*0.35,
              child: FutureBuilder(
                future: handler.queryTodoList(widget.userid),
                builder: (context, snapshot) {
                  return snapshot.hasData && snapshot.data!.isNotEmpty
                      ? Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: min(snapshot.data!.length, 5),
                          itemBuilder: (context, index) {
                            final todo = snapshot.data![index];
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                              child: GestureDetector(
                                onTap: () async {
                                  final result = await Get.to(
                                    () => EditView(
                                      todo: todo,
                                      onUpdated: () async {
                                        await reFresh();
                                      },
                                    ),
                                  );
                                  if(result == true){
                                    await reFresh();
                                  }
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width*0.7,
                                  height: MediaQuery.of(context).size.width*0.25,
                                  child: Card(
                                    color: index % 2 == 0 
                                    ? Theme.of(context).colorScheme.primaryContainer
                                    : Theme.of(context).colorScheme.secondaryContainer,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(snapshot.data![index].title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(snapshot.data![index].task, style: TextStyle(fontSize: 12)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            DateTimeUtil.formatRangeText(
                                              snapshot.data![index].startdate,
                                              snapshot.data![index].enddate,
                                              snapshot.data![index].starttime,
                                              snapshot.data![index].endtime,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                      : SizedBox(
                        width: MediaQuery.of(context).size.width*0.7,
                        height: MediaQuery.of(context).size.width*0.25,
                        child: Center(child: Text('일정을 추가하세요.')),
                      );
                },
              ),
            ),
            Container(
              color: Colors.yellow[200],
              width: MediaQuery.of(context).size.width,
              height: 45,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('완료된 일정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange[700])),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width*0.75,
                child: FutureBuilder(
                  future: handler.queryEndList(widget.userid),
                  builder: (context, snapshot) {
                    return snapshot.hasData && snapshot.data!.isNotEmpty
                    ? ListView.builder(
                      itemCount: min(snapshot.data!.length, 5),
                      itemBuilder: (context, index) {
                        return SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(10, 12, 15, 12),
                                      child: Icon(Icons.circle, color: Colors.grey),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width*0.8,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(snapshot.data![index].title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              Text(snapshot.data![index].task),
                                            ],
                                          ),
                                          Text(
                                            DateTimeUtil.formatRangeText(
                                              snapshot.data![index].startdate,
                                              snapshot.data![index].enddate,
                                              snapshot.data![index].starttime,
                                              snapshot.data![index].endtime,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                    : SizedBox(
                      width: MediaQuery.of(context).size.width*0.7,
                      height: MediaQuery.of(context).size.width*0.25,
                      child: Center(child: Text('완료된 일정이 없습니다.')),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  } // build
} // class