import '../BaseModel.dart';

class Appointment {
  int? id;
  String? title;
  String? description;
  String? apptDate;
  String? apptTime;

  @override
  String toString() {
    return "{ id = $id, title = $title,"
        "description = $description,"
        "apptDate = $apptDate, apptTime = $apptTime}";
  }
}

class AppointmentsModel extends BaseModel<Appointment> {
  String? apptTime;

  void setApptTime(String? inApptTime) {
    apptTime = inApptTime;
    notifyListeners();
  }
}

var appointmentsModel = AppointmentsModel();