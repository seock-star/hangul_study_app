import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/quiz_loader.dart';

class ListeningGameScreen extends StatefulWidget {
  const ListeningGameScreen({super.key});
  @override
  State<ListeningGameScreen> createState() => _ListeningGameScreenState();
}

class _ListeningGameScreenState extends State<ListeningGameScreen> {
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
    var dynamicData = await loadDynamicQuizData(10);
    setState(() {
      _quizList = dynamicData;
      _isLoading = false;
    });
    
    // 첫 문제 사운드 0.5초 대기 후 재생
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) speak(_quizList[currentStep]['answer']);
    });
  }

  Future<void> setKoreanVoice() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.35);
    await flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  void checkAnswer(String selectedOption) {
    String correctAnswer = _quizList[currentStep]['answer'];
    if (selectedOption == correctAnswer) {
      speak('딩동댕!');
      setState(() { currentStep++; });
      if (currentStep >= _quizList.length) {
        showCompletionDialog();
      } else {
        Future.delayed(const Duration(seconds: 1), () { speak(_quizList[currentStep]['answer']); });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('앗, 다른 소리 같아요! 다시 들어볼까요? 🎧'), backgroundColor: Colors.red[400], duration: const Duration(seconds: 1)),
      );
    }
  }

  void showCompletionDialog() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('🎉 듣기 평가 완료!'),
          content: const Text('황금 귀를 가지셨네요!\n경험치 +100 XP 획득!'),
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
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.purple)));
    }
    if (currentStep >= _quizList.length) { return const Scaffold(); }
    
    var currentQuiz = _quizList[currentStep];
    double progress = currentStep / _quizList.length;

    return Scaffold(
      appBar: AppBar(title: const Text('소리 듣고 맞히기'), backgroundColor: Colors.purple[400], foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: progress, minHeight: 15, backgroundColor: Colors.grey[300], color: Colors.purple, borderRadius: BorderRadius.circular(10)),
            const SizedBox(height: 50),
            const Text('스피커를 누르고 어떤 글자인지 맞춰보세요!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(40), backgroundColor: Colors.purple[100], elevation: 8),
                onPressed: () => speak(currentQuiz['answer']), child: const Icon(Icons.volume_up, size: 80, color: Colors.purple),
              ),
            ),
            const SizedBox(height: 20),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(currentQuiz['options'].length, (index) {
                String option = currentQuiz['options'][index];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 30), textStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: () => checkAnswer(option), child: Text(option),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}