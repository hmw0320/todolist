import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todolist_app/model/todo_list.dart';
import 'package:todolist_app/util/message.dart';
import 'package:todolist_app/util/datetime.dart';
import 'package:todolist_app/vm/database_handler.dart';

class EditView extends StatefulWidget {
  final TodoList todo;          // 수정할 일정
  final VoidCallback onUpdated; // 수정 후 이전 화면에서 새로고침

  const EditView({
    super.key,
    required this.todo,
    required this.onUpdated,
  });

  @override
  State<EditView> createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  late TextEditingController titleController;     // 제목 입력 창
  late TextEditingController taskController;      // 내용 입력 창
  late DatabaseHandler handler;                   // handler

  DateTime _startSelectedDay = DateTime.now();    // 선택된 시작 날짜
  DateTime _endSelectedDay   = DateTime.now();    // 선택된 종료 날짜

  TimeOfDay? _startTime;                          // 선택된 시작 시간
  TimeOfDay? _endTime;                            // 선택된 종료 시간

  Duration _startDuration = Duration(hours: 9);   // CupertinoTimerPicker 초기 시작 시간
  Duration _endDuration   = Duration(hours: 10);  // CupertinoTimerPicker 초기 종료 시간

  Message message = Message();                    // SnackBar, Dialog

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();

    // TextField 초기값
    titleController = TextEditingController(text: widget.todo.title);
    taskController  = TextEditingController(text: widget.todo.task);

    // 날짜 초기값
    _startSelectedDay = DateTime.parse(widget.todo.startdate);
    _endSelectedDay   = DateTime.parse(widget.todo.enddate);

    // 시간 초기값, HH:mm 형식으로
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

  // 날짜 선택
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

  // 종료 날짜가 시작 날짜보다 빠르면 동일한 날짜로 변경
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

  // isStart가 true면 시작 시간 선택, false면 종료 시간 선택
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
                subtitle: Text(DateTimeUtil.formatDate(_startSelectedDay)),
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
                subtitle: Text(DateTimeUtil.formatDate(_endSelectedDay)),
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
                subtitle: Text(DateTimeUtil.formatTimeOfDay(_startTime!)),
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
                subtitle: Text(DateTimeUtil.formatTimeOfDay(_endTime!)),
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
      seq: widget.todo.seq,
      id: widget.todo.id,
      startdate: DateTimeUtil.formatDate(_startSelectedDay),
      enddate: DateTimeUtil.formatDate(_endSelectedDay),
      title: titleController.text.trim(),
      task: taskController.text.trim(),
      starttime: DateTimeUtil.formatTimeOfDay(_startTime!),
      endtime: DateTimeUtil.formatTimeOfDay(_endTime!),
      end: widget.todo.end,
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
        Get.back();
        Get.back(result: true);
      },
    );
  }
} // class