import 'package:flutter/material.dart';

// 날짜/시간 포맷 유틸 모음
class DateTimeUtil {
  // DateTime → "YYYY-MM-DD"
  static String formatDate(DateTime date) =>
      "${date.year.toString().padLeft(4, '0')}-"
      "${date.month.toString().padLeft(2, '0')}-"
      "${date.day.toString().padLeft(2, '0')}";

  // TimeOfDay → "HH:MM"
  static String formatTimeOfDay(TimeOfDay time) =>
      "${time.hour.toString().padLeft(2, '0')}:"
      "${time.minute.toString().padLeft(2, '0')}";

  // "YYYY-MM-DD" + "HH:MM" → DateTime
  static DateTime parseDateAndTime(String date, String time) {
    return DateTime.parse('$date $time:00');
  }

  // DateTime → "M월 D일"
  static String formatMonthDay(DateTime dt) {
    return '${dt.month}월 ${dt.day}일';
  }

  // DateTime → "M월 D일 HH:MM"
  static String formatMonthDayTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.month}월 ${dt.day}일 $h:$m';
  }

  // 오늘 날짜 "YYYY-MM-DD"
  static String todayYMD() {
    final now = DateTime.now();
    return formatDate(now);
  }

  static String formatRangeText(
    String startdate,
    String enddate,
    String start,
    String end,
  ) {
    final todayStr = todayYMD();

    DateTime startDT = parseDateAndTime(startdate, start);
    DateTime endDT = parseDateAndTime(enddate, end);

    if (!endDT.isAfter(startDT)) {
      endDT = endDT.add(const Duration(days: 1));
    }

    String formatTime(DateTime dt) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }

    final bool sameDay =
        startDT.year == endDT.year &&
        startDT.month == endDT.month &&
        startDT.day == endDT.day;

    if (sameDay) {
      if (startdate == todayStr) {
        // 오늘 + 같은 날 → 시간만
        return '${formatTime(startDT)} ~ ${formatTime(endDT)}';
      } else {
        // 같은 날이지만 오늘은 아님 → "M월 D일 HH:MM ~ HH:MM"
        return '${formatMonthDay(startDT)} '
               '${formatTime(startDT)} ~ ${formatTime(endDT)}';
      }
    } else {
      // 날짜가 다르면 양쪽 다 "M월 D일 HH:MM"
      final startStr = formatMonthDayTime(startDT);
      final endStr = formatMonthDayTime(endDT);
      return '$startStr ~ $endStr';
    }
  }
}
