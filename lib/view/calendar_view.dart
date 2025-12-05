import 'package:flutter/material.dart';
import 'package:todolist_app/model/todo_list.dart';
import 'package:todolist_app/model/user_list.dart';
import 'package:todolist_app/util/calendar_list.dart';
import 'package:todolist_app/vm/database_handler.dart';

class CalendarView extends StatefulWidget {
  final String userid;
  const CalendarView({super.key, required this.userid});

  @override
  State<CalendarView> createState() => CalendarViewState();
}

class CalendarViewState extends State<CalendarView> {

  late DatabaseHandler handler;
  UserList? user;

  DateTime _selectedDay = DateTime.now();

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

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return "$year-$month-$day";
  }

  @override
  Widget build(BuildContext context) {
    final String selectedDateString = _formatDate(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
        ),
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          CalendarList(
            startDate: DateTime.now(),
            dayCount: 7,
            selectedDay: _selectedDay,
            onDaySelected: (day) {
              setState(() {
                _selectedDay = day;
              });
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                // height는 Expanded가 잡아주니까 굳이 안 줘도 됨
                child: FutureBuilder<List<TodoList>>(
                  future: handler.queryTodoListDate(widget.userid, selectedDateString),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.width * 0.25,
                        child: const Center(child: Text('해당 날짜의 일정이 없습니다.')),
                      );
                    }

                    final list = snapshot.data!;

                    return ListView.builder(
                      itemCount: list.length, // 필요하면 min(list.length, 5)로 제한 가능
                      itemBuilder: (context, index) {
                        final todo = list[index];
                        return SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                child: Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(10, 12, 15, 12),
                                      child: Icon(Icons.circle, color: Colors.grey),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 제목
                                        Text(
                                          todo.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        // 시간
                                        Text(
                                          '${todo.starttime} ~ ${todo.endtime}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        // 내용
                                        Text(todo.task),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
