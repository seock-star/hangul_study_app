import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class LearningScreen extends StatefulWidget {
  final String type;
  final String title;
  const LearningScreen({super.key, required this.type, required this.title});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  final FlutterTts flutterTts = FlutterTts();
  
  final List<Map<String, String>> consonants = const [
    {'letter': 'ㄱ', 'sound': '기역'}, {'letter': 'ㄴ', 'sound': '니은'}, {'letter': 'ㄷ', 'sound': '디귿'}, {'letter': 'ㄹ', 'sound': '리을'},
    {'letter': 'ㅁ', 'sound': '미음'}, {'letter': 'ㅂ', 'sound': '비읍'}, {'letter': 'ㅅ', 'sound': '시옷'}, {'letter': 'ㅇ', 'sound': '이응'},
    {'letter': 'ㅈ', 'sound': '지읒'}, {'letter': 'ㅊ', 'sound': '치읓'}, {'letter': 'ㅋ', 'sound': '키읔'}, {'letter': 'ㅌ', 'sound': '티읕'},
    {'letter': 'ㅍ', 'sound': '피읖'}, {'letter': 'ㅎ', 'sound': '히읗'},
  ];
  
  final List<Map<String, String>> vowels = const [
    {'letter': 'ㅏ', 'sound': '아'}, {'letter': 'ㅑ', 'sound': '야'}, {'letter': 'ㅓ', 'sound': '어'}, {'letter': 'ㅕ', 'sound': '여'},
    {'letter': 'ㅗ', 'sound': '오'}, {'letter': 'ㅛ', 'sound': '요'}, {'letter': 'ㅜ', 'sound': '우'}, {'letter': 'ㅠ', 'sound': '유'},
    {'letter': 'ㅡ', 'sound': '으'}, {'letter': 'ㅣ', 'sound': '이'},
  ];
  
  final List<Map<String, String>> syllables = const [
    {'letter': '가', 'sound': '가'}, {'letter': '나', 'sound': '나'}, {'letter': '다', 'sound': '다'}, {'letter': '라', 'sound': '라'},
    {'letter': '마', 'sound': '마'}, {'letter': '바', 'sound': '바'}, {'letter': '사', 'sound': '사'}, {'letter': '아', 'sound': '아'},
    {'letter': '자', 'sound': '자'}, {'letter': '차', 'sound': '차'}, {'letter': '카', 'sound': '카'}, {'letter': '타', 'sound': '타'},
    {'letter': '파', 'sound': '파'}, {'letter': '하', 'sound': '하'},
  ];

  @override
  void initState() { 
    super.initState(); 
    setKoreanVoice(); 
  }
  
  Future<void> setKoreanVoice() async { 
    await flutterTts.setLanguage("ko-KR"); 
    await flutterTts.setSpeechRate(0.35); // 어르신용 느린 속도
    await flutterTts.setPitch(1.0); 
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> currentList;
    if (widget.type == 'consonant') { currentList = consonants; } 
    else if (widget.type == 'vowel') { currentList = vowels; } 
    else { currentList = syllables; }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.green[400], foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: currentList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                flutterTts.speak(currentList[index]['sound']!);
                // 🌟 나중에 실습 서랍을 만든 뒤 진짜 실습 화면(PracticeFlowScreen)으로 연결해 줄게요!
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${currentList[index]['letter']} 학습을 시작합니다!'), duration: const Duration(milliseconds: 500)),
                );
              },
              child: Card(
                elevation: 4, color: Colors.green[50], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Center(child: Text(currentList[index]['letter']!, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87))),
              ),
            );
          },
        ),
      ),
    );
  }
}