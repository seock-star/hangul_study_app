import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_application_1/utils/quiz_data_loader.dart';

/// 🔗 끝말잇기 - 고정 데이터 (단어 관계가 중요해서 자동생성 어려움)
/// 단, 매번 문제 순서를 섞어서 제공합니다.
class WordChainGameScreen extends StatefulWidget {
  const WordChainGameScreen({super.key});
  @override
  State<WordChainGameScreen> createState() => _WordChainGameScreenState();
}

class _WordChainGameScreenState extends State<WordChainGameScreen> {
  final FlutterTts _tts = FlutterTts();

  // 고정 체인 세트 - 순서는 initState에서 섞음
  final List<Map<String, dynamic>> _allRounds = [
    {'chain': '사과', 'options': ['과자', '자동차', '나무'], 'answer': '과자', 'hint': '사과 → 과___'},
    {'chain': '과자', 'options': ['자동차', '가방', '파도'], 'answer': '자동차', 'hint': '과자 → 자___'},
    {'chain': '자동차', 'options': ['차표', '나무', '하늘'], 'answer': '차표', 'hint': '자동차 → 차___'},
    {'chain': '차표', 'options': ['표범', '바다', '구름'], 'answer': '표범', 'hint': '차표 → 표___'},
    {'chain': '표범', 'options': ['범인', '강물', '산'], 'answer': '범인', 'hint': '표범 → 범___'},
    {'chain': '나무', 'options': ['무지개', '하늘', '바람'], 'answer': '무지개', 'hint': '나무 → 무___'},
    {'chain': '무지개', 'options': ['개나리', '구름', '강'], 'answer': '개나리', 'hint': '무지개 → 개___'},
    {'chain': '바나나', 'options': ['나비', '가방', '물'], 'answer': '나비', 'hint': '바나나 → 나___'},
    {'chain': '나비', 'options': ['비행기', '하늘', '달'], 'answer': '비행기', 'hint': '나비 → 비___'},
    {'chain': '비행기', 'options': ['기차', '배', '버스'], 'answer': '기차', 'hint': '비행기 → 기___'},
    {'chain': '기차', 'options': ['차도', '열차', '사람'], 'answer': '차도', 'hint': '기차 → 차___'},
    {'chain': '차도', 'options': ['도서관', '하늘', '강'], 'answer': '도서관', 'hint': '차도 → 도___'},
  ];

  late List<Map<String, dynamic>> _rounds;
  int _step = 0, _correct = 0;
  String? _selected;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("ko-KR");
    _tts.setSpeechRate(0.35);
    _initGame();
  }

  void _initGame() {
    _rounds = List.of(_allRounds)..shuffle();
    _rounds = _rounds.take(10).toList();
    _step = 0; _correct = 0; _selected = null; _answered = false;
    setState(() {});
    _speakQuestion();
  }

  void _speakQuestion() {
    final r = _rounds[_step];
    final chain = r['chain'] as String;
    final lastChar = chain[chain.length - 1];
    _tts.speak('"$chain"의 마지막 글자는 "$lastChar"입니다. 이 글자로 시작하는 단어를 고르세요!');
  }

  void _select(String opt) {
    if (_answered) return;
    final answer = _rounds[_step]['answer'] as String;
    setState(() { _selected = opt; _answered = true; });
    if (opt == answer) { _correct++; _tts.speak('${getRandomPraise()} $opt 맞아요!'); }
    else { _tts.speak('아쉬워요. 정답은 $answer 예요.'); }
  }

  void _next() {
    if (_step + 1 >= _rounds.length) { _showResult(); return; }
    setState(() { _step++; _selected = null; _answered = false; });
    _speakQuestion();
  }

  void _showResult() {
    showDialog(context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 끝말잇기 완료!'),
        content: Text('${_rounds.length}문제 중 $_correct개 맞혔어요! 어휘력이 대단해요! 🏆'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); _initGame(); }, child: const Text('다시 하기', style: TextStyle(fontSize: 20))),
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('끝내기', style: TextStyle(fontSize: 20))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_rounds.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final r = _rounds[_step];
    final answer = r['answer'] as String;
    final chain = r['chain'] as String;
    final lastChar = chain[chain.length - 1];

    return Scaffold(
      appBar: AppBar(title: Text('🔗 끝말잇기  ${_step + 1}/${_rounds.length}'),
          backgroundColor: Colors.purple[500], foregroundColor: Colors.white),
      backgroundColor: Colors.purple[50],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_step + 1) / _rounds.length, minHeight: 12, color: Colors.purple, backgroundColor: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
            const SizedBox(height: 30),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.purple[100], borderRadius: BorderRadius.circular(20)),
              child: Column(children: [
                Text(chain, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('"$lastChar"(으)로 시작하는 단어는?', style: TextStyle(fontSize: 20, color: Colors.purple[800])),
                  IconButton(icon: Icon(Icons.volume_up, color: Colors.purple[700], size: 28), onPressed: _speakQuestion),
                ]),
              ]),
            ),
            const SizedBox(height: 12),
            Text(r['hint'], style: TextStyle(fontSize: 18, color: Colors.purple[600], fontWeight: FontWeight.bold)),
            const Spacer(),
            ...(r['options'] as List<String>).map((opt) {
              Color btnColor = Colors.white;
              if (_answered) {
                if (opt == answer) btnColor = Colors.green[200]!;
                else if (opt == _selected) btnColor = Colors.red[200]!;
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor, foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    textStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4, minimumSize: const Size(double.infinity, 0),
                  ),
                  onPressed: () => _select(opt),
                  child: Text(opt),
                ),
              );
            }),
            if (_answered) ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[500], foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18), textStyle: const TextStyle(fontSize: 22)),
              onPressed: _next,
              child: Text(_step + 1 >= _rounds.length ? '결과 보기 🏆' : '다음 문제 👉'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
