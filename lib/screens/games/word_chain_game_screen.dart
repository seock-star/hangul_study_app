import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_application_1/utils/quiz_data_loader.dart';

class WordChainGameScreen extends StatefulWidget {
  const WordChainGameScreen({super.key});
  @override
  State<WordChainGameScreen> createState() => _WordChainGameScreenState();
}

class _WordChainGameScreenState extends State<WordChainGameScreen> {
  final FlutterTts _tts = FlutterTts();

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

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _initGame() {
    _rounds = List.of(_allRounds)..shuffle();
    _rounds = _rounds.take(10).toList();
    setState(() {
      _step = 0;
      _correct = 0;
      _selected = null;
      _answered = false;
    });
    Future.delayed(const Duration(milliseconds: 400), _speakQuestion);
  }

  void _speakQuestion() {
    final r = _rounds[_step];
    final chain = r['chain'] as String;
    final lastChar = chain[chain.length - 1];
    _tts.speak(
        '"$chain"의 마지막 글자는 "$lastChar"입니다. 이 글자로 시작하는 단어를 고르세요!');
  }

  void _select(String opt) {
    if (_answered) return;
    final answer = _rounds[_step]['answer'] as String;
    setState(() {
      _selected = opt;
      _answered = true;
    });
    if (opt == answer) {
      _correct++;
      _tts.speak('${getRandomPraise()} $opt 맞아요!');
    } else {
      _tts.speak('아쉬워요. 정답은 $answer 예요.');
    }
  }

  void _next() {
    if (_step + 1 >= _rounds.length) {
      _showResult();
      return;
    }
    setState(() {
      _step++;
      _selected = null;
      _answered = false;
    });
    Future.delayed(const Duration(milliseconds: 400), _speakQuestion);
  }

  void _showResult() {
    _tts.speak('끝말잇기를 모두 마쳤어요! $_correct개 맞혔어요! 어휘력이 정말 대단하세요!');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 끝말잇기 완료!',
            style: TextStyle(fontSize: 26),
            textAlign: TextAlign.center),
        content: Text(
          '${_rounds.length}문제 중 $_correct개 맞혔어요!\n어휘력이 대단해요! 🏆',
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
                    _initGame();
                  },
                  child: const Text('다시 하기'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[500],
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
    if (_rounds.isEmpty) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final r = _rounds[_step];
    final answer = r['answer'] as String;
    final chain = r['chain'] as String;
    final lastChar = chain[chain.length - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text('🔗 끝말잇기  ${_step + 1}/${_rounds.length}',
            style: const TextStyle(fontSize: 20)),
        backgroundColor: Colors.purple[500],
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
                      value: (_step + 1) / _rounds.length,
                      minHeight: 14,
                      color: Colors.purple,
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${_step + 1} / ${_rounds.length}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),

            // ── 현재 단어 카드 ──
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [Colors.purple[300]!, Colors.purple[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 28, horizontal: 20),
                child: Column(
                  children: [
                    // 현재 단어
                    Text(
                      chain,
                      style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // 마지막 글자 강조
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          Text(
                            '"$lastChar"(으)로 시작하는 단어는?',
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          IconButton(
                            icon: const Icon(Icons.volume_up,
                                color: Colors.white, size: 24),
                            onPressed: _speakQuestion,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 힌트
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        r['hint'],
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── 보기 버튼 ──
            ...(r['options'] as List<String>).map((opt) {
              Color bgColor = Colors.white;
              Color borderColor = Colors.purple[200]!;
              Color textColor = Colors.black87;
              IconData? icon;

              if (_answered) {
                if (opt == answer) {
                  bgColor = Colors.green[50]!;
                  borderColor = Colors.green;
                  textColor = Colors.green[800]!;
                  icon = Icons.check_circle;
                } else if (opt == _selected) {
                  bgColor = Colors.red[50]!;
                  borderColor = Colors.red;
                  textColor = Colors.red[800]!;
                  icon = Icons.cancel;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GestureDetector(
                  onTap: () => _select(opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(18),
                      border:
                          Border.all(color: borderColor, width: 2.5),
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
                              fontSize: 26,
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

            // ── 다음 문제 버튼 ──
            if (_answered)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _selected == answer ? Colors.green : Colors.orange,
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
                  _step + 1 >= _rounds.length
                      ? '결과 보기 🏆'
                      : _selected == answer
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