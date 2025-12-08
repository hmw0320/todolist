import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todolist_app/model/todo_list.dart';
import 'package:todolist_app/model/user_list.dart';
import 'package:todolist_app/util/datetime.dart';

class DatabaseHandler {
  // Connection, Table Creation : UserList, TodoList
  Future<Database> initializeDB() async{
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'todolist.db'),
      onCreate: (db, version) async{
        await db.execute(
          """
          create table userlist
          (
            id text primary key,
            pw text,
            name text,
            image blob
          )
          """
        );
        await db.execute(
          """
          create table todolist
          (
            seq integer primary key autoincrement,
            id text,
            startdate text,
            enddate text,
            title text,
            task text,
            starttime text,
            endtime text,
            end integer default 0
          )
          """
        );
      },
      version: 1
    );
  }

  // Insert : UserList
  Future<int> insertUserList(UserList user) async{
    int result = 0;
    final Database db = await initializeDB();
    result = await db.rawInsert(
      """
      insert into userlist
      (id, pw, name, image)
      values
      (?,?,?,?)
      """,
      [user.id, user.pw, user.name, user.image]
    );
    return result;
  } 

  // Login Check
  Future<bool> login(String id, String pw) async {
    final Database db = await initializeDB();
    final List<Map<String, dynamic>> result = await db.rawQuery(
      """
      select * from userlist
      where id = ? and pw = ?
      """,
      [id, pw]
    );
    return result.isNotEmpty;
  }

  // Insert : TodoList
  Future<int> insertTodoList(TodoList todo) async{
    int result = 0;
    final Database db = await initializeDB();
    result = await db.rawInsert(
      """
      insert into todolist
      (id, startdate, enddate, title, task, starttime, endtime)
      values
      (?,?,?,?,?,?,?)
      """,
      [todo.id, todo.startdate, todo.enddate, todo.title, todo.task, todo.starttime, todo.endtime]
    );
    return result;
  } 

  // Query : UserList
  Future<List<UserList>> queryUserList(String userid) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult =
        await db.rawQuery(
          """
          select * from userlist
          where id = ?
          """,
          [userid]
        );
    return queryResult.map((e) => UserList.fromMap(e)).toList();
  }

  // Query : TodoList
  Future<List<TodoList>> queryTodoList(String userid) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult =
        await db.rawQuery(
          """
          select * from todolist
          where id = ? and "end" = 0
          order by enddate asc, endtime asc
          """,
          [userid]
        );
    return queryResult.map((e) => TodoList.fromMap(e)).toList();
  }

  // Query : TodoList by Date
  Future<List<TodoList>> queryTodoListDate(String userid, String date) async {
    final db = await initializeDB();
    final result = await db.rawQuery(
      """
      select * from todolist
      where id = ? and startdate = ?
      order by end asc, starttime asc
      """,
      [userid, date],
    );
    return result.map((e) => TodoList.fromMap(e)).toList();
  }

  // Query : TodoList by Date(Range)
  Future<List<TodoList>> queryTodoListDateRange(String userid, String selectedDate) async {
    final db = await initializeDB();

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      select * from todolist
      where id = ?
        and startdate <= ?
        and enddate >= ?
      order by startdate asc, starttime asc
      ''',
      [userid, selectedDate, selectedDate],
    );

    return result.map((e) => TodoList.fromMap(e)).toList();
  }

  // 오늘 완료, 총 일정 개수 조회
  Future<Map<String, int>> getTodayTaskCounts(String userid) async {
    final db = await initializeDB();

    final String today = DateTimeUtil.todayYMD();

    final List<Map<String, Object?>> result = await db.rawQuery(
      """
      select 
        count(*) as total,
        sum(case when "end" = 1 then 1 else 0 end) as completed
      from todolist
      where id = ? 
        and enddate = ?
      """,
      [userid, today],
    );

    if (result.isEmpty) {
      return {'total': 0, 'completed': 0};
    }

    final row = result.first;
    final int total = (row['total'] as int?) ?? 0;
    final int completed = (row['completed'] as int?) ?? 0;

    return {
      'total': total,
      'completed': completed,
    };
  }

  // Update : UserList (이미지 변경 X)
  Future<int> updateUserList(UserList user) async{
    int result = 0;
    final Database db = await initializeDB();
    result = await db.rawUpdate(
      """
      update userlist
      set name = ?
      where id = ?
      """,
      [user.name, user.id]
    );
    return result;
  }

  // Update : UserList (이미지 변경 O)
  Future<int> updateUserListAll(UserList user) async{
    int result = 0;
    final Database db = await initializeDB();
    result = await db.rawUpdate(
      """
      update userlist
      set name = ?, image = ?
      where id = ?
      """,
      [user.name, user.image, user.id]
    );
    return result;
  }

  // Update : TodoList
  Future<int> updateTodoList(TodoList todo) async{
    int result = 0;
    final Database db = await initializeDB();
    result = await db.rawUpdate(
      """
      update todolist
      set startdate = ?, enddate = ?, title = ?, task = ?, starttime = ?, endtime = ?
      where seq = ?
      """,
      [todo.startdate, todo.enddate, todo.title, todo.task, todo.starttime, todo.endtime, todo.seq]
    );
    return result;
  }

  Future<int> updateEnd(String userid) async {
    final db = await initializeDB();
    final now = DateTime.now();

    // 아직 완료 처리 안 된 일정만 가져오기
    final List<Map<String, dynamic>> rows = await db.rawQuery(
      """
      select seq, startdate, enddate, starttime, endtime
      from todolist
      where id = ? and "end" = 0
      """,
      [userid],
    );

    int updatedCount = 0;

    for (final row in rows) {
      final String startdate = row['startdate'] as String;
      final String enddate   = row['enddate'] as String;
      final String starttime = row['starttime'] as String;
      final String endtime   = row['endtime'] as String;

      // 문자열 → DateTime
      DateTime startDt = DateTimeUtil.parseDateAndTime(startdate, starttime);
      DateTime endDt = DateTimeUtil.parseDateAndTime(enddate, endtime);

      // endDt가 startDt보다 빠르면 하루 추가
      if (endDt.isBefore(startDt)) {
        endDt = endDt.add(Duration(days: 1));
      }

      // 현재 시간이 종료 시각을 지났으면 end = 1
      if (!now.isBefore(endDt)) {
        final int cnt = await db.rawUpdate(
          """
          update todolist
          set "end" = 1
          where seq = ?
          """,
          [row['seq']],
        );
        updatedCount += cnt;
      }
    }

    return updatedCount;
  }

  // End 검색
  Future<List<TodoList>> queryEndList(String userid) async {
    final db = await initializeDB();
    final result = await db.rawQuery(
      """
      select * from todolist
      where id = ? and "end" = 1
      order by enddate desc, endtime desc
      """,
      [userid],
    );
    return result.map((e) => TodoList.fromMap(e)).toList();
  }

  // 검색창에서 검색
  Future<List<TodoList>> searchTodoList(String userid, String keyword) async {
    final db = await initializeDB();

    final likeKeyword = '%$keyword%';

    final List<Map<String, Object?>> result = await db.rawQuery(
      """
      select *
      from todolist
      where id = ?
        and (title like ? or task like ?)
      order by startdate asc, starttime asc
      """,
      [userid, likeKeyword, likeKeyword],
    );

    return result.map((e) => TodoList.fromMap(e)).toList();
  }

    // 이번 주 완료, 총 일정 개수 조회
  Future<Map<String, int>> getWeekTaskCounts(String userid) async {
    final db = await initializeDB();
    final now = DateTime.now();

    // 이번 주 월요일, 일요일 계산
    final int weekday = now.weekday;
    final DateTime monday = now.subtract(Duration(days: weekday - 1));
    final DateTime sunday = monday.add(const Duration(days: 6));

    String fmt(DateTime d) =>
        "${d.year.toString().padLeft(4, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.day.toString().padLeft(2, '0')}";

    final String start = fmt(monday);
    final String end   = fmt(sunday);

    final List<Map<String, Object?>> result = await db.rawQuery(
      """
      select 
        count(*) as total,
        sum(case when "end" = 1 then 1 else 0 end) as completed
      from todolist
      where id = ?
        and enddate between ? and ?
      """,
      [userid, start, end],
    );

    if (result.isEmpty) {
      return {'total': 0, 'completed': 0};
    }

    final row = result.first;
    final int total     = (row['total'] as int?) ?? 0;
    final int completed = (row['completed'] as int?) ?? 0;

    return {
      'total': total,
      'completed': completed,
    };
  }

    // 이번 주 날짜별 total/completed 통계
  Future<List<Map<String, Object?>>> getWeekDailyStats(String userid) async {
    final db = await initializeDB();
    final now = DateTime.now();

    final int weekday = now.weekday;
    final DateTime monday = now.subtract(Duration(days: weekday - 1));
    final DateTime sunday = monday.add(const Duration(days: 6));

    String fmt(DateTime d) =>
        "${d.year.toString().padLeft(4, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.day.toString().padLeft(2, '0')}";

    final String start = fmt(monday);
    final String end   = fmt(sunday);

    final List<Map<String, Object?>> result = await db.rawQuery(
      """
      select 
        enddate as date,
        count(*) as total,
        sum(case when "end" = 1 then 1 else 0 end) as completed
      from todolist
      where id = ?
        and enddate between ? and ?
      group by enddate
      order by enddate asc
      """,
      [userid, start, end],
    );
    return result;
  }

  // Delete : UserList + TodoList
  Future<void> deleteUserAll(String userid) async {
    final db = await initializeDB();
    await db.rawDelete(
      """
      delete from todolist
      where id = ?
      """,
      [userid],
    );
    await db.rawDelete(
      """
      delete from userlist
      where id = ?
      """,
      [userid],
    );
  }

  // Delete : TodoList
  Future<void> deleteTodolist(int seq) async{
    final Database db = await initializeDB();
    await db.rawUpdate(
      """
        delete from todolist
        where seq = ?
      """,
      [seq]
    );
  }
}