import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_application_1/utils/quiz_data_loader.dart';
import 'dart:math';

/// 🔀 순서 맞추기 - assets에서 10문제 무작위
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

  Future<void> _loadQuiz() async {
    // 2글자 이상만 사용
    final all = await loadAllPracticalWords();
    final filtered = all.where((w) => w.word.length >= 2).toList()..shuffle(Random());
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
    _tts.speak('글자를 순서대로 눌러서 단어를 완성해 보세요!');
  }

  void _pickChar(int i) {
    if (_answered) return;
    setState(() { _answer.add(_shuffled[i]); _shuffled.removeAt(i); });
    if (_shuffled.isEmpty) _checkAnswer();
  }

  void _removeChar(int i) {
    if (_answered) return;
    setState(() { _shuffled.add(_answer[i]); _answer.removeAt(i); });
  }

  void _checkAnswer() {
    final word = _quizList[_step].word;
    final composed = _answer.join();
    setState(() => _answered = true);
    if (composed == word) { _correct++; _tts.speak('${getRandomPraise()} $word 맞아요!'); }
    else { _tts.speak('아쉬워요. 정답은 $word 예요.'); }
  }

  void _next() {
    if (_step + 1 >= _quizList.length) { _showResult(); return; }
    setState(() => _step++);
    _initStep();
  }

  void _showResult() {
    showDialog(context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 완료!'),
        content: Text('${_quizList.length}문제 중 $_correct개 맞혔어요!'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); _loadQuiz(); }, child: const Text('다시 하기', style: TextStyle(fontSize: 20))),
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('끝내기', style: TextStyle(fontSize: 20))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final q = _quizList[_step];
    final isCorrect = _answered && _answer.join() == q.word;
    return Scaffold(
      appBar: AppBar(title: Text('🔀 순서 맞추기  ${_step + 1}/${_quizList.length}'),
          backgroundColor: Colors.green[600], foregroundColor: Colors.white),
      backgroundColor: Colors.green[50],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_step + 1) / _quizList.length, minHeight: 12, color: Colors.green, backgroundColor: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
            const SizedBox(height: 24),
            Text(q.icon, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 8),
            Text('글자를 순서대로 눌러 단어를 완성하세요!', style: TextStyle(fontSize: 18, color: Colors.green[800])),
            const SizedBox(height: 20),
            Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: _answered ? (isCorrect ? Colors.green[100] : Colors.red[100]) : Colors.white,
                borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _answer.isEmpty
                    ? [Text('여기에 글자가 채워져요', style: TextStyle(fontSize: 20, color: Colors.grey[400]))]
                    : _answer.asMap().entries.map((e) => GestureDetector(
                        onTap: () => _removeChar(e.key),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 52, height: 52,
                          decoration: BoxDecoration(color: Colors.green[200], borderRadius: BorderRadius.circular(10)),
                          child: Center(child: Text(e.value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
                        ),
                      )).toList(),
              ),
            ),
            if (_answered) Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(isCorrect ? '🎉 정답이에요!' : '❌ 정답은 "${q.word}" 예요',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isCorrect ? Colors.green : Colors.red)),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
              children: _shuffled.asMap().entries.map((e) => GestureDetector(
                onTap: () => _pickChar(e.key),
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: Colors.green[400], borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))]),
                  child: Center(child: Text(e.value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white))),
                ),
              )).toList(),
            ),
            const Spacer(),
            if (_answered) ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600], foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18), textStyle: const TextStyle(fontSize: 22)),
              onPressed: _next,
              child: Text(_step + 1 >= _quizList.length ? '결과 보기 🏆' : '다음 문제 👉'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
