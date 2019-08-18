import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

void main() => runApp(ToDoApp());

class ToDoApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: ToDo(title: 'To Do'),
    );
  }
}

class ToDo extends StatefulWidget {
  ToDo({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ToDoState createState() => _ToDoState();
}

class _ToDoState extends State<ToDo> {
  final _todo = <Task>[];

  /*build ToDoList*/
  Widget _buildToDoList() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _todo.length * 2,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();
          final index = i ~/ 2;
          return _buildTask(_todo[index]);
//            Dismissible(
//            key: Key("some id"),
//            background: Container(color: Colors.red),
//            child; _buildTask(_todo[index]),
//          );
        });
  }

  Widget _buildTask(Task task) {
    return ListTile(
      title: Text(
        task.title,
        style: TextStyle(fontSize: 20),
      ),
      subtitle: Text(task.description +
          "\n" +
          "開始日：" +
          (DateFormat.yMMMd()).format(task.startDay) +
          "\n" +
          "終了日：" +
          (DateFormat.yMMMd()).format(task.endDay)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _buildToDoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTask()),
          );
          if (result != null) {
            _todo.addAll(<Task>[]..length = 1);
            _todo[_todo.length - 1] = result;
          }
        },
        tooltip: 'Create new Task',
        child: Icon(Icons.add),
      ),
    );
  }
}

/*about a task*/
class Task {
  /*property*/
  int _id; //タスクを識別するためのID
  String _title; //タスク名
  String _description; //タスクの詳細
  DateTime _start_day = DateTime.now(); //開始日
  DateTime _end_day = DateTime.now(); //終了日
  bool _finish = false;

  /*constructor*/
  Task(
      this._id, this._title, this._description, this._start_day, this._end_day);

  /*getter*/
  int get id => _id;
  String get title => _title;
  String get description => _description;
  DateTime get startDay => _start_day;
  DateTime get endDay => _end_day;
  bool get isFinish => _finish;

  /*setter*/
  set id(int numberOfId) => _id = numberOfId;
  set title(String title) => _title = title;
  set description(String description) => _description = description;
  set startDay(DateTime startDay) => _start_day = startDay;
  set endDay(DateTime endDay) => _end_day = endDay;

  /*タスクを終了させる*/
  void finished() => _finish = true;
}

/*画面遷移先*/
class CreateTask extends StatefulWidget {
  CreateTask({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _CreateTaskState createState() => _CreateTaskState();
}

/*create task*/
class _CreateTaskState extends State<CreateTask> {
  int _id; //タスクを識別するためのID
  String _title; //タスク名
  String _description; //タスクの詳細
  DateTime _start_day = DateTime.now(); //開始日
  DateTime _end_day = DateTime.now(); //終了日
  Task task;

  final _formKey = GlobalKey<FormState>(); //各フォームを識別するためのキー

  /*各フォームの管理用のノード*/
  final titleFocus = FocusNode();
  final descriptionFocus = FocusNode();

  /*create task*/
  void _buildTask() {
    task = Task(_id, _title, _description, _start_day, _end_day);
  }

  /*タスク名の入植フォーム*/
  TextFormField titleFormField(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.next, //入力後の案内
      decoration: InputDecoration(labelText: 'タスク'), //ラベル
      focusNode: titleFocus, //フォーカスノード

      /*フォーカスフォーラム入力後どこにフォーカスするか*/
      onFieldSubmitted: (v) {
        FocusScope.of(context).requestFocus(descriptionFocus); //詳細の部分にフォーカス
      },

      /*入力内容のチェック*/
      validator: (value) {
        if (value.isEmpty) {
          //何も入力されていなかったら
          return 'タイトルを入力してください。';
        } else {
          return null;
        }
      },

      /*update title*/
      onSaved: (value) {
        setState(() {
          _title = value;
        });
      },
    );
  }

  TextFormField descriptionFormField(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.done, //入力後の案内
      decoration: InputDecoration(labelText: '詳細'), //ラベル
      focusNode: descriptionFocus, //フォーカスノード

      /*update description*/
      onSaved: (value) {
        setState(() {
          _description = value;
        });
      },
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2020),
    );
    if (selected != null) {
      setState(() {
        _start_day = selected;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2020),
    );
    if (selected != null) {
      setState(() {
        _end_day = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Task"),
      ),
      body: Form(
        key: _formKey,
        //padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            titleFormField(context),
            descriptionFormField(context),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RaisedButton(
                    child: Text("開始日：" + (DateFormat.yMMMd()).format(_start_day)),
                    onPressed: () {
                      _selectStartDate(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RaisedButton(
                    child: Text("終了日：" + (DateFormat.yMMMd()).format(_end_day)),
                    onPressed: () {
                      _selectEndDate(context);
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              child: RaisedButton(
                // 送信ボタンクリック時の処理
                onPressed: () {
                  // バリデーションチェック
                  if (_formKey.currentState.validate()) {
                    // 各フォームのonSavedに記述した処理を実行
                    // このsave()を呼び出さないと、onSavedは実行されないので注意
                    _formKey.currentState.save();
                    _buildTask();
                    Navigator.of(context).pop(task);
                  }
                },
                child: Text('タスクを追加'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
