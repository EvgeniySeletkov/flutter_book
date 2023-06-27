import 'dart:io';
import 'package:flutter_book/contacts/ContactsDBWorker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'ContactsModel.dart' show Contact, ContactsModel, contactsModel;
import 'package:flutter_book/utils.dart' as utils;

class ContactsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext context, Widget? inChild, ContactsModel model) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () async {
                var avatarFile = File(join(utils.docDir!.path, "avatar"));
                if (avatarFile.existsSync()) {
                  avatarFile.deleteSync();
                }
                contactsModel.entityBeingEdited = Contact();
                contactsModel.setChosenDate(null);
                contactsModel.setStackIndex(1);
              },
            ),
            body: ListView.builder(
              itemCount: contactsModel.entityList.length,
              itemBuilder: (BuildContext context, int index) {
                Contact contact = contactsModel.entityList[index];
                var avatarFile = File(join(utils.docDir!.path, contact.id.toString()));
                bool avataFileExists = avatarFile.existsSync();
                return Column(
                  children: [
                    Slidable(
                      endActionPane: ActionPane(
                        motion: DrawerMotion(),
                        extentRatio: 0.25,
                        children: [
                          SlidableAction(
                            label: "Delete",
                            backgroundColor: Colors.red,
                            icon: Icons.delete,
                            onPressed: (BuildContext context) {
                              _deleteContact(context, contact);
                            },
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigoAccent,
                          foregroundColor: Colors.white,
                          backgroundImage: avataFileExists
                            ? FileImage(avatarFile)
                            : null,
                          child: avataFileExists
                            ? null
                            : Text(contact.name!.substring(0, 1).toUpperCase()),
                        ),
                        title: Text("${contact.name}"),
                        subtitle: contact.phone == null
                          ? null
                          : Text("${contact.phone}"),
                        onTap: () async {
                          var avatarFile = File(join(utils.docDir!.path, "avatar"));
                          if (avatarFile.existsSync()) {
                            avatarFile.deleteSync();
                          }
                          contactsModel.entityBeingEdited = await ContactsDBWorker.db.get(contact.id!);
                          if (contactsModel.entityBeingEdited!.birthday == null) {
                            contactsModel.setChosenDate(null);
                          }
                          else {
                            List dateParts = contactsModel.entityBeingEdited!.birthday!.split(",");
                            var birthday = DateTime(
                              int.parse(dateParts[0]),
                              int.parse(dateParts[1]),
                              int.parse(dateParts[2]));
                            contactsModel.setChosenDate(
                              DateFormat.yMMMMd("en_US").format(birthday.toLocal())
                            );
                          }
                          contactsModel.setStackIndex(1);
                        },
                      ),
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future _deleteContact(BuildContext context, Contact contact) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext alertContext) {
        return AlertDialog(
          title: Text("Delete Contact"),
          content: Text(
            "Are you sure you want to delete ${contact.name}?"
          ),
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
                var avatarFile = File(join(utils.docDir!.path, contact.id.toString()));
                if (avatarFile.existsSync()) {
                  avatarFile.deleteSync();
                }
                await ContactsDBWorker.db.delete(contact.id!);
                Navigator.of(alertContext).pop();
                ScaffoldMessenger.of(alertContext).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                      content: Text("Contact deleted"),
                    )
                );
                contactsModel.loadData("contacts", ContactsDBWorker.db);
              },
            ),
          ],
        );
      }
    );
  }
}