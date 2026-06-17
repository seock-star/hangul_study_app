import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_loader.dart'; // 🌟 우리가 만든 데이터 엔진 연동

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});
  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  final FlutterTts flutterTts = FlutterTts();
  List<Map<String, dynamic>> _quizList = [];
  bool _isLoading = true;
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    setKoreanVoice();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    // 🌟 도우미 엔진을 이용해 실시간 무작위 10문제를 빌드합니다.
    var dynamicData = await loadDynamicQuizData(10);
    setState(() {
      _quizList = dynamicData;
      _isLoading = false;
    });
  }

  Future<void> setKoreanVoice() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.35); // 어르신 맞춤형 속도
    await flutterTts.setPitch(1.0);
  }

  void checkAnswer(String selectedOption) {
    String correctAnswer = _quizList[currentStep]['answer'];
    if (selectedOption == correctAnswer) {
      flutterTts.speak('딩동댕!');
      setState(() { currentStep++; });
      if (currentStep >= _quizList.length) { showCompletionDialog(); }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('앗, 다시 한번 생각해 볼까요? 🤔'), backgroundColor: Colors.red[400], duration: const Duration(seconds: 1)),
      );
    }
  }

  void _giveWater() async {
    final prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toString().substring(0, 10);
    String lastDate = prefs.getString('lastWaterDate') ?? '';

    if (today != lastDate) { 
      int count = prefs.getInt('waterCount') ?? 0;
      await prefs.setInt('waterCount', count + 1);
      await prefs.setString('lastWaterDate', today);
    }
  }

  void showCompletionDialog() {
    _giveWater();
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('🎉 숙제 완료!'),
          content: const Text('대단해요! 오늘의 한글 숙제를 모두 마쳤어요.\n경험치 +50 XP 획득!'),
          actions: [
            TextButton(onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); }, child: const Text('확인', style: TextStyle(fontSize: 20))),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.amber)));
    }
    if (currentStep >= _quizList.length) { return const Scaffold(); }
    
    var currentQuiz = _quizList[currentStep];
    double progress = currentStep / _quizList.length;

    return Scaffold(
      appBar: AppBar(title: const Text('숙제: 글자 맞히기'), backgroundColor: Colors.amber[700], foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: progress, minHeight: 15, backgroundColor: Colors.grey[300], color: Colors.amber, borderRadius: BorderRadius.circular(10)),
            const SizedBox(height: 50),
            const Text('이 글자는 어떻게 읽을까요?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 30),
            Center(child: Text(currentQuiz['question'], style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold))),
            const Spacer(),
            ...List.generate(currentQuiz['options'].length, (index) {
              String option = currentQuiz['options'][index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20), textStyle: const TextStyle(fontSize: 24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: () => checkAnswer(option), child: Text(option),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}