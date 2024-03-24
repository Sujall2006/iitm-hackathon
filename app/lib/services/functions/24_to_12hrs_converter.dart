import 'package:intl/intl.dart';

String convert24To12(String time24) {
  DateFormat dateFormat24 = DateFormat('HH:mm');
  DateTime dateTime = dateFormat24.parse(time24);

  DateFormat dateFormat12 = DateFormat('h:mm a');
  String time12 = dateFormat12.format(dateTime);

  return time12;
}
