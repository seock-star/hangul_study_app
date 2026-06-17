import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class WordOrderGameScreen extends StatefulWidget {
  const WordOrderGameScreen({super.key});
  @override
  State<WordOrderGameScreen> createState() => _WordOrderGameScreenState();
}

class _WordOrderGameScreenState extends State<WordOrderGameScreen> {
  final FlutterTts _tts = FlutterTts();
  final List<Map<String, dynamic>> _quizList = [{'word': '사과', 'hint': '🍎'}, {'word': '바나나', 'hint': '🍌'}];
  int _step = 0; List<String> _shuffled = []; List<String> _answer = []; bool _answered = false;

  @override
  void initState() { super.initState(); _tts.setLanguage("ko-KR"); _tts.setSpeechRate(0.35); _initStep(); }
  void _initStep() { _shuffled = _quizList[_step]['word'].toString().split('')..shuffle(); _answer = []; _answered = false; }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔀 순서 맞추기'), backgroundColor: Colors.green[600], foregroundColor: Colors.white),
      backgroundColor: Colors.green[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_quizList[_step]['hint'], style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text(_answer.join(' '), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 40),
            Wrap(
              spacing: 12,
              children: _shuffled.asMap().entries.map((e) => ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
                onPressed: () { setState(() { _answer.add(e.value); _shuffled.removeAt(e.key); if(_shuffled.isEmpty) _answered = true; }); },
                child: Text(e.value, style: const TextStyle(fontSize: 28)),
              )).toList(),
            ),
            const SizedBox(height: 40),
            if (_answered) ElevatedButton(onPressed: () {
              if (_step + 1 < _quizList.length) { setState(() { _step++; _initStep(); }); } else { Navigator.pop(context); }
            }, child: const Text('다음 문제 👉', style: TextStyle(fontSize: 20)))
          ],
        ),
      ),
    );
  }
}