import 'package:flutter/material.dart';
import 'package:flutter_book/tasks/TasksDBWorker.dart';
import 'package:flutter_book/tasks/TasksModel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'TasksModel.dart' show Task, TasksModel, tasksModel;

class TasksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<TasksModel>(
        model: tasksModel,
        child: ScopedModelDescendant<TasksModel>(
          builder: (BuildContext context, Widget? child, TasksModel model) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  tasksModel.entityBeingEdited = Task();
                  tasksModel.setStackIndex(1);
                },
              ),
              body: ListView.builder(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                itemCount: tasksModel.entityList.length,
                itemBuilder: (BuildContext context, int index) {
                  Task task = tasksModel.entityList[index];
                  String dueDateString = "";
                  if (task.dueDate != null) {
                    var dateParts = task.dueDate!.split(",");
                    var dueDate = DateTime(
                      int.parse(dateParts[0]),
                      int.parse(dateParts[1]),
                      int.parse(dateParts[2]),
                    );
                    dueDateString = DateFormat.yMMMMd("en_US")
                        .format(dueDate.toLocal());
                  }
                  return Slidable(
                    endActionPane: ActionPane(
                      motion: DrawerMotion(),
                      extentRatio: 0.25,
                      children: [
                        SlidableAction(
                          label: "Delete",
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                          onPressed: (BuildContext context) {
                            _deleteNote(context, task);
                          },
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: task.completed == "true",
                        onChanged: (value) async {
                          task.completed = value.toString();
                          await TasksDBWorker.db.update(task);
                          tasksModel.loadData("tasks", TasksDBWorker.db);
                        },
                      ),
                      title: Text(
                        "${task.description}",
                        style: task.completed == "true"
                          ? TextStyle(
                              color: Theme.of(context).disabledColor,
                              decoration: TextDecoration.lineThrough,
                            )
                          : TextStyle(
                              color: Theme.of(context).textTheme.titleLarge?.color
                            ),
                      ),
                      subtitle: task.dueDate == null
                        ? null
                        : Text(
                            dueDateString,
                            style: task.completed == "true"
                              ? TextStyle(
                                  color: Theme.of(context).disabledColor,
                                  decoration:  TextDecoration.lineThrough,
                                )
                              : TextStyle(
                                  color: Theme.of(context).textTheme.titleMedium?.color
                                ),
                      ),
                      onTap: () async {
                        if (task.completed == "true") {
                          return;
                        }
                        tasksModel.entityBeingEdited = await TasksDBWorker.db.get(task.id!);
                        if (tasksModel.entityBeingEdited.dueDate == null) {
                          tasksModel.setChosenDate(null);
                        }
                        else {
                          tasksModel.setChosenDate(dueDateString);
                        }
                        tasksModel.setStackIndex(1);
                      },
                    )
                  );
                },
              )
            );
          },
        )
    );
  }

  Future _deleteNote(BuildContext context, Task task) async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext alertContext) {
          return AlertDialog(
            title: Text("Delete Task"),
            content: Text("Are you sure you want to delete this task?"),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(alertContext).pop(false);
                },
              ),
              TextButton(
                child: Text("Delete"),
                onPressed: () async {
                  await TasksDBWorker.db.delete(task.id!);
                  Navigator.of(alertContext).pop();
                  ScaffoldMessenger.of(alertContext).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                        content: Text("Task deleted"),
                      )
                  );
                  tasksModel.loadData("tasks", TasksDBWorker.db);
                },
              )
            ],
          );
        }
    );
  }

}