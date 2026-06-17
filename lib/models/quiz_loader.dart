import 'package:flutter/services.dart' show rootBundle;

/// 🌟 [동적 퀴즈 생성 엔진]
/// assets/practical_words.txt 파일에서 전체 단어를 읽어와 
/// 지정한 개수(10개)만큼 무작위로 추출하여 정답과 오답(보기 3개) 세트를 만들어 줍니다.
Future<List<Map<String, dynamic>>> loadDynamicQuizData(int count) async {
  // 1. practical_words.txt 파일에서 전체 텍스트 읽어오기
  String fileText = await rootBundle.loadString('assets/practical_words.txt');
  
  // 2. 텍스트를 한 줄씩 쪼개서 이모지와 단어 분리하기
  var allWords = fileText.split('\n')
      .where((line) => line.contains(':'))
      .map((line) {
        var parts = line.split(':');
        return {
          'icon': parts[0].trim(),
          'word': parts[1].trim()
        };
      }).toList();
  
  // 오답 보기를 만들 때 쓸 전체 단어 텍스트 리스트 따로 추출
  var allWordStrings = allWords.map((item) => item['word'] as String).toList();
  
  // 3. 전체 단어 목록을 무작위로 섞고 원하는 개수(10개)만큼 슬라이싱
  allWords.shuffle();
  var selectedQuizWords = allWords.take(count).toList();
  
  // 4. 각 문제마다 '정답 1개 + 랜덤 오답 2개' 총 3개의 보기를 동적으로 생성
  List<Map<String, dynamic>> structuredQuizList = selectedQuizWords.map((item) {
    String correctAnswer = item['word'] as String;
    String iconHint = item['icon'] as String;
    
    // 보기 리스트에 일단 정답 먼저 추가
    var options = [correctAnswer];
    
    // 전체 단어 중 정답이 아닌 단어들만 걸러내서 무작위로 섞기
    var distractors = allWordStrings.where((w) => w != correctAnswer).toList()..shuffle();
    
    // 섞인 오답 리스트에서 상위 2개를 가져와 보기 목록에 합치기
    options.addAll(distractors.take(2));
    
    // 1번, 2번, 3번 보기 순서를 랜덤하게 재배치 (매번 정답 위치가 달라짐)
    options.shuffle();
    
    return {
      'hint': iconHint,         // 이모지 힌트 (예: 🍎)
      'question': correctAnswer, // 문제 텍스트 (예: 사과)
      'options': options,        // 선택지 3개 리스트 (예: ['바나나', '사과', '가방'])
      'answer': correctAnswer,   // 진짜 정답 텍스트
    };
  }).toList();
  
  return structuredQuizList;
}