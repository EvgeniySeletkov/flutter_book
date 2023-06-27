import 'dart:io';
import 'package:flutter_book/contacts/ContactsDBWorker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'ContactsModel.dart' show ContactsModel, contactsModel;
import 'package:flutter_book/utils.dart' as utils;

class ContactsEntry extends StatelessWidget {
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ContactsEntry() {
    _nameEditingController.addListener(() {
      contactsModel.entityBeingEdited!.name = _nameEditingController.text;
    });
    _phoneEditingController.addListener(() {
      contactsModel.entityBeingEdited!.phone = _phoneEditingController.text;
    });
    _emailEditingController.addListener(() {
      contactsModel.entityBeingEdited!.email = _emailEditingController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    _nameEditingController.text = contactsModel.entityBeingEdited?.name ?? "";
    _phoneEditingController.text = contactsModel.entityBeingEdited?.phone ?? "";
    _emailEditingController.text = contactsModel.entityBeingEdited?.email ?? "";

    return ScopedModel(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext context, Widget? child, ContactsModel model) {
          var avatarFile = File(join(utils.docDir!.path, "avatar"));
          if (!avatarFile.existsSync()
            && model.entityBeingEdited != null
            && model.entityBeingEdited!.id != null
          ) {
            avatarFile = File(join(utils.docDir!.path, model.entityBeingEdited!.id.toString()));
          }
          return Scaffold(
            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    title: avatarFile.existsSync() 
                      ? Image.file(avatarFile)
                      : Text("No avata image for this contact"),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () {
                        _selectAvatar(context);
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: "Name"),
                      controller: _nameEditingController,
                      validator: (String? value) {
                        if (value?.length == 0) {
                          return "Please enter a name";
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(hintText: "Phone"),
                      controller: _phoneEditingController,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(hintText: "Email"),
                      controller: _emailEditingController,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.today),
                    title: Text("Birthday"),
                    subtitle: Text(contactsModel.chosenDate == null
                      ? ""
                      : contactsModel.chosenDate!),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        var chosenDate = await utils.selectDate(
                            context,
                            contactsModel,
                            contactsModel.entityBeingEdited!.birthday);
                        if (chosenDate != null) {
                          contactsModel.entityBeingEdited!.birthday = chosenDate;
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
                      var avatarFile = File(join(utils.docDir!.path, "avatar"));
                      if (avatarFile.existsSync()) {
                        avatarFile.deleteSync();
                      }
                      FocusScope.of(context).requestFocus(FocusNode());
                      model.setStackIndex(0);
                    },
                  ),
                  Spacer(),
                  TextButton(
                    child: Text("Save"),
                    onPressed: () {
                      _save(context, model);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future _save(BuildContext context, ContactsModel model) async {
    if (!_formKey.currentState!.validate()){
      return;
    }
    int? id;
    if (model.entityBeingEdited!.id == null) {
      id = await ContactsDBWorker.db.create(contactsModel.entityBeingEdited!);
    }
    else {
      id = await ContactsDBWorker.db.update(contactsModel.entityBeingEdited!);
    }
    
    var avatarFile = File(join(utils.docDir!.path, "avatar"));
    if (avatarFile.existsSync()) {
      avatarFile.renameSync(join(utils.docDir!.path, id.toString()));
    }

    contactsModel.loadData("contacts", ContactsDBWorker.db);

    model.setStackIndex(0);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          content: Text("Notes saved"),
        )
    );
  }

  Future _selectAvatar(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: Text("Take a picture"),
                  onTap: () async {
                    var cameraImage = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                    );
                    if (cameraImage != null) {
                      var imageFile = File(cameraImage.path);
                      imageFile.copySync(join(utils.docDir!.path, "avatar"));
                      contactsModel.triggerRebuild();
                    }
                    Navigator.of(dialogContext).pop();
                  },
                ),
                GestureDetector(
                  child: Text("Select From Gallery"),
                  onTap: () async {
                    var galleryImage = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (galleryImage != null) {
                      var imageFile = File(galleryImage.path);
                      imageFile.copySync(join(utils.docDir!.path, "avatar"));
                      contactsModel.triggerRebuild();
                    }
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}