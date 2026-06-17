import 'package:flutter/material.dart';
import 'dart:math';

class MatchingGameScreen extends StatefulWidget {
  const MatchingGameScreen({super.key});
  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  final List<Map<String, String>> _allPairs = [
    {'icon': '🍎', 'word': '사과'}, {'icon': '🍌', 'word': '바나나'}, {'icon': '🍇', 'word': '포도'}, {'icon': '🐕', 'word': '개'},
    {'icon': '🐈', 'word': '고양이'}, {'icon': '✏️', 'word': '연필'}, {'icon': '📚', 'word': '책'}, {'icon': '🚗', 'word': '자동차'},
    {'icon': '✈️', 'word': '비행기'}, {'icon': '🏠', 'word': '집'}, {'icon': '🌙', 'word': '달'}, {'icon': '☀️', 'word': '해'},
    {'icon': '🌊', 'word': '파도'}, {'icon': '🥛', 'word': '우유'}, {'icon': '🍞', 'word': '빵'}, {'icon': '👒', 'word': '모자'},
    {'icon': '👟', 'word': '운동화'}, {'icon': '⌚', 'word': '시계'}, {'icon': '🎈', 'word': '풍선'}, {'icon': '🌹', 'word': '장미'},
  ];

  late List<_MatchCard> _cards;
  int? _firstIndex;
  bool _isChecking = false;
  int _matchedCount = 0;
  int _tries = 0;

  @override
  void initState() { super.initState(); _initGame(); }

  void _initGame() {
    final rand = Random();
    final selected = List.of(_allPairs)..shuffle(rand);
    final pairs = selected.take(6).toList();

    List<_MatchCard> cards = [];
    for (int i = 0; i < pairs.length; i++) {
      cards.add(_MatchCard(id: i, isIcon: true,  text: pairs[i]['icon']!,  word: pairs[i]['word']!));
      cards.add(_MatchCard(id: i, isIcon: false, text: pairs[i]['word']!,  word: pairs[i]['word']!));
    }
    cards.shuffle(rand);
    setState(() { _cards = cards; _firstIndex = null; _matchedCount = 0; _tries = 0; });
  }

  void _onTap(int index) {
    if (_isChecking) return;
    if (_cards[index].isFlipped || _cards[index].isMatched) return;

    setState(() => _cards[index].isFlipped = true);

    if (_firstIndex == null) {
      _firstIndex = index;
    } else {
      _tries++; _isChecking = true;
      final first = _cards[_firstIndex!]; final second = _cards[index];

      if (first.id == second.id && first.isIcon != second.isIcon) {
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _cards[_firstIndex!].isMatched = true; _cards[index].isMatched = true;
            _matchedCount++; _firstIndex = null; _isChecking = false;
          });
          if (_matchedCount == 6) _showResult();
        });
      } else {
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() { _cards[_firstIndex!].isFlipped = false; _cards[index].isFlipped = false; _firstIndex = null; _isChecking = false; });
        });
      }
    }
  }

  void _showResult() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 모두 찾았어요!'), content: Text('시도 횟수: $_tries 번\n훌륭해요! 👏'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); _initGame(); }, child: const Text('다시 하기', style: TextStyle(fontSize: 20))),
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('끝내기', style: TextStyle(fontSize: 20))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('🃏 짝 맞추기 | $_matchedCount / 6 쌍'), backgroundColor: Colors.pink[400], foregroundColor: Colors.white),
      backgroundColor: Colors.pink[50],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12),
          itemCount: _cards.length,
          itemBuilder: (context, i) {
            final card = _cards[i];
            return GestureDetector(
              onTap: () => _onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: card.isMatched ? Colors.green[200] : card.isFlipped ? Colors.white : Colors.pink[300],
                  borderRadius: BorderRadius.circular(16), border: Border.all(color: card.isMatched ? Colors.green : Colors.pink[200]!, width: 2),
                ),
                child: Center(
                  child: card.isFlipped || card.isMatched
                      ? Text(card.text, style: TextStyle(fontSize: card.isIcon ? 40 : 22, fontWeight: FontWeight.bold))
                      : const Text('?', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MatchCard {
  final int id; 
  final bool isIcon; 
  final String text; 
  final String word; 
  bool isFlipped; 
  bool isMatched;

  // 🌟 초기화 리스트 작성 시 첫 번째에만 콜론(:)을 쓰고, 그 뒤는 쉼표(,)로 이어붙여야 해!
  _MatchCard({
    required this.id, 
    required this.isIcon, 
    required this.text, 
    required this.word,
    this.isFlipped = false, // 💡 생성자 매개변수 단계에서 기본값을 주거나
    this.isMatched = false,
  });
}