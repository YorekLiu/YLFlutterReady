import 'package:flutter/material.dart';

import '../../utils.dart';
import '../../data/task.dart';
import '../../data/db/dbmanager.dart';
import '../../data/provider/task_provider.dart';

class TaskDetailOrAddForm extends StatefulWidget {

  final Task task;

  TaskDetailOrAddForm({Key key, this.task}) : super(key: key);

  @override
  createState() => _TaskDetailOrAddFormState();
}

class _TaskDetailOrAddFormState extends State<TaskDetailOrAddForm> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController titleController;
  TextEditingController currentCountController;
  TextEditingController totalCountController;
  int deadline;
  TextEditingController messageController;

  FocusNode currentFocusNode;
  FocusNode totalFocusNode;
  FocusNode messageFocusNode;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task?.title ?? "");
    currentCountController = TextEditingController(text: widget.task?.currentCount?.toString() ?? "0");
    totalCountController = TextEditingController(text: widget.task?.totalCount?.toString() ?? "");
    deadline = widget.task?.deadline ?? DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch;
    messageController = TextEditingController(text: widget.task?.message ?? "");

    currentFocusNode = FocusNode();
    totalFocusNode = FocusNode();
    messageFocusNode = FocusNode();
  }

  @override
  void dispose() {
    titleController.dispose();
    currentCountController.dispose();
    totalCountController.dispose();
    messageController.dispose();

    currentFocusNode.dispose();
    totalFocusNode.dispose();
    messageFocusNode.dispose();

    super.dispose();
  }

  _fieldFocusChange(BuildContext context, FocusNode from, FocusNode to) {
    FocusScope.of(context).requestFocus(to);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'New Task' : ''),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: '保存Task',
            onPressed: () => _saveTaskAndPop(context),
          )
        ],
      ),
      body: _buildForm(context)
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildTitleForm(context),
              Divider(
                height: 1.0,
                color: Colors.black26,
              ),
              _buildCountForm(context),
              Divider(
                height: 1.0,
                color: Colors.black26,
              ),
              _buildDeadLineForm(context),
              Divider(
                height: 1.0,
                color: Colors.black26,
              ),
              _buildMessageForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleForm(BuildContext context) {
    return TextFormField(
      controller: titleController,
      style: Theme.of(context).textTheme.headline,
      validator: (value) {
        if (value.isEmpty) {
          return '请输入标题';
        }
      },
      autofocus: widget.task == null,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (text) => _fieldFocusChange(context, null, currentFocusNode),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: '输入标题',
        hintStyle: Theme.of(context).textTheme.headline.copyWith(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 56.0, vertical: 16.0),
      ),
    );
  }

  Widget _buildCountForm(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(16.0),
          child: Icon(Icons.show_chart, color: Colors.grey,),
        ),
        Expanded(
          child: TextFormField(
            controller: currentCountController,
            style: Theme.of(context).textTheme.subhead,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            focusNode: currentFocusNode,
            onFieldSubmitted: (text) => _fieldFocusChange(context, currentFocusNode, totalFocusNode),
            validator: (value) {
              int count = int.tryParse(value);
              if (count == null || count < 0) {
                return "次数必须为正整数";
              }
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: '已完成次数',
              hintStyle: Theme.of(context).textTheme.subhead.copyWith(color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: totalCountController,
            style: Theme.of(context).textTheme.subhead,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            focusNode: totalFocusNode,
            onFieldSubmitted: (text) => _fieldFocusChange(context, totalFocusNode, messageFocusNode),
            validator: (value) {
              int count = int.tryParse(value);
              if (count == null || count < 0) {
                return "次数必须为正整数";
              }
              int currentCount = int.tryParse(currentCountController.text);
              if (currentCount == null || currentCount < 0) {
                return "已完成次数填写错误";
              }
              if (currentCount > count) {
                return "已完成次数不能大于总次数";
              }
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: '总次数',
              hintStyle: Theme.of(context).textTheme.subhead.copyWith(color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeadLineForm(BuildContext context) {
    return Tooltip(
      message: '设置Task截止时间',
      child: InkWell(
        onTap: () {
          showDatePicker(
            context: context,
            initialDate: DateTime.fromMillisecondsSinceEpoch(deadline),
            firstDate: DateTime(2016),
            lastDate: DateTime(2050)
          ).then((DateTime value) {
            setState(() {
              deadline = value.millisecondsSinceEpoch;
            });
          });
        },
        child: Container(
          height: 56.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(Icons.timer_off, color: Colors.grey,),
              ),
              Text(
                formatDate(DateTime.fromMillisecondsSinceEpoch(deadline)),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        )
      ),
    );
  }

  Widget _buildMessageForm(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(16.0),
            child: Icon(Icons.event_note, color: Colors.grey,),
          ),
          Expanded(
            child: TextFormField(
              controller: messageController,
              style: Theme.of(context).textTheme.body1,
              maxLines: 10,
              textInputAction: TextInputAction.done,
              focusNode: messageFocusNode,
              onFieldSubmitted: (text) => _saveTaskAndPop(context),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '描述',
                hintStyle: Theme.of(context).textTheme.body1.copyWith(color: Colors.grey),
                contentPadding: const EdgeInsets.fromLTRB(0.0, 16.0, 16.0, 16.0),
              ),
            ),
          )
        ],
      ),
    );
  }

  _saveTaskAndPop(BuildContext context) {
    if (_formKey.currentState.validate()) {
      _saveTask(context);
      Navigator.pop(context, true);
    }
  }

  _saveTask(BuildContext context) async {
    var db = await DBManager().db;

    if (widget.task == null) {
      // insert new task
      Task newTask = Task();
      setTask(newTask);
      return await TaskProvider.insert(db, newTask);
    } else {
      // update task
      setTask(widget.task);
      return await TaskProvider.update(db, widget.task, widget.task.currentCount);
    }
  }

  void setTask(Task task) {
    task
      ..title = titleController.text
      ..message = messageController.text
      ..currentCount = int.tryParse(currentCountController.text) ?? 0
      ..totalCount = int.tryParse(totalCountController.text) ?? 0
      ..deadline = deadline;
  }
}