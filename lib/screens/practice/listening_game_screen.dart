import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/utils/quiz_data_loader.dart';

class ListeningGameScreen extends StatefulWidget {
  const ListeningGameScreen({super.key});
  @override
  State<ListeningGameScreen> createState() => _ListeningGameScreenState();
}

class _ListeningGameScreenState extends State<ListeningGameScreen> {
  final FlutterTts _tts = FlutterTts();

  List<WordQuiz> _quizList = [];
  int _currentStep = 0;
  bool _isLoading = true;
  bool _isPlaying = false;
  String? _selectedAnswer;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadQuiz();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("ko-KR");
    await _tts.setSpeechRate(0.35);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      setState(() => _isPlaying = false);
    });
  }

  Future<void> _loadQuiz() async {
    final words = await loadAllPracticalWords();
    final quizList = buildWordQuizList(words, 10);
    setState(() {
      _quizList = quizList;
      _isLoading = false;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) _playQuestion();
  }

  Future<void> _playQuestion() async {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);
    await _tts.stop();
    await Future.delayed(const Duration(milliseconds: 100));
    await _tts.speak(_quizList[_currentStep].item.word);
  }

  void _checkAnswer(String selected) {
    if (_isAnswered) return;
    final correct = _quizList[_currentStep].item.word;
    setState(() {
      _selectedAnswer = selected;
      _isAnswered = true;
      _isPlaying = true;
    });

    if (selected == correct) {
      _tts.speak(getRandomPraise());
      _tts.setCompletionHandler(() {
        setState(() => _isPlaying = false);
      });
    } else {
      _tts.speak('아쉬워요! 정답은 $correct 예요.');
      _tts.setCompletionHandler(() {
        setState(() => _isPlaying = false);
      });
    }
  }

  void _nextQuestion() {
    if (_currentStep + 1 >= _quizList.length) {
      _saveStudyRecord();
      _showCompletionDialog();
      return;
    }
    setState(() {
      _currentStep++;
      _selectedAnswer = null;
      _isAnswered = false;
    });
    Future.delayed(const Duration(milliseconds: 400), _playQuestion);
  }

  Future<void> _saveStudyRecord() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    final monthKey = '${today.year}-${today.month}';
    final count = prefs.getInt('homeworkCount_$todayKey') ?? 0;
    await prefs.setInt('homeworkCount_$todayKey', count + 1);
    final days = prefs.getStringList('studiedDays_$monthKey') ?? [];
    if (!days.contains('${today.day}')) {
      days.add('${today.day}');
      await prefs.setStringList('studiedDays_$monthKey', days);
    }
  }

  void _showCompletionDialog() {
    _tts.speak('듣기 평가를 모두 마쳤어요! 황금 귀를 가지셨네요! 정말 대단하세요!');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 듣기 평가 완료!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26)),
        content: const Text(
            '황금 귀를 가지셨네요!\n\n경험치 +100 XP 획득!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, height: 1.6)),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 22),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                _tts.stop();
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
        title: const Text('소리 듣고 맞히기'),
        backgroundColor: Colors.purple[400],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _tts.stop();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
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
                      color: Colors.purple,
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
            const SizedBox(height: 30),

            // ── 스피커 버튼 카드 ──
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
                      '스피커를 누르고\n어떤 단어인지 맞춰보세요!',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // 스피커 버튼
                    GestureDetector(
                      onTap: _isAnswered ? null : _playQuestion,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isPlaying
                              ? Colors.purple[200]
                              : Colors.purple[100],
                          border: Border.all(
                            color: Colors.purple[400]!,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isPlaying
                                  ? Icons.volume_up
                                  : Icons.play_circle,
                              size: 65,
                              color: Colors.purple[700],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _isPlaying ? '재생중...' : '눌러서 듣기',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.purple[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '소리를 잘 듣고 정답을 골라요',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── 보기 버튼 3개 ──
            ...quiz.options.map((opt) {
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

            // ── 다음 문제 버튼 (답 선택 후에만) ──
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