import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/utils/quiz_data_loader.dart';

/// 숙제: 글자 맞히기
/// assets/practical_words.txt에서 매번 10문제를 무작위로 뽑습니다.
class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});
  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  final FlutterTts flutterTts = FlutterTts();

  List<WordQuiz> _quizList = [];
  int _currentStep = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setKoreanVoice();
    _loadQuiz();
  }

  Future<void> _setKoreanVoice() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.35);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _loadQuiz() async {
    final words = await loadAllPracticalWords();
    final quizList = buildWordQuizList(words, 10); // ← 10문제
    setState(() {
      _quizList = quizList;
      _isLoading = false;
    });
  }

  Future<void> speak(String text) async => flutterTts.speak(text);

  void checkAnswer(String selected) {
    final correct = _quizList[_currentStep].item.word;
    if (selected == correct) {
      speak(getRandomPraise());
      setState(() => _currentStep++);
      if (_currentStep >= _quizList.length) _showCompletionDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('앗, 다시 한번 생각해 볼까요? 🤔'),
            backgroundColor: Colors.red[400], duration: const Duration(seconds: 1)),
      );
    }
  }

 void _giveWater() async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateTime.now();
  final todayKey = '${today.year}-${today.month}-${today.day}';
  final monthKey = '${today.year}-${today.month}';

  // 화분 물주기 (하루 1번)
  final lastDate = prefs.getString('lastWaterDate') ?? '';
  if (todayKey != lastDate) {
    final count = prefs.getInt('waterCount') ?? 0;
    await prefs.setInt('waterCount', count + 1);
    await prefs.setString('lastWaterDate', todayKey);
  }

  // 🌟 오늘 숙제 완료 횟수 +1
  final homeworkCount = prefs.getInt('homeworkCount_$todayKey') ?? 0;
  await prefs.setInt('homeworkCount_$todayKey', homeworkCount + 1);

  // 🌟 이번 달 공부한 날 기록
  final days = prefs.getStringList('studiedDays_$monthKey') ?? [];
  final dayStr = '${today.day}';
  if (!days.contains(dayStr)) {
    days.add(dayStr);
    await prefs.setStringList('studiedDays_$monthKey', days);
  }
}

  void _showCompletionDialog() {
    _giveWater();
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 숙제 완료!'),
        content: const Text('대단해요! 오늘의 한글 숙제를 모두 마쳤어요.\n경험치 +50 XP 획득!'),
        actions: [
          TextButton(
            onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); },
            child: const Text('확인', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_currentStep >= _quizList.length) return const Scaffold();

    final quiz = _quizList[_currentStep];
    final progress = _currentStep / _quizList.length;

    return Scaffold(
      appBar: AppBar(title: const Text('숙제: 글자 맞히기'), backgroundColor: Colors.green[400]),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: progress, minHeight: 15,
              backgroundColor: Colors.grey[300], color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 30),
            Text(
              '${_currentStep + 1} / ${_quizList.length} 문제',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text('이 그림은 무엇일까요?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Center(child: Text(quiz.item.icon, style: const TextStyle(fontSize: 100))),
            const SizedBox(height: 10),
            // 소리 듣기 버튼
            Center(
              child: IconButton(
                icon: const Icon(Icons.volume_up, size: 36, color: Colors.green),
                onPressed: () => speak(quiz.item.word),
              ),
            ),
            const Spacer(),
            ...quiz.options.map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  textStyle: const TextStyle(fontSize: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () => checkAnswer(opt),
                child: Text(opt),
              ),
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
