import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'BaseModel.dart';

Directory? docDir;

Future selectDate(
    BuildContext context,
    BaseModel model,
    String? dateString) async {
  var initialDate = DateTime.now();
  if(dateString != null) {
    var dateParts = dateString.split(",");
    initialDate = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
    );
  }

  var picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
  );

  if(picked != null) {
    model.setChosenDate(
      DateFormat.yMMMMd("en_US").format(picked.toLocal())
    );
    return "${picked.year},${picked.month},${picked.day}";
  }
}