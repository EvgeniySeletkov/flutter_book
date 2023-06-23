import 'package:flutter/material.dart';
import 'package:flutter_book/appointments/AppointmentsDBWorker.dart';
import 'package:flutter_book/appointments/AppointmentsModel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'AppointmentsModel.dart' show AppointmentsModel, appointmentsModel;

class AppointmentsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    EventList<Event> markedDateMap = EventList(events: Map());
    for (int i = 0; i < appointmentsModel.entityList.length; i++) {
      Appointment appointment = appointmentsModel.entityList[i];
      if (appointment.apptDate != null) {
        var dateParts = appointment.apptDate!.split(",");
        var apptDate = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        );
        markedDateMap.add(
            apptDate,
            Event(
              date: apptDate,
              icon: Container(
                decoration: BoxDecoration(color: Colors.blue),
              ),
            ),
        );
      }
    }

    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (context, child, model) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () async {
                appointmentsModel.entityBeingEdited = Appointment();
                var now = DateTime.now();
                appointmentsModel.entityBeingEdited.apptDate =
                    "${now.year},${now.month},${now.day}";
                appointmentsModel.setChosenDate(
                  DateFormat.yMMMMd("en_US")
                      .format(now.toLocal()));
                appointmentsModel.setApptTime(null);
                appointmentsModel.setStackIndex(1);
              },
            ),
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: CalendarCarousel<Event>(
                      thisMonthDayBorderColor: Colors.grey,
                      daysHaveCircularBorder: false,
                      markedDatesMap: markedDateMap,
                      onDayPressed: (DateTime date, List<Event> events) {
                        _showAppointments(date, context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAppointments(DateTime date, BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ScopedModel<AppointmentsModel>(
          model: appointmentsModel,
          child: ScopedModelDescendant<AppointmentsModel>(
            builder: (BuildContext context, Widget? child, AppointmentsModel model) {
              return Scaffold(
                body: Container(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: GestureDetector(
                      child: Column(
                        children: [
                          Text(
                            DateFormat.yMMMMd("en_US").format(date.toLocal()),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 24,
                            ),
                          ),
                          Divider(),
                          Expanded(
                            child: ListView.builder(
                              itemCount: appointmentsModel.entityList.length,
                              itemBuilder: (BuildContext context, int index) {
                                Appointment appointment = appointmentsModel.entityList[index];
                                if (appointment.apptDate !=
                                "${date.year},${date.month},${date.day}") {
                                  return Container(height: 0);
                                }
                                var apptTime = "";
                                if (appointment.apptTime != null) {
                                  var timeParts = appointment.apptTime!.split(",");
                                  var at = TimeOfDay(
                                    hour: int.parse(timeParts[0]),
                                    minute: int.parse(timeParts[1]),
                                  );
                                  apptTime = " (${at.format(context)})";
                                }
                                return Padding(
                                  padding: EdgeInsets.only(top: 4, bottom: 4),
                                  child: Slidable(
                                    endActionPane: ActionPane(
                                      motion: DrawerMotion(),
                                      extentRatio: 0.25,
                                      children: [
                                        SlidableAction(
                                          label: "Delete",
                                          icon: Icons.delete,
                                          backgroundColor: Colors.red,
                                          onPressed: (BuildContext context) async {
                                            _deleteAppointment(context, appointment);
                                          },
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      color: Colors.grey.shade300,
                                      child: ListTile(
                                        title: Text("${appointment.title}$apptTime"),
                                        subtitle: appointment.description == null
                                            ? null
                                            : Text("${appointment.description}"),
                                        onTap: () async {
                                          _editAppointment(context, appointment);
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }
    );
  }

  Future _deleteAppointment(BuildContext context, Appointment appointment) async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext alertContext) {
          return AlertDialog(
            title: Text("Delete Appointment"),
            content: Text("Are you sure you want to delete ${appointment.title}?"),
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
                  await AppointmentsDBWorker.db.delete(appointment.id!);
                  Navigator.of(alertContext).pop();
                  ScaffoldMessenger.of(alertContext).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                        content: Text("Appointment deleted"),
                      )
                  );
                  appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);
                },
              )
            ],
          );
        }
    );
  }

  Future _editAppointment(BuildContext context, Appointment appointment) async {
    appointmentsModel.entityBeingEdited = await AppointmentsDBWorker.db.get(appointment.id!);
    if (appointmentsModel.entityBeingEdited.apptDate == null) {
      appointmentsModel.setChosenDate(null);
    }
    else {
      List dateParts = appointmentsModel.entityBeingEdited.apptDate.split(",");
      var apptDate = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );
      appointmentsModel.setChosenDate(
        DateFormat.yMMMMd("en_US").format(apptDate.toLocal()));
      if (appointmentsModel.entityBeingEdited.apptTime == null) {
        appointmentsModel.setApptTime(null);
      }
      else {
        List timeApparts = appointmentsModel.entityBeingEdited.apptTime.split(",");
        var apptTime = TimeOfDay(
          hour: int.parse(timeApparts[0]),
          minute: int.parse(timeApparts[1])
        );
        appointmentsModel.setApptTime(apptTime.format(context));
      }
      appointmentsModel.setStackIndex(1);
      Navigator.pop(context);
    }
  }
}