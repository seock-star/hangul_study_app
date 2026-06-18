import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_application_1/utils/quiz_data_loader.dart';
import 'dart:math';

class WordOrderGameScreen extends StatefulWidget {
  const WordOrderGameScreen({super.key});
  @override
  State<WordOrderGameScreen> createState() => _WordOrderGameScreenState();
}

class _WordOrderGameScreenState extends State<WordOrderGameScreen> {
  final FlutterTts _tts = FlutterTts();
  List<PracticalWord> _quizList = [];
  int _step = 0, _correct = 0;
  late List<String> _shuffled;
  List<String> _answer = [];
  bool _answered = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("ko-KR");
    _tts.setSpeechRate(0.35);
    _loadQuiz();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    final all = await loadAllPracticalWords();
    final filtered = all.where((w) => w.word.length >= 2).toList()
      ..shuffle(Random());
    setState(() {
      _quizList = filtered.take(10).toList();
      _isLoading = false;
    });
    _initStep();
  }

  void _initStep() {
    final chars = _quizList[_step].word.split('');
    _shuffled = List.of(chars)..shuffle(Random());
    _answer = [];
    _answered = false;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _tts.speak('글자를 순서대로 눌러서 단어를 완성해 보세요!');
    });
  }

  void _pickChar(int i) {
    if (_answered) return;
    setState(() {
      _answer.add(_shuffled[i]);
      _shuffled.removeAt(i);
    });
    if (_shuffled.isEmpty) _checkAnswer();
  }

  void _removeChar(int i) {
    if (_answered) return;
    setState(() {
      _shuffled.add(_answer[i]);
      _answer.removeAt(i);
    });
  }

  void _checkAnswer() {
    final word = _quizList[_step].word;
    final composed = _answer.join();
    setState(() => _answered = true);
    if (composed == word) {
      _correct++;
      _tts.speak('${getRandomPraise()} $word 맞아요!');
    } else {
      _tts.speak('아쉬워요. 정답은 $word 예요.');
    }
  }

  void _next() {
    if (_step + 1 >= _quizList.length) {
      _showResult();
      return;
    }
    setState(() => _step++);
    _initStep();
  }

  void _showResult() {
    _tts.speak('순서 맞추기를 모두 마쳤어요! $_correct개 맞혔어요! 대단해요!');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 완료!',
            style: TextStyle(fontSize: 26),
            textAlign: TextAlign.center),
        content: Text(
          '${_quizList.length}문제 중 $_correct개 맞혔어요!\n훌륭해요! 👏',
          style: const TextStyle(fontSize: 20, height: 1.6),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _step = 0;
                      _correct = 0;
                    });
                    _loadQuiz();
                  },
                  child: const Text('다시 하기'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    _tts.stop();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('끝내기'),
                ),
              ),
            ],
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

    final q = _quizList[_step];
    final isCorrect = _answered && _answer.join() == q.word;

    return Scaffold(
      appBar: AppBar(
        title: Text('🔀 순서 맞추기  ${_step + 1}/${_quizList.length}',
            style: const TextStyle(fontSize: 20)),
        backgroundColor: Colors.green[600],
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
                      value: (_step + 1) / _quizList.length,
                      minHeight: 14,
                      color: Colors.green,
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${_step + 1} / ${_quizList.length}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
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
                    vertical: 24, horizontal: 20),
                child: Column(
                  children: [
                    Text(q.icon,
                        style: const TextStyle(fontSize: 90)),
                    const SizedBox(height: 8),
                    Text(
                      '글자를 순서대로 눌러\n단어를 완성하세요!',
                      style: TextStyle(
                          fontSize: 18, color: Colors.green[800]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // 소리 듣기 버튼
                    OutlinedButton.icon(
                      icon: const Icon(Icons.volume_up, size: 20),
                      label: const Text('소리 듣기',
                          style: TextStyle(fontSize: 16)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green[700],
                        side: BorderSide(
                            color: Colors.green[700]!, width: 2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () => _tts.speak(q.word),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── 정답 슬롯 ──
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              color: _answered
                  ? (isCorrect ? Colors.green[50] : Colors.red[50])
                  : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 12),
                child: Column(
                  children: [
                    const Text('내 답',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 8),
                    // 선택한 글자들
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: _answer.isEmpty
                          ? [
                              Text(
                                '글자를 눌러서 채워보세요',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[400]),
                              )
                            ]
                          : _answer.asMap().entries.map((e) {
                              return GestureDetector(
                                onTap: () => _removeChar(e.key),
                                child: Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: isCorrect
                                        ? Colors.green[200]
                                        : _answered
                                            ? Colors.red[200]
                                            : Colors.green[400],
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(e.value,
                                        style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight:
                                                FontWeight.bold,
                                            color: Colors.white)),
                                  ),
                                ),
                              );
                            }).toList(),
                    ),
                    // 정오답 표시
                    if (_answered) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCorrect
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: isCorrect
                                ? Colors.green
                                : Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              isCorrect
                                  ? '🎉 정답이에요!'
                                  : '❌ 정답은 "${q.word}" 예요',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isCorrect
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── 글자 버튼 ──
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('눌러서 고르세요',
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: _shuffled.asMap().entries.map((e) {
                        return GestureDetector(
                          onTap: () => _pickChar(e.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.green[400],
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(e.value,
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── 다음 문제 버튼 ──
            if (_answered)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isCorrect ? Colors.green : Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                onPressed: _next,
                child: Text(
                  _step + 1 >= _quizList.length
                      ? '결과 보기 🏆'
                      : isCorrect
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