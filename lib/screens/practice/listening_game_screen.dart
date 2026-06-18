import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_application_1/utils/quiz_data_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';  // ← 이 줄 추가
import 'package:audioplayers/audioplayers.dart';

/// 숙제: 소리 듣고 맞히기
/// assets/practical_words.txt에서 매번 10문제 무작위로 뽑습니다.
class ListeningGameScreen extends StatefulWidget {
  const ListeningGameScreen({super.key});
  @override
  State<ListeningGameScreen> createState() => _ListeningGameScreenState();
}
final AudioPlayer _audioPlayer = AudioPlayer();
class _ListeningGameScreenState extends State<ListeningGameScreen> {
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
    // 첫 문제 자동 읽기
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted && _quizList.isNotEmpty) {
      await _audioPlayer.play(UrlSource(
  'https://www.soundjay.com/buttons/sounds/button-09.mp3'
));
await Future.delayed(const Duration(milliseconds: 800));
flutterTts.speak(_quizList[0].item.word);
    }
  }
  @override
  void dispose() {
    _audioPlayer.dispose();
    flutterTts.stop();
    super.dispose();
}
  void checkAnswer(String selected) {
    final correct = _quizList[_currentStep].item.word;
    if (selected == correct) {
      flutterTts.speak(getRandomPraise());
      setState(() => _currentStep++);
      if (_currentStep >= _quizList.length) {
        _showCompletionDialog();
      } else {
       Future.delayed(const Duration(seconds: 1), () async {
  await _audioPlayer.play(UrlSource(
    'https://www.soundjay.com/buttons/sounds/button-09.mp3'
  ));
  await Future.delayed(const Duration(milliseconds: 800));
  flutterTts.speak(_quizList[_currentStep].item.word);
});
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('앗, 다른 소리 같아요! 다시 들어볼까요? 🎧'),
          backgroundColor: Colors.red[400],
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
Future<void> _saveStudyRecord() async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateTime.now();
  final todayKey = '${today.year}-${today.month}-${today.day}';
  final monthKey = '${today.year}-${today.month}';

  final homeworkCount = prefs.getInt('homeworkCount_$todayKey') ?? 0;
  await prefs.setInt('homeworkCount_$todayKey', homeworkCount + 1);

  final days = prefs.getStringList('studiedDays_$monthKey') ?? [];
  final dayStr = '${today.day}';
  if (!days.contains(dayStr)) {
    days.add(dayStr);
    await prefs.setStringList('studiedDays_$monthKey', days);
  }
}
  void _showCompletionDialog() {
    _saveStudyRecord();
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 듣기 평가 완료!'),
        content: const Text('황금 귀를 가지셨네요!\n경험치 +100 XP 획득!'),
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
      appBar: AppBar(title: const Text('소리 듣고 맞히기'), backgroundColor: Colors.purple[400]),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: progress, minHeight: 15,
              backgroundColor: Colors.grey[300], color: Colors.purple,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 30),
            Text(
              '${_currentStep + 1} / ${_quizList.length} 문제',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text('스피커를 누르고 어떤 단어인지 맞춰보세요!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(40),
                  backgroundColor: Colors.purple[100],
                  elevation: 8,
                ),
                onPressed: () async {
                      await _audioPlayer.play(UrlSource(
                         'https://www.soundjay.com/buttons/sounds/button-09.mp3'
                        ));
                       await Future.delayed(const Duration(milliseconds: 800));
                      flutterTts.speak(quiz.item.word);
                },
                child: const Icon(Icons.volume_up, size: 80, color: Colors.purple),
              ),
            ),
            const SizedBox(height: 10),
            const Center(child: Text('소리 다시 듣기', style: TextStyle(fontSize: 16, color: Colors.grey))),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: quiz.options.map((opt) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      textStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () => checkAnswer(opt),
                    child: Text(opt),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
