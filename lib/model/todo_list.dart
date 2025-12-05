class TodoList {

  int? seq;          // PK,AI
  String id;         // UserId
  String startdate;       // 날짜
  String enddate;       // 날짜
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
      required this.startdate,
      required this.enddate,
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
    startdate = res['startdate'],
    enddate = res['enddate'],
    title = res['title'],
    task = res['task'],
    starttime = res['starttime'],
    endtime = res['endtime'],
    fav = res['fav'] == 1,
    end = res['end'] == 1;

}