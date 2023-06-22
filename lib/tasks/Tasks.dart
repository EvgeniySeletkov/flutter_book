import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'TasksDBWorker.dart';
import 'TasksEntry.dart';
import 'TasksList.dart';
import 'TasksModel.dart' show TasksModel, tasksModel;

class Tasks extends StatelessWidget {
  Tasks() {
    tasksModel.loadData("tasks", TasksDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TasksModel>(
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel>(
        builder: (BuildContext context, Widget? inChild, TasksModel inModel) {
          return IndexedStack(
            index: inModel.stackIndex,
            children: [TasksList(), TasksEntry()],
          );
        },
      ),
    );
  }

}