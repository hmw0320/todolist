import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todolist_app/model/user_list.dart';
import 'package:todolist_app/util/calendar_list.dart';
import 'package:todolist_app/view/edit_view.dart';
import 'package:todolist_app/vm/database_handler.dart';
import 'package:table_calendar/table_calendar.dart';

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
  DateTime _currentMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  bool _isExpanded = false;

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

  int _daysInMonth(DateTime month) {
    final firstDayNextMonth = (month.month == 12)
        ? DateTime(month.year + 1, 1, 1)
        : DateTime(month.year, month.month + 1, 1);
    return firstDayNextMonth.subtract(Duration(days: 1)).day;
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedDay = picked;
        _currentMonth = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  _goToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDay = now;
      _currentMonth = DateTime(now.year, now.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final String selectedDateString = _formatDate(_selectedDay);
    final int daysInMonth = _daysInMonth(_currentMonth);
    final DateTime monthStart =
        DateTime(_currentMonth.year, _currentMonth.month, 1);

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(),
        backgroundColor: Colors.lightBlue,
        actions: [
          TextButton(
            onPressed: _goToday,
            child: Text(
              '오늘',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  InkWell(
                    onTap: _pickMonth,
                    child: Row(
                      children: [
                        Text(
                          '${_currentMonth.year}년 ${_currentMonth.month}월',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                ],
              ),
            ),
            CalendarList(
              startDate: monthStart,
              dayCount: daysInMonth,
              selectedDay: _selectedDay,
              onDaySelected: (day) {
                setState(() {
                  _selectedDay = day;
                  _currentMonth = DateTime(day.year, day.month, 1);
                });
              },
            ),
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TableCalendar(
                  firstDay: DateTime(_currentMonth.year - 5, 1, 1),
                  lastDay: DateTime(_currentMonth.year + 5, 12, 31),
                  focusedDay: _selectedDay,
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) =>
                      day.year == _selectedDay.year &&
                      day.month == _selectedDay.month &&
                      day.day == _selectedDay.day,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _currentMonth =
                          DateTime(selectedDay.year, selectedDay.month, 1);
                    });
                  },
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: FutureBuilder(
                  future: () async {
                    await handler.updateEnd(widget.userid);
                    return handler.queryTodoListDateRange(
                        widget.userid, selectedDateString);
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
                                  if(result == true){
                                    setState(() {});
                                  }
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
                                                color: snapshot.data![index].end
                                                    ? Colors.grey
                                                    : Colors.orange,
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                ),
                              );
                            },
                          )
                        : SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: MediaQuery.of(context).size.width * 0.25,
                            child: Center(
                              child: Text('해당 날짜의 일정이 없습니다.'),
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
  }
}
