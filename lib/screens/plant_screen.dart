import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PlantScreen extends StatefulWidget {
  final int waterCount;
  const PlantScreen({super.key, required this.waterCount});
  @override
  State<PlantScreen> createState() => _PlantScreenState();
}

class _PlantScreenState extends State<PlantScreen> {
  int homeworkCount = 0;
  Set<int> studiedDays = {};
  int streakDays = 0;        // 🔥 연속 출석일
  String familyPhone = '';   // 가족 전화번호

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    final monthKey = '${today.year}-${today.month}';

    final count = prefs.getInt('homeworkCount_$todayKey') ?? 0;
    final days = prefs.getStringList('studiedDays_$monthKey') ?? [];
    final dayInts = days.map((d) => int.tryParse(d) ?? 0).toSet();
    final streak = prefs.getInt('streakDays') ?? 0;
    final phone = prefs.getString('familyPhone') ?? '';

    setState(() {
      homeworkCount = count;
      studiedDays = dayInts;
      streakDays = streak;
      familyPhone = phone;
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

  // 🔥 스트릭 이모지
  String get streakEmoji {
    if (streakDays == 0) return '😴';
    if (streakDays < 3) return '🌱';
    if (streakDays < 7) return '🔥';
    if (streakDays < 14) return '💪';
    if (streakDays < 30) return '⭐';
    return '👑';
  }

  // 📱 카톡으로 가족에게 공유
  Future<void> _shareToKakao() async {
    final today = DateTime.now();
    final message =
        '안녕하세요! 😊\n'
        '오늘 ${today.month}월 ${today.day}일 한글 공부를 했어요!\n\n'
        '📚 오늘 숙제: $homeworkCount개 완료\n'
        '🔥 연속 출석: $streakDays일째\n'
        '🌸 화분 상태: $plantName\n\n'
        '매일 열심히 공부하고 있어요! 💕';

    // 카카오톡 앱으로 공유 시도
    final kakaoUrl = Uri.parse(
        'kakaolink://send?text=${Uri.encodeComponent(message)}');
    // 일반 문자로 공유 (카카오톡 설치 안 된 경우)
    final smsUrl = Uri.parse(
        'sms:$familyPhone?body=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(kakaoUrl)) {
      await launchUrl(kakaoUrl);
    } else if (await canLaunchUrl(smsUrl)) {
      await launchUrl(smsUrl);
    } else {
      // 공유 텍스트만 보여주기
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text('📋 공유 내용'),
            content: SelectableText(
              message,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        );
      }
    }
  }

  // 가족 전화번호 저장
  Future<void> _saveFamilyPhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('familyPhone', phone);
    setState(() => familyPhone = phone);
  }

  // 전화번호 입력 다이얼로그
  void _showPhoneDialog() {
    final controller = TextEditingController(text: familyPhone);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('📱 가족 연락처 등록',
            style: TextStyle(fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '공부 완료 후 가족에게\n자동으로 알림을 보낼 수 있어요!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '예) 01012345678',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(fontSize: 18)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[400],
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              _saveFamilyPhone(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('저장', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
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
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── 🔥 연속 출석 스트릭 ──
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: streakDays >= 7
                        ? [Colors.orange[400]!, Colors.red[400]!]
                        : streakDays >= 3
                            ? [Colors.orange[300]!, Colors.amber[400]!]
                            : [Colors.grey[300]!, Colors.grey[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 20),
                child: Row(
                  children: [
                    Text(streakEmoji,
                        style: const TextStyle(fontSize: 52)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('연속 출석',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text(
                            '$streakDays일째 🔥',
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            streakDays == 0
                                ? '오늘 공부를 시작해보세요!'
                                : streakDays < 3
                                    ? '잘하고 있어요! 계속 해봐요!'
                                    : streakDays < 7
                                        ? '3일 연속! 불꽃이 피어나요! 🔥'
                                        : streakDays < 14
                                            ? '일주일 연속! 대단해요! 💪'
                                            : '${streakDays}일 연속! 진정한 한글 마스터! 👑',
                            style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── 오늘 학습 요약 ──
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
                                  fontWeight: FontWeight.bold)),
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

            // ── 📱 가족에게 공유 ──
            Card(
              elevation: 4,
              color: Colors.blue[50],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('💌',
                            style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('가족에게 공부 현황 알리기',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text(
                                '오늘 공부한 내용을\n가족에게 카톡/문자로 보내요!',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 전화번호 표시
                    if (familyPhone.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.phone,
                                size: 18, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(familyPhone,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _showPhoneDialog,
                              child: const Icon(Icons.edit,
                                  size: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        icon: const Icon(Icons.phone, size: 20),
                        label: const Text('가족 연락처 등록하기',
                            style: TextStyle(fontSize: 16)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _showPhoneDialog,
                      ),
                    const SizedBox(height: 12),
                    // 공유 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send, size: 22),
                        label: const Text('공부 현황 보내기',
                            style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[600],
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 3,
                        ),
                        onPressed: _shareToKakao,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── 출석 달력 ──
            Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
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
                    _buildCalendar(now),
                    const SizedBox(height: 12),
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
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    List<Widget> rows = [];
    int day = 1;

    for (int week = 0; week < 6; week++) {
      List<Widget> cells = [];
      for (int weekday = 0; weekday < 7; weekday++) {
        final cellIndex = week * 7 + weekday;
        if (cellIndex < firstWeekday || day > daysInMonth) {
          cells.add(const SizedBox(width: 36, height: 40));
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
                  if (isStudied)
                    const Text('⭐', style: TextStyle(fontSize: 9))
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