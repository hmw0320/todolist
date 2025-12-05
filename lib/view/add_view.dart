import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todolist_app/model/todo_list.dart';
import 'package:todolist_app/util/message.dart';
import 'package:todolist_app/vm/database_handler.dart';

class AddView extends StatefulWidget {
  final String userid;
  final VoidCallback onSaved;

  const AddView({super.key, required this.userid, required this.onSaved});

  @override
  State<AddView> createState() => _AddViewState();
}

class _AddViewState extends State<AddView> {

  late TextEditingController titleController;
  late TextEditingController taskController;
  late DatabaseHandler handler;

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Duration _startDuration = Duration(hours: 9);
  Duration _endDuration   = Duration(hours: 10);

  Message message = Message();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    taskController = TextEditingController();
    handler = DatabaseHandler();
  }

  @override
  void dispose() {
    titleController.dispose();
    taskController.dispose();
    super.dispose();
  }

  final DateTime _firstDay = DateTime(
    DateTime.now().year - 5,
    DateTime.now().month,
    DateTime.now().day,
  );

  final DateTime _lastDay = DateTime(
    DateTime.now().year + 5,
    DateTime.now().month,
    DateTime.now().day,
  );

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return "$year-$month-$day";
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  String _formatDurationToHM(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return "${h.toString().padLeft(2, '0')}시 ${m.toString().padLeft(2, '0')}분";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[700],
        foregroundColor: Colors.white,
        title: Text('일정 추가'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TableCalendar(
              firstDay: _firstDay,
              lastDay: _lastDay,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarFormat: CalendarFormat.month,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),

            // 시작 시간 ------------------
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '시작 시간',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 100,
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    initialTimerDuration: _startDuration,
                    onTimerDurationChanged: (Duration value) {
                      setState(() {
                        _startDuration = value;
                        final h = value.inHours;
                        final m = value.inMinutes.remainder(60);
                        _startTime = TimeOfDay(hour: h, minute: m);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // 🔹 여기에 한국어 형식으로 표시
                Text(
                  _formatDurationToHM(_startDuration),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // 종료 시간 ------------------
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '종료 시간',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 100,
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    initialTimerDuration: _endDuration,
                    onTimerDurationChanged: (Duration value) {
                      setState(() {
                        _endDuration = value;
                        final h = value.inHours;
                        final m = value.inMinutes.remainder(60);
                        _endTime = TimeOfDay(hour: h, minute: m);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // 🔹 종료 시간도 같은 형식으로 표시
                Text(
                  _formatDurationToHM(_endDuration),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: '제목을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: taskController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: '내용을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () => insertAction(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  } // build

  // Functions ---------------------------
  insertAction() async {
    if (titleController.text.trim().isEmpty) {
      message.snackBar('오류', '제목을 입력하세요');
      return;
    }

    if (_startTime == null || _endTime == null) {
      message.snackBar('오류', '시간을 입력하세요');
      return;
    }

    int startInMinutes = _startTime!.hour * 60 + _startTime!.minute;
    int endInMinutes = _endTime!.hour * 60 + _endTime!.minute;

    if (startInMinutes >= endInMinutes) {
      message.snackBar('오류', '종료 시간은 시작 시간보다 늦어야 합니다.');
      return;
    }

    final String date = _formatDate(_selectedDay);
    final String start = _formatTime(_startTime!);
    final String end = _formatTime(_endTime!);

    final todo = TodoList(
      id: widget.userid,
      date: date,
      title: titleController.text.trim(),
      task: taskController.text.trim(),
      starttime: start,
      endtime: end,
    );

    int result = await handler.insertTodoList(todo);

    if (result == 0) {
      message.snackBar('오류', '저장 중 오류가 발생했습니다.');
    } else {
      Get.defaultDialog(
        title: '완료',
        middleText: '일정이 저장되었습니다.',
        backgroundColor: Color.fromARGB(255, 193, 197, 201),
        barrierDismissible: false,
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            child: Text('OK'),
          ),
        ],
      );
      widget.onSaved();
      titleController.clear();
      taskController.clear();
      _startTime = null;
      _endTime = null;
      _startDuration = Duration(hours: 9);
      _endDuration = Duration(hours: 10);
      setState(() {});
    }
  }

} // class
