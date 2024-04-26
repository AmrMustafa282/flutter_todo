import 'package:flutter_1/todos.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHandler {
  static Database? _db;

  static const String DATABASE = 'mydatabase.db';
  static const int VERSION = 1;
  static const String TABLE_TODOS = 'todos';
  static const String ID = 'id';
  static const String TEXT = 'text';
  static const String DONE = 'done';

  get db async {
    if (_db == null) {
      String path = join(await getDatabasesPath(), DATABASE);
      _db = await openDatabase(path,
          version: VERSION, onCreate: _onCreate, onUpgrade: _onUpgrade);
    }
    return _db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        'create table $TABLE_TODOS ($ID integer primary key, $TEXT text , $DONE integer)');
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('drop table $TABLE_TODOS');
    await _onCreate(db, newVersion);
  }

  Future<Todo> create(Todo todo) async {
    Database dbClient = await db;
    int id = await dbClient.insert(
        TABLE_TODOS, {'id': todo.id, 'text': todo.text, 'done': todo.done});
    todo.id = id;
    return todo;
  }

  Future<List<Todo>> read() async {
    Database dbClient = await db;
    List<Map> res =
        await dbClient.query(TABLE_TODOS, columns: [ID, TEXT, DONE]);
    List<Todo> todos = [];
    if (res.length > 0) {
      for (var i = 0; i < res.length; i++) {
        Map map = res[i];
        Todo todo = Todo(map['id'], map['text'], map['done']);
        todos.add(todo);
      }
    }
    return todos;
  }

  void delete(todoId) async {
    Database dbClient = await db;
    await dbClient.delete(TABLE_TODOS, where: '$ID=?', whereArgs: [todoId]);
  }

  Future<Todo> update(Todo todo) async {
    Database dbClient = await db;
    await dbClient.update(TABLE_TODOS, {'text': todo.text, 'done': todo.done},
        where: '$ID=?', whereArgs: [todo.id]);
    return todo;
  }
}
