import 'package:flutter/material.dart';

class WordChainGameScreen extends StatefulWidget {
  const WordChainGameScreen({super.key});
  @override
  State<WordChainGameScreen> createState() => _WordChainGameScreenState();
}

class _WordChainGameScreenState extends State<WordChainGameScreen> {
  final List<Map<String, dynamic>> _rounds = [
    {'chain': '사과', 'options': ['과자', '자동차', '나무'], 'answer': '과자', 'hint': '사과 → 과___'},
    {'chain': '과자', 'options': ['자동차', '가방', '파도'], 'answer': '자동차', 'hint': '과자 → 자___'},
  ];
  int _step = 0; bool _answered = false;

  @override
  Widget build(BuildContext context) {
    var r = _rounds[_step];
    return Scaffold(
      appBar: AppBar(title: const Text('🔗 끝말잇기'), backgroundColor: Colors.purple[500], foregroundColor: Colors.white),
      backgroundColor: Colors.purple[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(r['chain'], style: const TextStyle(fontSize: 58, fontWeight: FontWeight.bold, color: Colors.purple)),
            const SizedBox(height: 10),
            Text(r['hint'], style: const TextStyle(fontSize: 20, color: Colors.grey)),
            const SizedBox(height: 40),
            ...List.generate(r['options'].length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: SizedBox(
                width: 200, height: 60,
                child: ElevatedButton(
                  onPressed: () { setState(() { _answered = true; }); },
                  child: Text(r['options'][i], style: const TextStyle(fontSize: 24)),
                ),
              ),
            )),
            const SizedBox(height: 20),
            if (_answered) ElevatedButton(onPressed: () {
              if (_step + 1 < _rounds.length) { setState(() { _step++; _answered = false; }); } else { Navigator.pop(context); }
            }, child: const Text('다음 단계 👉', style: TextStyle(fontSize: 18)))
          ],
        ),
      ),
    );
  }
}