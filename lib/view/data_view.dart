import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:todolist_app/vm/database_handler.dart';
import 'package:todolist_app/util/data.dart'; // DayStat, ProgressCard

class DataView extends StatefulWidget {
  final String userid;
  const DataView({super.key, required this.userid});

  @override
  State<DataView> createState() => DataViewState();
}

class DataViewState extends State<DataView> {
  late DatabaseHandler handler;

  double _todayPercent = 0;
  double _weekPercent = 0;

  List<DayStat> _weekBarStats = [];
  List<DayStat> _weekLineStats = [];

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    _loadData();
  }

  Future<void> _loadData() async {
    // 완료 상태 먼저 업데이트
    await handler.updateEnd(widget.userid);

    // 오늘 통계
    final todayCounts = await handler.getTodayTaskCounts(widget.userid);
    final tTotal = todayCounts['total'] ?? 0;
    final tCompleted = todayCounts['completed'] ?? 0;
    _todayPercent = tTotal == 0 ? 0 : (tCompleted / tTotal) * 100;

    // 이번 주 통계
    final weekCounts = await handler.getWeekTaskCounts(widget.userid);
    final wTotal = weekCounts['total'] ?? 0;
    final wCompleted = weekCounts['completed'] ?? 0;
    _weekPercent = wTotal == 0 ? 0 : (wCompleted / wTotal) * 100;

    // 요일별 통계
    final weekStats = await handler.getWeekDailyStats(widget.userid);

    final labels = ["월", "화", "수", "목", "금", "토", "일"];
    final values = List<int>.filled(7, 0);
    final lineValues = List<int>.filled(7, 0);

    for (final row in weekStats) {
      final date = row['date'] as String;
      final total = (row['total'] as int?) ?? 0;
      final completed = (row['completed'] as int?) ?? 0;

      final dt = DateTime.parse(date);
      final index = dt.weekday - 1; // 월=1 → 0, ..., 일=7 → 6

      if (index >= 0 && index < 7) {
        values[index] = total;
        lineValues[index] = completed;
      }
    }

    _weekBarStats = List.generate(
      7,
      (i) => DayStat(label: labels[i], value: values[i].toDouble()),
    );

    _weekLineStats = List.generate(
      7,
      (i) => DayStat(label: labels[i], value: lineValues[i].toDouble()),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("통계"),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 오늘 진행률 카드 ---------------------------------------------
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ProgressCard(
                title: "오늘 진행률",
                subtitle: "오늘 완료 / 전체 일정",
                percent: _todayPercent,
              ),
            ),

            // 이번 주 진행률 카드 -----------------------------------------
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: ProgressCard(
                title: "이번 주 진행률",
                subtitle: "이번 주 완료 / 전체 일정",
                percent: _weekPercent,
              ),
            ),

            // 섹션 타이틀 : 요일별 일정 수 --------------------------------
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                "요일별 일정 수",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 바 차트 -----------------------------------------------------
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: SizedBox(
                height: 220,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(),
                  series: <ColumnSeries<DayStat, String>>[
                    ColumnSeries<DayStat, String>(
                      dataSource: _weekBarStats,
                      xValueMapper: (DayStat d, _) => d.label,
                      yValueMapper: (DayStat d, _) => d.value,
                      borderRadius: BorderRadius.circular(6),
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 섹션 타이틀 : 요일별 완료 수 --------------------------------
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                "요일별 완료 수",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 라인 차트 (완료 수, 라벨 포함) ------------------------------
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                height: 220,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(),
                  series: <LineSeries<DayStat, String>>[
                    LineSeries<DayStat, String>(
                      dataSource: _weekLineStats,
                      xValueMapper: (DayStat d, _) => d.label,
                      yValueMapper: (DayStat d, _) => d.value,
                      markerSettings: MarkerSettings(isVisible: true),
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true, // 점 위에 숫자 표시
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
