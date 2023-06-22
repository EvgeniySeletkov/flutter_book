import 'package:flutter/material.dart';
import 'package:flutter_book/tasks/TasksDBWorker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_book/utils.dart' as utils;
import 'TasksModel.dart' show TasksModel, tasksModel;

class TasksEntry extends StatelessWidget {
  final TextEditingController _descriptionEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TasksEntry() {
    _descriptionEditingController.addListener(() {
      tasksModel.entityBeingEdited.description = _descriptionEditingController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    _descriptionEditingController.text = tasksModel.entityBeingEdited?.description ?? "";

    return ScopedModel(
        model: tasksModel,
        child: ScopedModelDescendant<TasksModel>(
          builder: (BuildContext context, Widget? child, TasksModel model) {
            return Scaffold(
              body: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(Icons.description),
                      title: TextFormField(
                        decoration: InputDecoration(hintText: "Description"),
                        controller: _descriptionEditingController,
                        validator: (String? value) {
                          return value?.length == 0
                              ? "Please enter a description"
                              : null;
                        },
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.today),
                      title: Text("Due Date"),
                      subtitle: Text(
                          tasksModel.chosenDate == null
                            ? ""
                            : tasksModel.chosenDate!
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          String? chosenDate = await utils.selectDate(
                              context,
                              tasksModel,
                              tasksModel.entityBeingEdited.dueDate);
                          if (chosenDate != null) {
                            tasksModel.entityBeingEdited.dueDate = chosenDate;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 10,
                ),
                child: Row(
                  children: [
                    TextButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        model.setStackIndex(0);
                      },
                    ),
                    Spacer(),
                    TextButton(
                      child: Text("Save"),
                      onPressed: () {
                        _save(context, tasksModel);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        )
    );
  }

  Future _save(BuildContext context, TasksModel model) async {
    if (!_formKey.currentState!.validate()){
      return;
    }
    if (model.entityBeingEdited.id == null) {
      await TasksDBWorker.db.create(tasksModel.entityBeingEdited);
    }
    else {
      await TasksDBWorker.db.update(tasksModel.entityBeingEdited);
    }

    tasksModel.loadData("tasks", TasksDBWorker.db);

    model.setStackIndex(0);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          content: Text("Tasks saved"),
        )
    );
  }
}