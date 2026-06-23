import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_application_1/utils/quiz_data_loader.dart';

class MatchingGameScreen extends StatefulWidget {
  const MatchingGameScreen({super.key});
  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  final FlutterTts _tts = FlutterTts();

  List<PracticalWord> _pairs = [];
  int? _selectedIconIndex;
  int? _selectedWordIndex;
  Set<int> _matchedIndexes = {};
  Set<int> _wrongIconIndexes = {};
  Set<int> _wrongWordIndexes = {};
  bool _isChecking = false;
  int _tries = 0;
  bool _isLoading = true;
  late List<int> _shuffledWordOrder;

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

  Future<void> _initGame() async {
    setState(() => _isLoading = true);
    final words = await loadRandomPracticalWords(6);
    final order = List.generate(6, (i) => i)..shuffle(Random());
    setState(() {
      _pairs = words;
      _shuffledWordOrder = order;
      _selectedIconIndex = null;
      _selectedWordIndex = null;
      _matchedIndexes = {};
      _wrongIconIndexes = {};
      _wrongWordIndexes = {};
      _tries = 0;
      _isLoading = false;
    });
    // 시작 안내
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _tts.speak('그림과 글자를 짝지어 맞춰보세요!');
  }

  void _onIconTap(int index) {
    if (_isChecking) return;
    if (_matchedIndexes.contains(index)) return;
    _tts.speak(_pairs[index].word);
    setState(() {
      _selectedIconIndex = index;
      _wrongIconIndexes = {};
      _wrongWordIndexes = {};
    });
    if (_selectedWordIndex != null) _checkMatch();
  }

  void _onWordTap(int shuffledIndex) {
    if (_isChecking) return;
    final realIndex = _shuffledWordOrder[shuffledIndex];
    if (_matchedIndexes.contains(realIndex)) return;
    _tts.speak(_pairs[realIndex].word);
    setState(() {
      _selectedWordIndex = realIndex;
      _wrongIconIndexes = {};
      _wrongWordIndexes = {};
    });
    if (_selectedIconIndex != null) _checkMatch();
  }

  void _checkMatch() {
    _isChecking = true;
    final iconIdx = _selectedIconIndex!;
    final wordIdx = _selectedWordIndex!;

    if (iconIdx == wordIdx) {
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _matchedIndexes.add(iconIdx);
          _selectedIconIndex = null;
          _selectedWordIndex = null;
          _isChecking = false;
          _tries++;
        });
        if (_matchedIndexes.length == 6) {
          Future.delayed(const Duration(milliseconds: 400), () {
            _tts.speak(getRandomPraise());
            Future.delayed(
                const Duration(milliseconds: 1200), _showResult);
          });
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {
          _wrongIconIndexes = {iconIdx};
          _wrongWordIndexes = {wordIdx};
          _tries++;
        });
        _tts.speak('다시 해보세요');
        Future.delayed(const Duration(milliseconds: 900), () {
          setState(() {
            _selectedIconIndex = null;
            _selectedWordIndex = null;
            _wrongIconIndexes = {};
            _wrongWordIndexes = {};
            _isChecking = false;
          });
        });
      });
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 모두 찾았어요!',
            style: TextStyle(fontSize: 26),
            textAlign: TextAlign.center),
        content: Text(
          '시도 횟수: $_tries 번\n훌륭해요! 👏',
          style: const TextStyle(fontSize: 22, height: 1.6),
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
                    backgroundColor: Colors.deepPurple[300],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: Text('🃏 짝 맞추기  ${_matchedIndexes.length} / 6 쌍',
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple[300],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _tts.stop();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            tooltip: '새 게임',
            onPressed: _initGame,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── 진행 바 상단 고정 ──
          LinearProgressIndicator(
            value: _matchedIndexes.length / 6,
            minHeight: 10,
            backgroundColor: Colors.deepPurple[50],
            color: Colors.deepPurple[300],
          ),

          // ── 나머지 스크롤 ──
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 8,
              radius: const Radius.circular(8),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [

                    // ── 그림 구역 ──
                    _SectionLabel(
                        icon: '🖼️',
                        label: '그림 카드',
                        color: Colors.orange[700]!),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: 6,
                        itemBuilder: (_, i) => _IconCard(
                          word: _pairs[i],
                          isSelected: _selectedIconIndex == i,
                          isMatched: _matchedIndexes.contains(i),
                          isWrong: _wrongIconIndexes.contains(i),
                          onTap: () => _onIconTap(i),
                        ),
                      ),
                    ),

                    // ── 구분선 ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(children: [
                        Expanded(
                            child: Divider(
                                color: Colors.deepPurple[200],
                                thickness: 1.5)),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          child: Text('👇 맞는 글자를 골라요',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.deepPurple[400])),
                        ),
                        Expanded(
                            child: Divider(
                                color: Colors.deepPurple[200],
                                thickness: 1.5)),
                      ]),
                    ),

                    // ── 글자 구역 ──
                    _SectionLabel(
                        icon: '🔤',
                        label: '글자 카드',
                        color: Colors.deepPurple[600]!),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.4,
                        ),
                        itemCount: 6,
                        itemBuilder: (_, shuffledI) {
                          final realI = _shuffledWordOrder[shuffledI];
                          return _WordCard(
                            word: _pairs[realI].word,
                            isSelected: _selectedWordIndex == realI,
                            isMatched: _matchedIndexes.contains(realI),
                            isWrong: _wrongWordIndexes.contains(realI),
                            onTap: () => _onWordTap(shuffledI),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 구역 레이블 ──
class _SectionLabel extends StatelessWidget {
  final String icon, label;
  final Color color;
  const _SectionLabel(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color)),
      ]),
    );
  }
}

// ── 그림 카드 ──
class _IconCard extends StatelessWidget {
  final PracticalWord word;
  final bool isSelected, isMatched, isWrong;
  final VoidCallback onTap;
  const _IconCard(
      {required this.word,
      required this.isSelected,
      required this.isMatched,
      required this.isWrong,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color borderColor = Colors.orange[200]!;
    double borderWidth = 2;

    if (isMatched) {
      bgColor = Colors.green[100]!;
      borderColor = Colors.green;
      borderWidth = 3;
    } else if (isSelected) {
      bgColor = Colors.orange[50]!;
      borderColor = Colors.orange[700]!;
      borderWidth = 4;
    } else if (isWrong) {
      bgColor = Colors.red[50]!;
      borderColor = Colors.red;
      borderWidth = 4;
    }

    return GestureDetector(
      onTap: isMatched ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isMatched)
              const Text('✅', style: TextStyle(fontSize: 32))
            else
              Text(word.icon, style: const TextStyle(fontSize: 40)),
            if (isSelected && !isMatched)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8, height: 8,
                decoration: const BoxDecoration(
                    color: Colors.orange, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}

// ── 글자 카드 ──
class _WordCard extends StatelessWidget {
  final String word;
  final bool isSelected, isMatched, isWrong;
  final VoidCallback onTap;
  const _WordCard(
      {required this.word,
      required this.isSelected,
      required this.isMatched,
      required this.isWrong,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color borderColor = Colors.deepPurple[200]!;
    Color textColor = Colors.black87;
    double borderWidth = 2;

    if (isMatched) {
      bgColor = Colors.green[100]!;
      borderColor = Colors.green;
      borderWidth = 3;
      textColor = Colors.green[800]!;
    } else if (isSelected) {
      bgColor = Colors.deepPurple[50]!;
      borderColor = Colors.deepPurple[600]!;
      borderWidth = 4;
      textColor = Colors.deepPurple[800]!;
    } else if (isWrong) {
      bgColor = Colors.red[50]!;
      borderColor = Colors.red;
      borderWidth = 4;
      textColor = Colors.red[800]!;
    }

    return GestureDetector(
      onTap: isMatched ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isMatched)
              const Text('✅', style: TextStyle(fontSize: 28))
            else
              Padding(
  padding: const EdgeInsets.symmetric(horizontal: 6),
  child: Text(
    word,
    style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textColor),
    textAlign: TextAlign.center,
    maxLines: 2,              // ← 두 줄 허용
    overflow: TextOverflow.visible, // ← 말줄임 제거
  ),
),
            if (isSelected && !isMatched)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8, height: 8,
                decoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}