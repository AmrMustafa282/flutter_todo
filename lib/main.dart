// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_1/databaseHandler.dart';
import 'package:flutter_1/todos.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Todo> _todos = [];
  _MyHomePageState() {
    _getTodos();
  }

  DatabaseHandler databaseHandler = DatabaseHandler();

  TextEditingController _todoController = TextEditingController();
  TextEditingController _todoController_2 = TextEditingController();

  void _addTodo() async {
    String newText = _todoController.text.trim();
    if (newText.isNotEmpty) {
      Todo todo = Todo(null, newText, 0);
      await databaseHandler.create(todo);
      print(10);
      setState(() {
        _todos.add(todo);
        _todoController.clear();
      });

      // SnackBar snackBar = SnackBar(
      //   content: Text('id: ${todo.id}, text:${todo.text}, done: ${todo.done}'),
      //   duration: Duration(seconds: 3),
      // );
    }
  }

  void _getTodos() async {
    var res = await databaseHandler.read();
    setState(() {
      _todos = res;
    });
  }

  void _deleteTodo(todo) {
    databaseHandler.delete(todo.id);
    setState(() {
      _todos.remove(todo);
    });
  }

  void _updateTodo(Todo todo) async {
    await databaseHandler.update(todo);
    setState(() {
      int index = _todos.indexWhere((element) => element.id == todo.id);
      if (index != -1) {
        _todos[index] = todo;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Today',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(_todos[index].text),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_note_outlined),
                        onPressed: () {
                          _todoController_2.text = _todos[index].text;
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: TextField(
                                  controller: _todoController_2,
                                  decoration: InputDecoration(
                                    hintText: 'Update todo',
                                  ),
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    onPressed: () {
                                      Todo todo = Todo(
                                          _todos[index].id,
                                          _todoController_2.text.trim(),
                                          _todos[index].done);
                                      setState(() {
                                        _updateTodo(todo);
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Text('Update'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteTodo(_todos[index]);
                        },
                      ),
                    ],
                  ),
                  leading: Checkbox(
                    value: _todos[index].done == 1 ? true : false,
                    onChanged: (value) {
                      setState(() {
                        _todos[index].done = value == true ? 1 : 0;
                        _updateTodo(_todos[index]);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.only(right: 16, bottom: 16),
            child: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: TextField(
                        controller: _todoController,
                        decoration: InputDecoration(
                          hintText: 'Enter a new todo',
                        ),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _addTodo();
                            });
                            Navigator.pop(context);
                          },
                          child: Text('Add'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Icon(Icons.add),
            ),
          )
        ],
      ),
    );
  }
}
