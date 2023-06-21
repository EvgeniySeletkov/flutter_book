import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'NotesDBWorker.dart';
import 'NotesModel.dart' show NotesModel, notesModel;

class NotesEntry extends StatelessWidget {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  NotesEntry() {
    _titleEditingController.addListener(() {
      notesModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _contentEditingController.addListener(() {
      notesModel.entityBeingEdited.content = _contentEditingController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    _titleEditingController.text = notesModel.entityBeingEdited?.title ?? "";
    _contentEditingController.text = notesModel.entityBeingEdited?.content ?? "";

    return ScopedModel(
        model: notesModel,
        child: ScopedModelDescendant<NotesModel>(
          builder: (BuildContext context, Widget? child, NotesModel model) {
            return Scaffold(
              body: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(Icons.title),
                      title: TextFormField(
                        decoration: InputDecoration(hintText: "Title"),
                        controller: _titleEditingController,
                        validator: (String? value) {
                          return value?.length == 0
                            ? "Please enter a title"
                            : null;
                        },
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.content_paste),
                      title: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 8,
                        decoration: InputDecoration(hintText: "Content"),
                        controller: _contentEditingController,
                        validator: (String? value) {
                          return value?.length == 0
                              ? "Please enter content"
                              : null;
                        },
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.color_lens),
                      title: Row(
                        children: [
                          GestureDetector(
                            child: Container(
                              decoration: ShapeDecoration(
                                shape: Border.all(
                                  width: 18,
                                  color: Colors.red
                                ) + Border.all(
                                  color: notesModel.color == "red"
                                      ? Colors.red
                                      : Theme.of(context).canvasColor,
                                ),
                              ),
                            ),
                            onTap: () {
                              notesModel.entityBeingEdited.color = "red";
                              notesModel.setColor("red");
                            },
                          ),
                          Spacer(),
                          GestureDetector(
                            child: Container(
                              decoration: ShapeDecoration(
                                shape: Border.all(
                                    width: 18,
                                    color: Colors.green
                                ) + Border.all(
                                  color: notesModel.color == "green"
                                      ? Colors.green
                                      : Theme.of(context).canvasColor,
                                ),
                              ),
                            ),
                            onTap: () {
                              notesModel.entityBeingEdited.color = "green";
                              notesModel.setColor("green");
                            },
                          ),
                          Spacer(),
                          GestureDetector(
                            child: Container(
                              decoration: ShapeDecoration(
                                shape: Border.all(
                                    width: 18,
                                    color: Colors.blue
                                ) + Border.all(
                                  color: notesModel.color == "blue"
                                      ? Colors.blue
                                      : Theme.of(context).canvasColor,
                                ),
                              ),
                            ),
                            onTap: () {
                              notesModel.entityBeingEdited.color = "blue";
                              notesModel.setColor("blue");
                            },
                          ),
                          Spacer(),
                          GestureDetector(
                            child: Container(
                              decoration: ShapeDecoration(
                                shape: Border.all(
                                    width: 18,
                                    color: Colors.yellow
                                ) + Border.all(
                                  color: notesModel.color == "yellow"
                                      ? Colors.yellow
                                      : Theme.of(context).canvasColor,
                                ),
                              ),
                            ),
                            onTap: () {
                              notesModel.entityBeingEdited.color = "yellow";
                              notesModel.setColor("yellow");
                            },
                          ),
                          Spacer(),
                          GestureDetector(
                            child: Container(
                              decoration: ShapeDecoration(
                                shape: Border.all(
                                    width: 18,
                                    color: Colors.grey
                                ) + Border.all(
                                  color: notesModel.color == "grey"
                                      ? Colors.grey
                                      : Theme.of(context).canvasColor,
                                ),
                              ),
                            ),
                            onTap: () {
                              notesModel.entityBeingEdited.color = "grey";
                              notesModel.setColor("grey");
                            },
                          ),
                          Spacer(),
                          GestureDetector(
                            child: Container(
                              decoration: ShapeDecoration(
                                shape: Border.all(
                                    width: 18,
                                    color: Colors.purple
                                ) + Border.all(
                                  color: notesModel.color == "purple"
                                      ? Colors.purple
                                      : Theme.of(context).canvasColor,
                                ),
                              ),
                            ),
                            onTap: () {
                              notesModel.entityBeingEdited.color = "purple";
                              notesModel.setColor("purple");
                            },
                          ),
                        ],
                      ),
                    )
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
                        _save(context, notesModel);
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

  Future _save(BuildContext context, NotesModel model) async {
    if (!_formKey.currentState!.validate()){
      return;
    }
    if (model.entityBeingEdited.id == null) {
      await NotesDBWorker.db.create(notesModel.entityBeingEdited);
    }
    else {
      await NotesDBWorker.db.update(notesModel.entityBeingEdited);
    }

    notesModel.loadData("notes", NotesDBWorker.db);

    model.setStackIndex(0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Notes saved"),
      )
    );
  }
}
