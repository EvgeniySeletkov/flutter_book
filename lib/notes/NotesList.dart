import 'package:flutter/material.dart';
import 'NotesDBWorker.dart';
import 'package:flutter_book/notes/NotesModel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:scoped_model/scoped_model.dart';
import 'NotesModel.dart' show Note, NotesModel, notesModel;

class NotesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<NotesModel>(
        model: notesModel,
        child: ScopedModelDescendant<NotesModel>(
          builder: (BuildContext context, Widget? child, NotesModel model) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  notesModel.entityBeingEdited = Note();
                  notesModel.setColor(null);
                  notesModel.setStackIndex(1);
                },
              ),
              body: ListView.builder(
                itemCount: notesModel.entityList.length,
                itemBuilder: (BuildContext context, int index) {
                  Note note = notesModel.entityList[index];
                  var color = Colors.white;
                  switch (note.color) {
                    case "red":
                      color = Colors.red;
                      break;
                    case "green":
                      color = Colors.green;
                      break;
                    case "blue":
                      color = Colors.blue;
                      break;
                    case "yellow":
                      color = Colors.yellow;
                      break;
                    case "grey":
                      color = Colors.grey;
                      break;
                    case "purple":
                      color = Colors.purple;
                      break;
                  }
                  return Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Slidable(
                      endActionPane: ActionPane(
                        motion: DrawerMotion(),
                        extentRatio: 0.25,
                        children: [
                          SlidableAction(
                            label: "Delete",
                            backgroundColor: Colors.red,
                            icon: Icons.delete,
                            onPressed: (BuildContext context) {
                              _deleteNote(context, note);
                            },
                          ),
                        ],
                      ), 
                      child: Card(
                        elevation: 8,
                        color: color,
                        child: ListTile(
                          title: Text("${note.title}"),
                          subtitle: Text("${note.content}"),
                          onTap: () async {
                            notesModel.entityBeingEdited = await NotesDBWorker.db.get(note.id!);
                            notesModel.setColor(notesModel.entityBeingEdited.color);
                            notesModel.setStackIndex(1);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        )
    );
  }

  Future _deleteNote(BuildContext context, Note note) async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext alertContext) {
          return AlertDialog(
            title: Text("Delete Note"),
            content: Text("Are you sure you want to delete ${note.title}?"),
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
                  await NotesDBWorker.db.delete(note.id!);
                  Navigator.of(alertContext).pop();
                  ScaffoldMessenger.of(alertContext).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                        content: Text("Note deleted"),
                      )
                  );
                  notesModel.loadData("notes", NotesDBWorker.db);
                },
              )
            ],
          );
        }
     );
  }

}