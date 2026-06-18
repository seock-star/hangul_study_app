import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:flutter_application_1/screens/forced_quiz_screen.dart';
import 'package:flutter_application_1/screens/plant_screen.dart';
import 'package:flutter_application_1/screens/study/study_menu_screen.dart';
import 'package:flutter_application_1/screens/practice/practice_menu_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final ValueNotifier<double> fontScaleNotifier = ValueNotifier<double>(1.0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  fontScaleNotifier.value = prefs.getDouble('fontScale') ?? 1.0;

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings);

  runApp(const HangulApp());
}

class HangulApp extends StatelessWidget {
  const HangulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: fontScaleNotifier,
      builder: (_, scale, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '기초 한글 공부',
          theme: ThemeData(
            primarySwatch: Colors.green,
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontSize: 16 * scale),
              bodyMedium: TextStyle(fontSize: 14 * scale),
              titleLarge: TextStyle(fontSize: 22 * scale),
              titleMedium: TextStyle(fontSize: 18 * scale),
            ),
          ),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
              ),
              child: child!,
            );
          },
          home: const HomeScreen(),
        );
      },
    );
  }
}

// ============================================================
// 홈 화면
// ============================================================
String _currentDateTime = '';
late final _timer;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts flutterTts = FlutterTts();
  String todayWord = '';
  List<String> wordList = ['단어 불러오는 중...'];
  int waterCount = 0;
  bool _showFontSetting = false;

  @override
  void initState() {
    super.initState();
    _setKoreanVoice();
    _loadWordsFromFile();
    _setupAlarms();
    _loadPlant();
    _updateDateTime();
    _timer = Stream.periodic(const Duration(seconds: 1))
        .listen((_) => _updateDateTime());
         // 🌟 앱 켤 때 강제 퀴즈 체크 (4시간마다)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkForcedQuiz();
  });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _loadPlant() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => waterCount = prefs.getInt('waterCount') ?? 0);
  }

  void _updateDateTime() {
    final now = DateTime.now();
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[now.weekday - 1];
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    setState(() {
      _currentDateTime =
          '${now.year}년 ${now.month}월 ${now.day}일 $weekday요일\n$hour : $minute : $second';
    });
  }

  Future<void> _loadWordsFromFile() async {
    final fileText = await rootBundle.loadString('assets/words.txt');
    setState(() {
      wordList = fileText
          .split(RegExp(r'[,\n]'))
          .map((w) => w.trim())
          .where((w) => w.isNotEmpty && !w.startsWith('['))
          .toList();
      _pickRandomWord();
    });
  }
// 🌟 4시간마다 강제 퀴즈 체크
Future<void> _checkForcedQuiz() async {
  final prefs = await SharedPreferences.getInstance();
  final now = DateTime.now();
  final lastQuizTime = prefs.getInt('lastQuizTime') ?? 0;
  final lastQuizDateTime =
      DateTime.fromMillisecondsSinceEpoch(lastQuizTime);
  final hoursSinceLastQuiz =
      now.difference(lastQuizDateTime).inHours;

  // 4시간 이상 지났으면 강제 퀴즈
  if (hoursSinceLastQuiz >= 4) {
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ForcedQuizScreen(
            onComplete: () async {
              // 퀴즈 완료 시간 저장
              await prefs.setInt(
                'lastQuizTime',
                DateTime.now().millisecondsSinceEpoch,
              );
            },
          ),
        ),
      );
    }
  }
}
  void _setupAlarms() async {
  const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
    'study_alarm',
    '한글 공부 알림',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails);

  // 기존 알람 전체 취소
  await flutterLocalNotificationsPlugin.cancelAll();

  // 2번: 점심 후 알람 (12:30)
  await flutterLocalNotificationsPlugin.show(
  id: 1,
  title: '🍚 점심 드셨나요?',
  body: '밥 먹고 한글 공부 5분만 해봐요! 오늘 미션이 기다려요 📚',
  notificationDetails: platformDetails,
);

  // 2번: 저녁 후 알람 (18:30)
  await flutterLocalNotificationsPlugin.show(
  id: 2,
  title: '🌙 저녁 드셨나요?',
  body: '하루 마무리로 한글 공부 어떠세요? 오늘 스트릭을 지켜요! 🔥',
  notificationDetails: platformDetails,
);

  // 3번: 스트릭 위기 알람 체크
  _checkStreakAlarm(platformDetails);

  // 4시간마다 반복 알람
  await flutterLocalNotificationsPlugin.periodicallyShow(
  id: 0,
  title: '📚 한글 공부 시간이에요!',
  body: '공부 안 하면 앱 열 때 퀴즈가 기다려요 😤',
  repeatInterval: RepeatInterval.hourly,        // ← 이걸로 교체
  notificationDetails: platformDetails,
  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
);
}

// 3번: 스트릭 위기 알람
void _checkStreakAlarm(NotificationDetails platformDetails) async {
  final prefs = await SharedPreferences.getInstance();
  final streak = prefs.getInt('streakDays') ?? 0;
  if (streak < 2) return; // 스트릭 2일 미만이면 패스

  final today = DateTime.now();
  final todayKey = '${today.year}-${today.month}-${today.day}';
  final lastStudyDate = prefs.getString('lastStudyDate') ?? '';

  // 오늘 아직 공부 안 했으면 스트릭 위기 알람
  if (lastStudyDate != todayKey) {
    await flutterLocalNotificationsPlugin.show(
  id: 3,
  title: '⚠️ 스트릭 위기! 🔥 $streak일이 끊겨요!',
  body: '오늘 공부 안 하면 $streak일 연속 기록이 사라져요! 지금 바로 시작해요!',
  notificationDetails: platformDetails,
);
  }
}

  Future<void> _setKoreanVoice() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.35);
    await flutterTts.setPitch(1.0);
  }

  void _pickRandomWord() {
    final random = Random();
    setState(() => todayWord = wordList[random.nextInt(wordList.length)]);
  }

  Future<void> _saveFontScale(double value) async {
    fontScaleNotifier.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontScale', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('기초 한글 공부',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[500],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields, size: 28),
            tooltip: '글씨 크기 조절',
            onPressed: () =>
                setState(() => _showFontSetting = !_showFontSetting),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── 글씨 크기 조절 패널 ──
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: _showFontSetting
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: _FontSettingPanel(
                  currentScale: fontScaleNotifier.value,
                  onChanged: _saveFontScale,
                ),
                secondChild: const SizedBox.shrink(),
              ),

              // ── 날짜/시간 카드 ──
              // ── 날짜/시간 카드 ──
Card(
  elevation: 6,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        colors: [Colors.green[400]!, Colors.teal[400]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.green.withOpacity(0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.calendar_today,
              color: Colors.white, size: 30),
        ),
        const SizedBox(width: 16),
        // ← Flexible로 감싸서 글씨 커져도 박스 안에서 처리
        Flexible(
          child: Text(
            _currentDateTime,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.7,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
),
const SizedBox(height: 12),

             // ── 오늘의 단어 카드 ──
Card(
  elevation: 6,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        colors: [Colors.blue[300]!, Colors.indigo[300]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            shape: BoxShape.circle,
          ),
          child: const Text('💡', style: TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: 12),
        // ← Flexible로 감싸서 글씨 커져도 줄바꿈으로 처리
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '오늘의 단어',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                todayWord,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // 버튼 두 개
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.volume_up,
                  size: 28, color: Colors.white),
              onPressed: () => flutterTts.speak(todayWord),
              tooltip: '소리 듣기',
            ),
            IconButton(
              icon: const Icon(Icons.refresh,
                  size: 24, color: Colors.white70),
              onPressed: _pickRandomWord,
              tooltip: '다른 단어',
            ),
          ],
        ),
      ],
    ),
  ),
),
const SizedBox(height: 20),

              // ── 메인 3대 메뉴 ──
              _MainMenuButton(
                emoji: '🪴',
                label: '화분',
                subLabel: '출석 체크',
                color: Colors.pink[400]!,
                lightColor: Colors.pink[50]!,
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              PlantScreen(waterCount: waterCount)));
                  _loadPlant();
                },
              ),
              const SizedBox(height: 16),

              _MainMenuButton(
                emoji: '📖',
                label: '공부하기',
                subLabel: '자음·모음·가나다·심화',
                color: Colors.green[600]!,
                lightColor: Colors.green[50]!,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const StudyMenuScreen())),
              ),
              const SizedBox(height: 16),

              _MainMenuButton(
                emoji: '✏️',
                label: '실습하기',
                subLabel: '낱말·숙제·소리 게임',
                color: Colors.orange[700]!,
                lightColor: Colors.orange[50]!,
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PracticeMenuScreen()));
                  _loadPlant();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 글씨 크기 조절 패널
// ============================================================
class _FontSettingPanel extends StatelessWidget {
  final double currentScale;
  final ValueChanged<double> onChanged;

  const _FontSettingPanel(
      {required this.currentScale, required this.onChanged});

  String get _scaleLabel {
    if (currentScale <= 1.0) return '보통';
    if (currentScale <= 1.2) return '크게';
    if (currentScale <= 1.4) return '더 크게';
    return '매우 크게';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber[50],
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.text_fields, color: Colors.amber, size: 26),
                const SizedBox(width: 8),
                const Text('글씨 크기 조절',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_scaleLabel,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('가나다 ABC 123',
                  style: TextStyle(
                      fontSize: 22 * currentScale,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text('가', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: ValueListenableBuilder<double>(
                    valueListenable: fontScaleNotifier,
                    builder: (_, scale, __) => Slider(
                      value: scale,
                      min: 0.9,
                      max: 1.6,
                      divisions: 7,
                      activeColor: Colors.amber[700],
                      inactiveColor: Colors.amber[100],
                      onChanged: onChanged,
                    ),
                  ),
                ),
                const Text('가',
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _QuickScaleButton(
                    label: '보통', scale: 1.0, onTap: onChanged),
                _QuickScaleButton(
                    label: '크게', scale: 1.2, onTap: onChanged),
                _QuickScaleButton(
                    label: '더 크게', scale: 1.4, onTap: onChanged),
                _QuickScaleButton(
                    label: '매우 크게', scale: 1.6, onTap: onChanged),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── 빠른 선택 버튼 ──
class _QuickScaleButton extends StatelessWidget {
  final String label;
  final double scale;
  final ValueChanged<double> onTap;

  const _QuickScaleButton(
      {required this.label, required this.scale, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = (fontScaleNotifier.value - scale).abs() < 0.05;
    return GestureDetector(
      onTap: () => onTap(scale),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber[700] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? Colors.amber[700]! : Colors.grey[300]!),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87)),
      ),
    );
  }
}

// ============================================================
// 메인 메뉴 버튼
// ============================================================
class _MainMenuButton extends StatelessWidget {
  final String emoji, label, subLabel;
  final Color color, lightColor;
  final VoidCallback onTap;

  const _MainMenuButton({
    required this.emoji,
    required this.label,
    required this.subLabel,
    required this.color,
    required this.lightColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: lightColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 왼쪽 컬러 영역
              Container(
                width: 100,
                constraints: const BoxConstraints(minHeight: 100),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(26),
                      bottomLeft: Radius.circular(26)),
                ),
                child: Text(emoji,
                    style: const TextStyle(fontSize: 52)),
              ),
              const SizedBox(width: 22),
              // 오른쪽 텍스트 영역
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: color)),
                      const SizedBox(height: 6),
                      Text(subLabel,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black54)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}