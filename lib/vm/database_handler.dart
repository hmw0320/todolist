import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todolist_app/model/todo_list.dart';
import 'package:todolist_app/model/user_list.dart';

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
            date text,
            title text,
            task text,
            starttime text,
            endtime text,
            fav integer default 0,
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
      (id, date, title, task, starttime, endtime)
      values
      (?,?,?,?,?,?)
      """,
      [todo.id, todo.date, todo.title, todo.task, todo.starttime, todo.endtime]
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
          order by date asc, endtime asc
          """,
          [userid]
        );
    return queryResult.map((e) => TodoList.fromMap(e)).toList();
  }

  // Query : TodoList by date
  Future<List<TodoList>> queryTodoListDate(String userid, String date) async {
  final db = await initializeDB();
  final result = await db.rawQuery(
    """
    select * from todolist
    where id = ? and date = ?
    order by starttime asc
    """,
    [userid, date],
  );
  return result.map((e) => TodoList.fromMap(e)).toList();
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
      set date = ?, set title = ?, set task = ?, set starttime = ?, set endtime = ?
      where seq = ?
      """,
      [todo.date, todo.title, todo.task, todo.starttime, todo.endtime, todo.seq]
    );
    return result;
  }

  // Fav 추가
  Future<int> updateFav(int seq, bool fav) async {
    final db = await initializeDB();
    return await db.rawUpdate(
      """
      update todolist
      set fav = ?
      where seq = ?
      """,
      [fav ? 1 : 0, seq],
    );
  }

  // Fav 검색
  Future<List<TodoList>> queryFavList(String userid) async {
    final db = await initializeDB();
    final result = await db.rawQuery(
      """
      select * from todolist
      where id = ? and fav = 1
      """,
      [userid],
    );
    return result.map((e) => TodoList.fromMap(e)).toList();
  }

  // End Update
  Future<int> updateEnd(String userid) async {
    final db = await initializeDB();

    final now = DateTime.now();
    final String today =
        "${now.year.toString().padLeft(4, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";
    final String currentTime =
        "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}";

    return await db.rawUpdate(
      """
      update todolist
      set "end" = 1
      where id = ?
        and "end" = 0
        and (
          date < ?
          or (date = ? and endtime <= ?)
        )
      """,
      [userid, today, today, currentTime],
    );
  }

  // End 검색
  Future<List<TodoList>> queryEndList(String userid) async {
    final db = await initializeDB();
    final result = await db.rawQuery(
      """
      select * from todolist
      where id = ? and "end" = 1
      """,
      [userid],
    );
    return result.map((e) => TodoList.fromMap(e)).toList();
  }

  // Delete : UserList
  Future<void> deleteUserlist(int id) async{
    final Database db = await initializeDB();
    await db.rawUpdate(
      """
        delete from userlist
        where id = ?
      """,
      [id]
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