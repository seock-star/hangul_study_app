import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';

// 우리가 새로 만들 파일들을 미리 연결해 둡니다.
import 'home_screen.dart';

// 앱 전체에서 알림 도구를 쓸 수 있게 전역 변수로 선언합니다.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 안드로이드 기본 앱 아이콘을 알림 아이콘으로 설정
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  
  await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);

  runApp(const HangulApp());
}

class HangulApp extends StatelessWidget {
  const HangulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '기초 한글 공부',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // 앱을 켜면 무조건 입장 퀴즈(ForcedQuizScreen)가 먼저 나오게 합니다.
      home: const ForcedQuizScreen(),
    );
  }
}

// ----------------------------------------------------
// 퀴즈 화면 보호기 (입장 퀴즈)
// ----------------------------------------------------
class ForcedQuizScreen extends StatefulWidget {
  const ForcedQuizScreen({super.key});

  @override
  State<ForcedQuizScreen> createState() => _ForcedQuizScreenState();
}

class _ForcedQuizScreenState extends State<ForcedQuizScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final List<Map<String, dynamic>> quizData = [
    {'q': 'ㄱ', 'a': '기역', 'o': ['기역', '니은', '디귿']},
    {'q': '가', 'a': '가', 'o': ['나', '가', '다']},
    {'q': '사과', 'a': '사과', 'o': ['바나나', '포도', '사과']},
  ];
  late Map<String, dynamic> currentQuiz;

  @override
  void initState() {
    super.initState();
    currentQuiz = quizData[Random().nextInt(quizData.length)];
    _speakQuestion();
  }

  void _speakQuestion() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.35);
    await flutterTts.speak('공부 시작 전에 문제 하나 풀어볼까요? ${currentQuiz['q']}는 무엇일까요?');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('오늘의 입장 퀴즈', style: TextStyle(fontSize: 24, color: Colors.orange, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Text(currentQuiz['q'], style: const TextStyle(fontSize: 100, fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            ...List.generate(currentQuiz['o'].length, (index) {
              String option = currentQuiz['o'][index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    textStyle: const TextStyle(fontSize: 28),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    if (option == currentQuiz['a']) {
                      // 정답이면 메인 홈 화면으로 교체!
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('다시 한번 생각해보세요! 🤔')));
                    }
                  },
                  child: Text(option),
                ),
              );
            }),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
              child: const Text('건너뛰고 바로 시작하기', style: TextStyle(color: Colors.grey, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}