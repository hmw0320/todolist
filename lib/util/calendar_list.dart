import 'package:flutter/material.dart';

class CalendarList extends StatelessWidget {
  final DateTime startDate;                       // 시작 날짜
  final int dayCount;                             // 총 날짜 개수
  final DateTime selectedDay;                     // 선택된 날짜
  final ValueChanged<DateTime> onDaySelected;     // 날짜 선택 시 OverView로

  const CalendarList({
    super.key,
    required this.startDate,
    required this.dayCount,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dayCount,
        itemBuilder: (context, index) {
          final day = startDate.add(Duration(days: index));

          final bool isSelected =
              day.year == selectedDay.year &&
              day.month == selectedDay.month &&
              day.day == selectedDay.day;

          final DateTime today = DateTime.now();
          final bool isToday =
              day.year == today.year &&
              day.month == today.month &&
              day.day == today.day;

          return GestureDetector(
            onTap: () {
              onDaySelected(day);
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue[700]
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: isToday
                    ? Border.all(color: Colors.lightBlue, width: 2)
                    : null,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ['일', '월', '화', '수', '목', '금', '토'][day.weekday % 7],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                  Text(
                    day.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
