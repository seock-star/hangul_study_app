import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FillBlankGameScreen extends StatefulWidget {
  const FillBlankGameScreen({super.key});
  @override
  State<FillBlankGameScreen> createState() => _FillBlankGameScreenState();
}

class _FillBlankGameScreenState extends State<FillBlankGameScreen> {
  final FlutterTts _tts = FlutterTts();
  final List<Map<String, dynamic>> _quizList = [
    {'word': '사과', 'blank': 0, 'hint': '🍎', 'options': ['사', '바', '나', '가']},
    {'word': '바나나', 'blank': 0, 'hint': '🍌', 'options': ['바', '사', '가', '나']},
    {'word': '자동차', 'blank': 1, 'hint': '🚗', 'options': ['동', '차', '자', '통']},
    {'word': '비행기', 'blank': 0, 'hint': '✈️', 'options': ['비', '기', '행', '차']},
    {'word': '고양이', 'blank': 1, 'hint': '🐈', 'options': ['양', '고', '이', '강']},
  ];
  int _step = 0; int _correct = 0; String? _selected; bool _answered = false;

  @override
  void initState() { super.initState(); _tts.setLanguage("ko-KR"); _tts.setSpeechRate(0.35); _speakQuestion(); }
  void _speakQuestion() {
    final q = _quizList[_step]; final word = q['word'] as String; final blank = q['blank'] as int;
    final chars = word.split(''); chars[blank] = '빈칸'; _tts.speak(chars.join(' '));
  }
  void _select(String opt) {
    if (_answered) return;
    final q = _quizList[_step]; final answer = (q['word'] as String)[q['blank'] as int];
    setState(() {
      _selected = opt; _answered = true;
      if (opt == answer) { _correct++; _tts.speak('딩동댕! 정답이에요!'); } else { _tts.speak('아쉬워요. 정답은 $answer 예요.'); }
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _quizList[_step]; final word = q['word'] as String; final blank = q['blank'] as int;
    final chars = word.split('');

    return Scaffold(
      appBar: AppBar(title: Text('🔤 빈칸 채우기 ${_step + 1}/${_quizList.length}'), backgroundColor: Colors.blue[500], foregroundColor: Colors.white),
      backgroundColor: Colors.blue[50],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_step + 1) / _quizList.length, minHeight: 12, color: Colors.blue),
            const SizedBox(height: 30),
            Text(q['hint'], style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(chars.length, (i) {
                final isBlank = i == blank;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6), width: 56, height: 56,
                  decoration: BoxDecoration(color: isBlank ? Colors.yellow[100] : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue)),
                  child: Center(child: Text(isBlank ? (_answered ? _selected ?? '_' : '_') : chars[i], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
                );
              }),
            ),
            const Spacer(),
            Wrap(
              spacing: 16, runSpacing: 16,
              children: (q['options'] as List<String>).map((opt) => SizedBox(
                width: 120, height: 70,
                child: ElevatedButton(onPressed: () => _select(opt), child: Text(opt, style: const TextStyle(fontSize: 26))),
              )).toList(),
            ),
            const SizedBox(height: 20),
            if (_answered) ElevatedButton(onPressed: () {
              if (_step + 1 < _quizList.length) { setState(() { _step++; _selected = null; _answered = false; }); _speakQuestion(); } else { Navigator.pop(context); }
            }, child: const Text('다음으로')),
          ],
        ),
      ),
    );
  }
}