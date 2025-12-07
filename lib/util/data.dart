import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// 요일(라벨) + 값
class DayStat {
  final String label;
  final double value;

  DayStat({
    required this.label,
    required this.value,
  });
}

/// RadialBar 에 들어갈 데이터
class ProgressData {
  final String label;
  final double value;

  ProgressData(this.label, this.value);
}

/// 오늘 / 이번주 진행률 카드
class ProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double percent; // 0~100

  const ProgressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final double clamped = percent.clamp(0, 100).toDouble();
    final String percentText = '${clamped.toStringAsFixed(0)}%';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // 텍스트 영역 ---------------------------------------------------
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // 부제
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    // 퍼센트 텍스트
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        percentText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 원형 진행률 ---------------------------------------------------
            SizedBox(
              width: 70,
              height: 70,
              child: SfCircularChart(
                margin: EdgeInsets.zero,
                series: <CircularSeries<ProgressData, String>>[
                  RadialBarSeries<ProgressData, String>(
                    dataSource: [
                      ProgressData('progress', clamped),
                    ],
                    xValueMapper: (ProgressData d, _) => d.label,
                    yValueMapper: (ProgressData d, _) => d.value,
                    maximumValue: 100,
                    innerRadius: '70%',
                    radius: '100%',
                    cornerStyle: CornerStyle.bothCurve,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                    ),
                    dataLabelMapper: (ProgressData d, _) =>
                        '${d.value.toStringAsFixed(0)}%',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
