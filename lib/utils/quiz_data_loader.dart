import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

// ============================================================
// assets/practical_words.txt 에서 무작위로 단어를 뽑아주는 유틸
// 형식: 🍎:사과
// ============================================================

class PracticalWord {
  final String icon;
  final String word;
  const PracticalWord({required this.icon, required this.word});
}

Future<List<PracticalWord>> loadAllPracticalWords() async {
  final text = await rootBundle.loadString('assets/practical_words.txt');
  return text
      .split('\n')
      .where((line) => line.contains(':'))
      .map((line) {
        final parts = line.split(':');
        return PracticalWord(icon: parts[0].trim(), word: parts[1].trim());
      })
      .toList();
}

Future<List<PracticalWord>> loadRandomPracticalWords(int count) async {
  final all = await loadAllPracticalWords();
  all.shuffle(Random());
  return all.take(count).toList();
}

// ============================================================
// assets/words.txt 에서 일반 단어 목록 로딩
// 형식: 쉼표 또는 줄바꿈 구분
// ============================================================

Future<List<String>> loadAllWords() async {
  final text = await rootBundle.loadString('assets/words.txt');
  return text
      .split(RegExp(r'[,\n]'))
      .map((w) => w.trim())
      .where((w) => w.isNotEmpty && !w.startsWith('['))
      .toList();
}

Future<List<String>> loadRandomWords(int count) async {
  final all = await loadAllWords();
  all.shuffle(Random());
  return all.take(count).toList();
}

// ============================================================
// PracticalWord 목록에서 퀴즈 문제 자동 생성
// 정답 1개 + 오답 2개 = 보기 3개
// ============================================================

class WordQuiz {
  final PracticalWord item;        // 정답 데이터 (아이콘 + 단어)
  final List<String> options;      // 보기 3개 (섞인 상태)
  const WordQuiz({required this.item, required this.options});
}

List<WordQuiz> buildWordQuizList(List<PracticalWord> words, int count) {
  final rand = Random();
  final pool = List.of(words)..shuffle(rand);
  final quizWords = pool.take(count).toList();

  return quizWords.map((item) {
    // 오답 후보: 정답 제외한 나머지에서 2개 무작위
    final others = words.where((w) => w.word != item.word).toList()..shuffle(rand);
    final wrong = others.take(2).map((w) => w.word).toList();
    final options = [...wrong, item.word]..shuffle(rand);
    return WordQuiz(item: item, options: options);
  }).toList();
}
// ============================================================
// 칭찬 멘트 무작위 반환
// ============================================================
final List<String> _praiseMessages = [
  '딩동댕!',
  '정말 잘하셨어요!',
  '대단하세요!',
  '역시 최고세요!',
  '완벽해요!',
  '훌륭하세요!',
  '정확해요!',
  '멋지세요!',
  '대박이에요!',
  '척척박사세요!',
  '천재세요!',
  '이야, 맞혔어요!',
  '짝짝짝! 정답이에요!',
  '역시 다르세요!',
  '감동이에요!',
];

String getRandomPraise() {
  final rand = Random();
  return _praiseMessages[rand.nextInt(_praiseMessages.length)];
}