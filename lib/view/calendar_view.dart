import 'package:flutter/material.dart';
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
      body: SingleChildScrollView(
        child: Column(
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
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: FutureBuilder(
                  future: () async {
                    await handler.updateEnd(widget.userid);
                    return handler.queryTodoListDateRange(widget.userid, selectedDateString);
                  }(),
                  builder: (context, snapshot) {
                    return snapshot.hasData && snapshot.data!.isNotEmpty
                    ? ListView.builder(
                      itemCount: snapshot.data!.length,
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
                                      padding: EdgeInsets.fromLTRB(10, 12, 15, 12),
                                      child: Icon(Icons.circle, color: snapshot.data![index].end ? Colors.grey : Colors.orange)
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.data![index].title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(snapshot.data![index].task),
                                        Text(
                                          '${snapshot.data![index].starttime} ~ ${snapshot.data![index].endtime}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
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
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.width * 0.25,
                      child: Center(child: Text('해당 날짜의 일정이 없습니다.')));
                      
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
