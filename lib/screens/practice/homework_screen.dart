import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/utils/quiz_data_loader.dart';

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
  String? _selectedAnswer;   // 선택한 답
  bool _isAnswered = false;  // 답 선택 여부

  @override
  void initState() {
    super.initState();
    _setKoreanVoice();
    _loadQuiz();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _setKoreanVoice() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.35);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _loadQuiz() async {
    final words = await loadAllPracticalWords();
    final quizList = buildWordQuizList(words, 10);
    setState(() {
      _quizList = quizList;
      _isLoading = false;
    });
    // 첫 문제 안내
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) flutterTts.speak('이 그림은 무엇일까요?');
  }

  void _checkAnswer(String selected) {
    if (_isAnswered) return;
    final correct = _quizList[_currentStep].item.word;
    setState(() {
      _selectedAnswer = selected;
      _isAnswered = true;
    });

    if (selected == correct) {
      flutterTts.speak(getRandomPraise());
    } else {
      flutterTts.speak('아쉬워요! 정답은 $correct 예요.');
    }
  }

  void _nextQuestion() {
    if (_currentStep + 1 >= _quizList.length) {
      _giveWater();
      _showCompletionDialog();
      
      return;
    }
    setState(() {
      _currentStep++;
      _selectedAnswer = null;
      _isAnswered = false;
    });
    flutterTts.speak('이 그림은 무엇일까요?');
  }

  void _giveWater() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    final monthKey = '${today.year}-${today.month}';

    final lastDate = prefs.getString('lastWaterDate') ?? '';
    if (todayKey != lastDate) {
      final count = prefs.getInt('waterCount') ?? 0;
      await prefs.setInt('waterCount', count + 1);
      await prefs.setString('lastWaterDate', todayKey);
    }

    final homeworkCount = prefs.getInt('homeworkCount_$todayKey') ?? 0;
    await prefs.setInt('homeworkCount_$todayKey', homeworkCount + 1);

    final days = prefs.getStringList('studiedDays_$monthKey') ?? [];
    if (!days.contains('${today.day}')) {
      days.add('${today.day}');
      await prefs.setStringList('studiedDays_$monthKey', days);
    }
    await _updateStreak();
  }

  void _showCompletionDialog() {
    flutterTts.speak('숙제를 모두 마쳤어요! 정말 대단하세요!');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 숙제 완료!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26)),
        content: const Text(
            '대단해요! 오늘의 한글 숙제를\n모두 마쳤어요!\n\n경험치 +50 XP 획득!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, height: 1.6)),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 22),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                flutterTts.stop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    if (_currentStep >= _quizList.length) return const Scaffold();

    final quiz = _quizList[_currentStep];
    final correct = quiz.item.word;
    final progress = (_currentStep + 1) / _quizList.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('숙제: 글자 맞히기'),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            flutterTts.stop();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(       // ← 스크롤 추가
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── 진행 바 ──
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 14,
                      backgroundColor: Colors.grey[300],
                      color: Colors.amber[700],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_currentStep + 1} / ${_quizList.length}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── 문제 카드 ──
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 28, horizontal: 20),
                child: Column(
                  children: [
                    const Text(
                      '이 그림은 무엇일까요?',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // 그림 이모지
                    Text(quiz.item.icon,
                        style: const TextStyle(fontSize: 110)),
                    const SizedBox(height: 12),
                    // 소리 듣기 버튼
                    OutlinedButton.icon(
                      icon: const Icon(Icons.volume_up, size: 22),
                      label: const Text('소리 듣기',
                          style: TextStyle(fontSize: 18)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber[700],
                        side: BorderSide(
                            color: Colors.amber[700]!, width: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () =>
                          flutterTts.speak(quiz.item.word),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── 보기 버튼 3개 ──
            ...quiz.options.map((opt) {
              // 정답 여부에 따라 색상 결정
              Color bgColor = Colors.white;
              Color borderColor = Colors.grey[300]!;
              Color textColor = Colors.black87;
              IconData? icon;

              if (_isAnswered) {
                if (opt == correct) {
                  bgColor = Colors.green[50]!;
                  borderColor = Colors.green;
                  textColor = Colors.green[800]!;
                  icon = Icons.check_circle;
                } else if (opt == _selectedAnswer) {
                  bgColor = Colors.red[50]!;
                  borderColor = Colors.red;
                  textColor = Colors.red[800]!;
                  icon = Icons.cancel;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GestureDetector(
                  onTap: () => _checkAnswer(opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: borderColor, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: textColor, size: 26),
                          const SizedBox(width: 12),
                        ] else ...[
                          const SizedBox(width: 38),
                        ],
                        Expanded(
                          child: Text(
                            opt,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

            // ── 다음 문제 버튼 (답 선택 후에만 표시) ──
            if (_isAnswered)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedAnswer == correct
                      ? Colors.green
                      : Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                onPressed: _nextQuestion,
                child: Text(
                  _currentStep + 1 >= _quizList.length
                      ? '결과 보기 🏆'
                      : _selectedAnswer == correct
                          ? '다음 문제 👉'
                          : '다음 문제로 넘어가기 👉',
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
// 🔥 스트릭 업데이트
Future<void> _updateStreak() async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateTime.now();
  final todayKey = '${today.year}-${today.month}-${today.day}';
  final yesterdayKey = () {
    final yesterday = today.subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month}-${yesterday.day}';
  }();

  final lastStudyDate = prefs.getString('lastStudyDate') ?? '';
  int streak = prefs.getInt('streakDays') ?? 0;

  if (lastStudyDate == todayKey) {
    // 오늘 이미 공부했으면 스트릭 유지
    return;
  } else if (lastStudyDate == yesterdayKey) {
    // 어제 공부했으면 스트릭 +1
    streak++;
  } else {
    // 하루 이상 건너뛰면 스트릭 리셋
    streak = 1;
  }

  await prefs.setInt('streakDays', streak);
  await prefs.setString('lastStudyDate', todayKey);
}