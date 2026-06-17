import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_application_1/utils/quiz_data_loader.dart';

/// 🔤 빈칸 채우기 - assets에서 10문제 무작위 생성
class FillBlankGameScreen extends StatefulWidget {
  const FillBlankGameScreen({super.key});
  @override
  State<FillBlankGameScreen> createState() => _FillBlankGameScreenState();
}

class _FillBlankQuestion {
  final String word;
  final String hint; // 이모지
  final int blankIndex;
  final List<String> options;
  _FillBlankQuestion({required this.word, required this.hint, required this.blankIndex, required this.options});
}

class _FillBlankGameScreenState extends State<FillBlankGameScreen> {
  final FlutterTts _tts = FlutterTts();
  List<_FillBlankQuestion> _quizList = [];
  int _step = 0, _correct = 0;
  String? _selected;
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
    final rand = Random();
    // 2글자 이상인 단어만 사용
    final words = await loadAllPracticalWords();
    final filtered = words.where((w) => w.word.length >= 2).toList()..shuffle(rand);
    final selected = filtered.take(10).toList();

    final quizList = selected.map((pw) {
      final chars = pw.word.split('');
      final blankIdx = rand.nextInt(chars.length);
      final answer = chars[blankIdx];
      // 오답 후보: 다른 단어의 글자들에서 무작위 2개
      final others = filtered
          .where((w) => w.word != pw.word)
          .expand((w) => w.word.split(''))
          .where((c) => c != answer)
          .toSet()
          .toList()..shuffle(rand);
      final opts = ([...others.take(2), answer])..shuffle(rand);
      return _FillBlankQuestion(word: pw.word, hint: pw.icon, blankIndex: blankIdx, options: opts.cast<String>());
    }).toList();

    setState(() { _quizList = quizList; _isLoading = false; });
    _speakQuestion();
  }

  void _speakQuestion() {
    if (_quizList.isEmpty) return;
    final q = _quizList[_step];
    final chars = q.word.split('');
    chars[q.blankIndex] = '빈칸';
    _tts.speak(chars.join(' '));
  }

  void _select(String opt) {
    if (_answered) return;
    final answer = _quizList[_step].word[_quizList[_step].blankIndex];
    setState(() { _selected = opt; _answered = true; });
    if (opt == answer) {
      _correct++;
      _tts.speak(getRandomPraise());
    } else {
      _tts.speak('아쉬워요. 정답은 $answer 예요.');
    }
  }

  void _next() {
    if (_step + 1 >= _quizList.length) { _showResult(); return; }
    setState(() { _step++; _selected = null; _answered = false; });
    _speakQuestion();
  }

  void _showResult() {
    showDialog(context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 완료!'),
        content: Text('${_quizList.length}문제 중 $_correct개 맞혔어요! 👏'),
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
    final answer = q.word[q.blankIndex];
    final chars = q.word.split('');

    return Scaffold(
      appBar: AppBar(title: Text('🔤 빈칸 채우기  ${_step + 1}/${_quizList.length}'),
          backgroundColor: Colors.blue[500], foregroundColor: Colors.white),
      backgroundColor: Colors.blue[50],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_step + 1) / _quizList.length, minHeight: 12, color: Colors.blue, backgroundColor: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
            const SizedBox(height: 30),
            Text(q.hint, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(chars.length, (i) {
                final isBlank = i == q.blankIndex;
                final filled = isBlank && _answered ? _selected ?? '_' : null;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: isBlank ? (_answered ? (_selected == answer ? Colors.green[100] : Colors.red[100]) : Colors.yellow[100]) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isBlank ? Colors.blue : Colors.grey[300]!, width: 2),
                  ),
                  child: Center(child: Text(isBlank ? (filled ?? '_') : chars[i],
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: isBlank ? Colors.blue[800] : Colors.black87))),
                );
              }),
            ),
            const SizedBox(height: 10),
            IconButton(icon: const Icon(Icons.volume_up, size: 36, color: Colors.blue), onPressed: _speakQuestion),
            const Spacer(),
            Wrap(
              spacing: 16, runSpacing: 16, alignment: WrapAlignment.center,
              children: q.options.map((opt) {
                Color btnColor = Colors.white;
                if (_answered) {
                  if (opt == answer) btnColor = Colors.green[200]!;
                  else if (opt == _selected) btnColor = Colors.red[200]!;
                }
                return SizedBox(
                  width: 120, height: 70,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: btnColor, foregroundColor: Colors.black87,
                        textStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 4),
                    onPressed: () => _select(opt),
                    child: Text(opt),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            if (_answered) ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white,
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
