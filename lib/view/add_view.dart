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

  DateTime _startSelectedDay = DateTime.now();
  DateTime _endSelectedDay   = DateTime.now();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Duration _startDuration = const Duration(hours: 9);
  Duration _endDuration   = const Duration(hours: 10);

  Message message = Message();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    taskController = TextEditingController();
    handler = DatabaseHandler();

    final now = DateTime.now();
    _startTime = TimeOfDay(hour: now.hour, minute: now.minute);

    final endMinute = now.minute + 30;
    _endTime = TimeOfDay(
        hour: now.hour + endMinute ~/ 60,
        minute: endMinute % 60
    );

    _startDuration = Duration(hours: now.hour, minutes: now.minute);
    _endDuration   = Duration(hours: _endTime!.hour, minutes: _endTime!.minute);
  }

  String _formatDate(DateTime date) =>
      "${date.year.toString().padLeft(4,'0')}-"
      "${date.month.toString().padLeft(2,'0')}-"
      "${date.day.toString().padLeft(2,'0')}";

  String _formatTime(TimeOfDay time) =>
      "${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}";

  Future<void> _pickDate(bool isStart) async {
    DateTime temp = isStart ? _startSelectedDay : _endSelectedDay;

    final result = await showDialog<DateTime>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(isStart ? "시작 날짜 선택" : "종료 날짜 선택"),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 350,
                child: TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365 * 5)),
                  lastDay: DateTime.now().add(const Duration(days: 365 * 5)),
                  focusedDay: temp,
                  selectedDayPredicate: (day) => isSameDay(day, temp),
                  onDaySelected: (day, _) =>
                      setStateDialog(() => temp = day),
                  headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true),
                ),
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text("취소")),
            TextButton(onPressed: () => Get.back(result: temp), child: Text("확인"))
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        if (isStart) {
          _startSelectedDay = result;
          if (_endSelectedDay.isBefore(_startSelectedDay)) {
            _endSelectedDay = result;
          }
        } else {
          _endSelectedDay = result;
        }
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    Duration temp = isStart ? _startDuration : _endDuration;

    final picked = await showCupertinoModalPopup<Duration>(
      context: context,
      builder: (_) {
        return Container(
          height: 260,
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: temp,
                  onTimerDurationChanged: (value) => temp = value,
                ),
              ),
              CupertinoButton(
                child: Text("확인"),
                onPressed: () => Navigator.pop(context, temp),
              ),
            ],
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        final h = picked.inHours;
        final m = picked.inMinutes.remainder(60);

        if (isStart) {
          _startDuration = picked;
          _startTime = TimeOfDay(hour: h, minute: m);
        } else {
          _endDuration = picked;
          _endTime = TimeOfDay(hour: h, minute: m);
        }
      });
    }
  }

  insertAction() async {
    if (titleController.text.trim().isEmpty) {
      message.snackBar("오류", "제목을 입력하세요");
      return;
    }
    if (_startTime == null || _endTime == null) {
      message.snackBar("오류", "시간을 입력하세요");
      return;
    }

    final startDT = DateTime(_startSelectedDay.year, _startSelectedDay.month,
        _startSelectedDay.day, _startTime!.hour, _startTime!.minute);
    final endDT = DateTime(_endSelectedDay.year, _endSelectedDay.month,
        _endSelectedDay.day, _endTime!.hour, _endTime!.minute);

    if (!endDT.isAfter(startDT)) {
      message.snackBar("오류", "종료 일시가 시작 일시보다 늦어야 합니다.");
      return;
    }

    final todo = TodoList(
      id: widget.userid,
      startdate: _formatDate(_startSelectedDay),
      enddate: _formatDate(_endSelectedDay),
      title: titleController.text.trim(),
      task: taskController.text.trim(),
      starttime: _formatTime(_startTime!),
      endtime: _formatTime(_endTime!),
    );

    int result = await handler.insertTodoList(todo);

    if (result > 0) {
      Get.defaultDialog(
        title: "완료",
        middleText: "일정이 저장되었습니다.",
        barrierDismissible: false,
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("OK")),
        ],
      );

      widget.onSaved();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[700],
        foregroundColor: Colors.white,
        title: Text("일정 추가"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text("시작 날짜", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                subtitle: Text(_formatDate(_startSelectedDay)),
                trailing: Icon(Icons.calendar_month),
                onTap: () => _pickDate(true),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text("종료 날짜", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                subtitle: Text(_formatDate(_endSelectedDay)),
                trailing: Icon(Icons.calendar_month),
                onTap: () => _pickDate(false),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text("시작 시간", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                subtitle: Text(_formatTime(_startTime!)),
                trailing: Icon(Icons.access_time),
                onTap: () => _pickTime(true),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: ListTile(
                title: Text("종료 시간", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                subtitle: Text(_formatTime(_endTime!)),
                trailing: Icon(Icons.access_time),
                onTap: () => _pickTime(false),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "제목을 입력하세요", border: OutlineInputBorder()),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: TextField(
                controller: taskController,
                maxLines: 4,
                decoration: InputDecoration(labelText: "내용을 입력하세요", border: OutlineInputBorder()),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: ElevatedButton(
                onPressed: insertAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                ),
                child: Text("저장"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
