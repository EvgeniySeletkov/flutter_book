import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_book/appointments/AppointmentsDBWorker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'AppointmentsModel.dart' show AppointmentsModel, appointmentsModel;
import 'package:flutter_book/utils.dart' as utils;

class AppointmentsEntry extends StatelessWidget {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AppointmentsEntry() {
    _titleEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.title = _titleEditingController.text;
    });

    _descriptionEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.description = _descriptionEditingController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    _titleEditingController.text = appointmentsModel.entityBeingEdited?.title ?? "";
    _descriptionEditingController.text = appointmentsModel.entityBeingEdited?.description ?? "";

    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext context, Widget? child, AppointmentsModel model) {
          return Scaffold(
            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.subject),
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
                    leading: Icon(Icons.description),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      decoration: InputDecoration(hintText: "Decoration"),
                      controller: _descriptionEditingController,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.today),
                    title: Text("Date"),
                    subtitle: Text(
                      appointmentsModel.chosenDate == null
                          ? ""
                          : appointmentsModel.chosenDate!
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        String? chosenDate = await utils.selectDate(
                          context,
                          appointmentsModel,
                          appointmentsModel.entityBeingEdited.apptDate);
                        if (chosenDate != null) {
                          appointmentsModel.entityBeingEdited.apptDate = chosenDate;
                        }
                      },
                    ),
                  ),
                  ListTile(
                    title: Text("Time"),
                    leading: Icon(Icons.alarm),
                    subtitle: Text(
                      appointmentsModel.apptTime == null
                          ? ""
                          : appointmentsModel.apptTime!
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () {
                        _selectTime(context);
                      },
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
                      _save(context, appointmentsModel);
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future _selectTime(BuildContext context) async {
    var initialTime = TimeOfDay.now();
    if (appointmentsModel.entityBeingEdited.apptTime != null) {
       List timeParts = appointmentsModel.entityBeingEdited.apptTime.split(",");
       initialTime = TimeOfDay(
         hour: int.parse(timeParts[0]),
         minute: int.parse(timeParts[1]),
       );
    }
    var picked = await showTimePicker(
      context: context,
      initialTime: initialTime
    );
    if (picked != null) {
      appointmentsModel.entityBeingEdited.apptTime =
          "${picked.hour},${picked.minute}";
      appointmentsModel.setApptTime(picked.format(context));
    }
  }

  Future _save(BuildContext context, AppointmentsModel model) async {
    if (!_formKey.currentState!.validate()){
      return;
    }
    if (model.entityBeingEdited.id == null) {
      await AppointmentsDBWorker.db.create(appointmentsModel.entityBeingEdited);
    }
    else {
      await AppointmentsDBWorker.db.update(appointmentsModel.entityBeingEdited);
    }

    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);

    model.setStackIndex(0);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          content: Text("Appointments saved"),
        )
    );
  }
}