import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlantScreen extends StatefulWidget {
  final int waterCount;
  const PlantScreen({super.key, required this.waterCount});
  @override
  State<PlantScreen> createState() => _PlantScreenState();
}

class _PlantScreenState extends State<PlantScreen> {
  int homeworkCount = 0;       // 오늘 완료한 숙제 수
  Set<int> studiedDays = {};   // 이번 달 공부한 날짜들

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';

    // 오늘 완료한 숙제 수
    final count = prefs.getInt('homeworkCount_$todayKey') ?? 0;

    // 이번 달 공부한 날짜 목록
    final monthKey = '${today.year}-${today.month}';
    final days = prefs.getStringList('studiedDays_$monthKey') ?? [];
    final dayInts = days.map((d) => int.tryParse(d) ?? 0).toSet();

    setState(() {
      homeworkCount = count;
      studiedDays = dayInts;
    });
  }

  String get plantEmoji {
    if (widget.waterCount == 0) return '🪹';
    if (widget.waterCount < 3) return '🌱';
    if (widget.waterCount < 7) return '🌿';
    return '🌸';
  }

  String get plantName {
    if (widget.waterCount == 0) return '빈 화분';
    if (widget.waterCount < 3) return '새싹이 돋았어요!';
    if (widget.waterCount < 7) return '잎사귀가 자랐어요!';
    return '꽃이 활짝 피었어요! 🎉';
  }

  // 오늘 숙제 완료 요약 문구
  String get homeworkSummary {
    if (homeworkCount == 0) return '아직 오늘 숙제를 안 했어요. 화이팅! 💪';
    if (homeworkCount == 1) return '오늘 숙제 1개 완료! 잘하셨어요 👍';
    if (homeworkCount == 2) return '오늘 숙제 2개 완료! 대단해요 🌟';
    return '오늘 숙제 ${homeworkCount}개 완료! 🎉 최고예요!';
  }

  Color get homeworkCardColor {
    if (homeworkCount == 0) return Colors.grey[100]!;
    if (homeworkCount < 3) return Colors.yellow[50]!;
    return Colors.green[50]!;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🪴 나의 화분'),
        backgroundColor: Colors.pink[400],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.pink[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ── 화분 상태 ──
            Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(plantEmoji,
                        style: const TextStyle(fontSize: 100)),
                    const SizedBox(height: 12),
                    Text(plantName,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink)),
                    const SizedBox(height: 8),
                    Text('물 준 횟수: ${widget.waterCount} 번',
                        style: const TextStyle(
                            fontSize: 20, color: Colors.black87)),
                    const SizedBox(height: 4),
                    const Text('숙제를 마치면 물을 줄 수 있어요! 🌱',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── 4번: 오늘 학습 요약 ──
            Card(
              elevation: 4,
              color: homeworkCardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 18, horizontal: 20),
                child: Row(
                  children: [
                    // 숙제 개수 원형 표시
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: homeworkCount == 0
                            ? Colors.grey[300]
                            : homeworkCount < 3
                                ? Colors.amber[300]
                                : Colors.green[400],
                      ),
                      child: Center(
                        child: Text(
                          '$homeworkCount',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📚 오늘의 학습 기록',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          const SizedBox(height: 6),
                          Text(homeworkSummary,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: homeworkCount == 0
                                      ? Colors.grey[600]
                                      : Colors.green[800],
                                  height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── 8번: 출석 달력 ──
            Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 달력 헤더
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_month,
                            color: Colors.pink, size: 26),
                        const SizedBox(width: 8),
                        Text(
                          '${now.year}년 ${now.month}월 출석 달력',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '⭐ 공부한 날  |  오늘: ${now.day}일',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),

                    // 요일 헤더
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['일', '월', '화', '수', '목', '금', '토']
                          .asMap()
                          .entries
                          .map((e) => SizedBox(
                                width: 36,
                                child: Text(
                                  e.value,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: e.key == 0
                                        ? Colors.red
                                        : e.key == 6
                                            ? Colors.blue
                                            : Colors.black87,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),

                    // 달력 본체
                    _buildCalendar(now),

                    const SizedBox(height: 12),
                    // 이번 달 총 공부일 수
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '이번 달 총 ${studiedDays.length}일 공부했어요! 🎊',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(DateTime now) {
    // 이번 달 1일의 요일 (0=일, 1=월 ... 6=토)
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 일요일=0
    final daysInMonth =
        DateTime(now.year, now.month + 1, 0).day;

    List<Widget> rows = [];
    int day = 1;

    for (int week = 0; week < 6; week++) {
      List<Widget> cells = [];
      for (int weekday = 0; weekday < 7; weekday++) {
        final cellIndex = week * 7 + weekday;
        if (cellIndex < firstWeekday || day > daysInMonth) {
          // 빈 칸
          cells.add(const SizedBox(width: 36, height: 36));
        } else {
          final thisDay = day;
          final isToday = thisDay == now.day;
          final isStudied = studiedDays.contains(thisDay);
          final isSunday = weekday == 0;
          final isSaturday = weekday == 6;

          cells.add(
            SizedBox(
              width: 36,
              height: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 날짜 숫자
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday
                          ? Colors.pink[400]
                          : isStudied
                              ? Colors.amber[100]
                              : Colors.transparent,
                      border: isToday
                          ? Border.all(
                              color: Colors.pink[600]!, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$thisDay',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isToday || isStudied
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isToday
                              ? Colors.white
                              : isSunday
                                  ? Colors.red[400]
                                  : isSaturday
                                      ? Colors.blue[400]
                                      : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  // 공부한 날 ⭐ 표시
                  if (isStudied)
                    const Text('⭐',
                        style: TextStyle(fontSize: 9))
                  else
                    const SizedBox(height: 9),
                ],
              ),
            ),
          );
          day++;
        }
      }
      rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: cells));
      if (day > daysInMonth) break;
    }

    return Column(children: rows);
  }
}