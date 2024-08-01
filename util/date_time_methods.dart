import 'package:intl/intl.dart';

class DateConvertor{

  static  dateToEventPageFormat(String date){
    DateTime dateTime = DateTime.parse(date).toLocal();
    String getDate = DateFormat("dd/MM/yy").format(dateTime);
    String time = DateFormat().add_Hm().format(dateTime);
    String formattedDate = "$getDate · $time";
    return formattedDate;
  }
  static  dateToDDMMYY(String date){
    DateTime dateTime = DateTime.parse(date);
    String getDate = DateFormat("dd/MM/yy").format(dateTime);
    return getDate;
  }

  static differenceBetweenNowToEvent(String date){
    DateTime dateTime = DateTime.parse(date);
    DateTime nowDateTime = DateTime.now();
    Duration difference = nowDateTime.difference(dateTime);
    int days = difference.inDays;
    int hours = difference.inHours.remainder(24);
    int minutes = difference.inMinutes.remainder(60);
    int seconds = difference.inSeconds.remainder(60);

   String returnString = "${days.toString().replaceAll("-", "")}d ${hours.toString().replaceAll("-", "")}h ${minutes.toString().replaceAll("-", "")}m' left";
    return returnString;
  }

 static  String convertTime(int time) {
    int centiseconds = (time % 1000) ~/ 10;
    time ~/= 1000;
    int seconds = time % 60;
    time ~/= 60;
    int minutes = time % 60;
    time ~/= 60;
    int hours = time;
    if (hours > 0) {
      return "$hours:${_twoDigits(minutes)}:${_twoDigits(seconds)}:${_twoDigits(centiseconds)}";
    } else if (minutes > 0) {
      return "$minutes:${_twoDigits(seconds)}:${_twoDigits(centiseconds)}";
    } else {
      return "$seconds:${_twoDigits(centiseconds)}";
    }
  }
 static String _twoDigits(int time) {
    return "${time<10?'0':''}$time";
  }


  static String displayTimeAgoFromTimestamp(String timestamp) {
    final year = int.parse(timestamp.substring(0, 4));
    final month = int.parse(timestamp.substring(5, 7));
    final day = int.parse(timestamp.substring(8, 10));
    final hour = int.parse(timestamp.substring(11, 13));
    final minute = int.parse(timestamp.substring(14, 16));

    final DateTime videoDate = DateTime(year, month, day, hour, minute);
    final int diffInHours = DateTime.now().difference(videoDate).inHours;

    String timeAgo = '';
    String timeUnit = '';
    int timeValue = 0;

    if (diffInHours < 1) {
      final diffInMinutes = DateTime.now().difference(videoDate).inMinutes;
      timeValue = diffInMinutes;
      timeUnit = 'minute';
    } else if (diffInHours < 24) {
      timeValue = diffInHours;
      timeUnit = 'hour';
    } else if (diffInHours >= 24 && diffInHours < 24 * 7) {
      timeValue = (diffInHours / 24).floor();
      timeUnit = 'day';
    } else if (diffInHours >= 24 * 7 && diffInHours < 24 * 30) {
      timeValue = (diffInHours / (24 * 7)).floor();
      timeUnit = 'week';
    } else if (diffInHours >= 24 * 30 && diffInHours < 24 * 12 * 30) {
      timeValue = (diffInHours / (24 * 30)).floor();
      timeUnit = 'month';
    } else {
      timeValue = (diffInHours / (24 * 365)).floor();
      timeUnit = 'year';
    }

    timeAgo = timeValue.toString() + ' ' + timeUnit;
    timeAgo += timeValue > 1 ? 's' : '';

    return timeAgo + ' ago';
  }



  static String getViews(int videoViews){
    if(videoViews < 1000){
      String views = "$videoViews";
      return views;
    }else{
      String viewAbove = "${videoViews}k";
      return viewAbove;
    }
  }
///Format january, 10,2023
  static dateForBottomSheet(String date){
    DateTime dateTime = DateTime.parse(date);
  return DateFormat.yMMMMd().format(dateTime);
  }

}


