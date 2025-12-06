import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todolist_app/model/todo_list.dart';
import 'package:todolist_app/util/message.dart';
import 'package:todolist_app/vm/database_handler.dart';

class EditView extends StatefulWidget {
  final TodoList todo;        // 수정할 일정
  final VoidCallback onUpdated;

  const EditView({
    super.key,
    required this.todo,
    required this.onUpdated,
  });

  @override
  State<EditView> createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
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
    handler = DatabaseHandler();

    // 🔹 텍스트 필드 초기값
    titleController = TextEditingController(text: widget.todo.title);
    taskController  = TextEditingController(text: widget.todo.task);

    // 🔹 날짜 초기값
    _startSelectedDay = DateTime.parse(widget.todo.startdate);
    _endSelectedDay   = DateTime.parse(widget.todo.enddate);

    // 🔹 시간 초기값 (문자열 "HH:MM" 파싱)
    final startSplit = widget.todo.starttime.split(':');
    final endSplit   = widget.todo.endtime.split(':');

    _startTime = TimeOfDay(
      hour: int.parse(startSplit[0]),
      minute: int.parse(startSplit[1]),
    );
    _endTime = TimeOfDay(
      hour: int.parse(endSplit[0]),
      minute: int.parse(endSplit[1]),
    );

    _startDuration = Duration(
      hours: _startTime!.hour,
      minutes: _startTime!.minute,
    );
    _endDuration = Duration(
      hours: _endTime!.hour,
      minutes: _endTime!.minute,
    );
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
                  firstDay: DateTime.now().subtract(Duration(days: 365 * 5)),
                  lastDay: DateTime.now().add(Duration(days: 365 * 5)),
                  focusedDay: temp,
                  selectedDayPredicate: (day) => isSameDay(day, temp),
                  onDaySelected: (day, _) =>
                      setStateDialog(() => temp = day),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[700],
        foregroundColor: Colors.white,
        title: Text("일정 수정"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  "시작 날짜",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_formatDate(_startSelectedDay)),
                trailing: Icon(Icons.calendar_month),
                onTap: () => _pickDate(true),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  "종료 날짜",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_formatDate(_endSelectedDay)),
                trailing: Icon(Icons.calendar_month),
                onTap: () => _pickDate(false),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  "시작 시간",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_formatTime(_startTime!)),
                trailing: Icon(Icons.access_time),
                onTap: () => _pickTime(true),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: ListTile(
                title: Text(
                  "종료 시간",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_formatTime(_endTime!)),
                trailing: Icon(Icons.access_time),
                onTap: () => _pickTime(false),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "제목을 입력하세요",
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: TextField(
                controller: taskController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "내용을 입력하세요",
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: updateAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("수정"),
                  ),
                  ElevatedButton(
                    onPressed: deleteAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,   // 삭제 → 빨간색
                      foregroundColor: Colors.white,
                    ),
                    child: Text("삭제"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  } // build

  // Functions ---------------------------------
  updateAction() async {
    if (titleController.text.trim().isEmpty) {
      message.snackBar("오류", "제목을 입력하세요");
      return;
    }
    if (_startTime == null || _endTime == null) {
      message.snackBar("오류", "시간을 입력하세요");
      return;
    }

    final startDT = DateTime(
      _startSelectedDay.year,
      _startSelectedDay.month,
      _startSelectedDay.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final endDT = DateTime(
      _endSelectedDay.year,
      _endSelectedDay.month,
      _endSelectedDay.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    if (!endDT.isAfter(startDT)) {
      message.snackBar("오류", "종료 일시가 시작 일시보다 늦어야 합니다.");
      return;
    }

    final updated = TodoList(
      seq: widget.todo.seq,                 // ★ 수정 대상 row 지정
      id: widget.todo.id,                   // 유저 ID는 그대로
      startdate: _formatDate(_startSelectedDay),
      enddate: _formatDate(_endSelectedDay),
      title: titleController.text.trim(),
      task: taskController.text.trim(),
      starttime: _formatTime(_startTime!),
      endtime: _formatTime(_endTime!),
      fav: widget.todo.fav,                 // 즐겨찾기 유지
      end: widget.todo.end,                 // 완료 여부 유지 (필요하면 여기서도 제어 가능)
    );

    final result = await handler.updateTodoList(updated);

    if (result > 0) {
      widget.onUpdated();
      Get.back(result: true);
    } else {
      message.snackBar("오류", "수정 중 오류가 발생했습니다.");
    }
  }

  deleteAction() async {
    Get.defaultDialog(
      title: "삭제 확인",
      middleText: "정말 삭제하시겠습니까?",
      textCancel: "취소",
      textConfirm: "삭제",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await handler.deleteTodolist(widget.todo.seq!);
        widget.onUpdated();
        Get.back();  // dialog 닫기
        Get.back(result: true);  // EditView 닫기
      },
    );
  }
} // class