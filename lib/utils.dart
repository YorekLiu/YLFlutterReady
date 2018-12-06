import 'package:intl/intl.dart';

String formatDate(DateTime dateTime) {
  var dateFormat = DateFormat('yyyy-MM-dd');
  return dateFormat.format(dateTime);
}

String weekday(DateTime dateTime) {
  /**
   * static const int monday = 1;
    static const int tuesday = 2;
    static const int wednesday = 3;
    static const int thursday = 4;
    static const int friday = 5;
    static const int saturday = 6;
    static const int sunday = 7;
   */
  return <int, String> {
    DateTime.monday : "Monday",
    DateTime.tuesday : "tuesday",
    DateTime.wednesday : "wednesday",
    DateTime.thursday : "thursday",
    DateTime.friday : "friday",
    DateTime.saturday : "saturday",
    DateTime.sunday : "sunday",
  }[dateTime.weekday - 1];
}

String duration(DateTime dateTime) {
  int count = 0;
  Duration duration = dateTime.difference(DateTime.now());
  String suffix = duration.isNegative ? " ago" : "";

  StringBuffer stringBuffer = StringBuffer();
  var days = duration.inDays;
  if (days != 0) {
    count++;
    stringBuffer.write("${days.abs()}d");
    duration -= Duration(days: days);
  }

  var hours = duration.inHours;
  if (hours != 0 || days != 0) {
    count++;
    if (days != 0) {
      stringBuffer.write(" ");
    }
    stringBuffer.write("${hours.abs()}h");
    duration -= Duration(hours: hours);
  }

  var minutes = duration.inMinutes;
  if (count < 2 && (minutes != 0 || hours != 0 || days != 0)) {
    count++;
    if (hours != 0) {
      stringBuffer.write(" ");
    }
    stringBuffer.write("${minutes.abs()}m");
    duration -= Duration(minutes: minutes);
  }

  var seconds = duration.inSeconds;
  if (count < 2) {
    count++;
    if (minutes != 0) {
      stringBuffer.write(" ");
    }
    stringBuffer.write("${seconds.abs()}s");
    duration -= Duration(seconds: seconds);
  }

  stringBuffer.write(suffix);

  return stringBuffer.toString();
}