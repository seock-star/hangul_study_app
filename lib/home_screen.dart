import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// 🌟 home_screen.dart 최상단에 진짜 화면들을 연결합니다!
// (기존의 Fake 클래스들이 연결되어 있던 onTap 부분을 StudyMenuScreen(), PracticeMenuScreen() 으로 이름만 바꿔치기해 주면 끝!)
// 대가리가 깨지는 걸 방지하기 위해 main.dart에 있는 알림 변수를 가져옵니다.
import 'main.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts flutterTts = FlutterTts();
  String todayWord = ''; 
  List<String> wordList = ['사과', '바나나', '자동차', '비행기', '고양이', '나비']; // 임시 단어장
  int waterCount = 0; 

  @override
  void initState() {
    super.initState();
    setKoreanVoice();
    setupHourlyAlarm(); 
    _loadPlant(); 
    pickRandomWord();
  }

  void _loadPlant() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      waterCount = prefs.getInt('waterCount') ?? 0;
    });
  }

  void setupHourlyAlarm() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'study_alarm', '한글 공부 알림', importance: Importance.max, priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.periodicallyShow(
      id: 0,
      title: '⏰ 한글 공부할 시간이에요!',
      body: '오늘의 단어와 숙제가 기다리고 있어요. 앱을 켜서 확인해 보세요!',
      repeatInterval: RepeatInterval.hourly,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> setKoreanVoice() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.35); 
    await flutterTts.setPitch(1.0);
  }

  void pickRandomWord() {
    final random = Random();
    int randomIndex = random.nextInt(wordList.length);
    setState(() { todayWord = wordList[randomIndex]; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('기초 한글 공부', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[500],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4, color: Colors.blue[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('💡 오늘의 단어: ', style: TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
                    Text(todayWord, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    IconButton(icon: const Icon(Icons.volume_up, size: 30, color: Colors.blue), onPressed: () => flutterTts.speak(todayWord)),
                    IconButton(icon: const Icon(Icons.refresh, size: 26, color: Colors.blueGrey), onPressed: () => pickRandomWord()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            Expanded(
              child: Column(
                children: [
                  // 1. 화분
                  Expanded(
                    child: _MainMenuButton(
                      emoji: '🪴', label: '화분', subLabel: '출석 체크',
                      color: Colors.pink[400]!, lightColor: Colors.pink[50]!,
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => FakePlantScreen(waterCount: waterCount)));
                        _loadPlant(); 
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. 공부하기
                  Expanded(
                    child: _MainMenuButton(
                      emoji: '📖', label: '공부하기', subLabel: '자음·모음·가나다·심화',
                      color: Colors.green[600]!, lightColor: Colors.green[50]!,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const FakeStudyMenuScreen()));
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. 실습하기
                  Expanded(
                    child: _MainMenuButton(
                      emoji: '✏️', label: '실습하기', subLabel: '낱말·숙제·소리 게임',
                      color: Colors.orange[700]!, lightColor: Colors.orange[50]!,
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => const FakePracticeMenuScreen()));
                        _loadPlant();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MainMenuButton extends StatelessWidget {
  final String emoji; final String label; final String subLabel; final Color color; final Color lightColor; final VoidCallback onTap;
  const _MainMenuButton({required this.emoji, required this.label, required this.subLabel, required this.color, required this.lightColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: lightColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: color, width: 2.5),
        ),
        child: Row(
          children: [
            Container(
              width: 90, alignment: Alignment.center,
              decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.only(topLeft: Radius.circular(22), bottomLeft: Radius.circular(22))),
              child: Text(emoji, style: const TextStyle(fontSize: 48)),
            ),
            const SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 4),
                Text(subLabel, style: const TextStyle(fontSize: 17, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// ⚠️ [중요] 아래는 하위 파일 생성 전 에러를 방지하기 위한 임시 가짜 화면들입니다.
// 다음 단계에서 실제 폴더에 파일이 만들어지면 임포트(import)하고 아래 코드들은 지울 겁니다!
// ----------------------------------------------------
class FakePlantScreen extends StatelessWidget {
  final int waterCount;
  const FakePlantScreen({super.key, required this.waterCount});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('🪴 나의 화분')), body: Center(child: Text('여기는 곧 채워질 화분 화면이야! 물 준 횟수: $waterCount')));
  }
}

class FakeStudyMenuScreen extends StatelessWidget {
  const FakeStudyMenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('📖 공부하기')), body: const Center(child: Text('여기는 곧 채워질 공부하기 메뉴야!')));
  }
}

class FakePracticeMenuScreen extends StatelessWidget {
  const FakePracticeMenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('✏️ 실습하기')), body: const Center(child: Text('여기는 곧 채워질 실습하기 메뉴야!')));
  }
}