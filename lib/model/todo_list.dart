class TodoList {

  int? seq;          // PK,AI
  String id;         // UserId
  String date;     // 날짜
  String title;      // 일정 제목
  String task;       // 일정 내용
  String starttime;  // 시작 시간
  String endtime;    // 종료 시간
  bool fav;          // 즐겨찾기 여부
  bool end;          // 완료 여부


  TodoList(
    {
      this.seq,
      required this.id,
      required this.date,
      required this.title,
      required this.task,
      required this.starttime,
      required this.endtime,
      this.fav = false,
      this.end = false,
    }
  );

  TodoList.fromMap(Map<String, dynamic> res)
  : seq = res['seq'],
    id = res['id'],
    date = res['date'],
    title = res['title'],
    task = res['task'],
    starttime = res['starttime'],
    endtime = res['endtime'],
    fav = res['fav'] == 1 ? true : false,
    end = res['fav'] == 1 ? true : false;

}