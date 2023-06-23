import 'package:flutter/material.dart';
import 'package:flutter_book/appointments/AppointmentsDBWorker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'AppointmentsEntry.dart';
import 'AppointmentsList.dart';
import 'AppointmentsModel.dart' show AppointmentsModel, appointmentsModel;

class Appointments extends StatelessWidget {
  Appointments() {
    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext context, Widget? inChild, AppointmentsModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: [AppointmentsList(), AppointmentsEntry()],
          );
        },
      ),
    );
  }

}