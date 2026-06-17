import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AdvancedLearningScreen extends StatefulWidget {
  const AdvancedLearningScreen({super.key});

  @override
  State<AdvancedLearningScreen> createState() => _AdvancedLearningScreenState();
}

class _AdvancedLearningScreenState extends State<AdvancedLearningScreen> {
  final FlutterTts flutterTts = FlutterTts();

  final List<Map<String, dynamic>> advancedList = [
    {
      'title': 'ㄱ (기역) 조합',
      'letters': ['가', '갸', '거', '겨', '고', '교', '구', '규', '그', '기']
    },
    {
      'title': 'ㄴ (니은) 조합',
      'letters': ['나', '냐', '너', '녀', '노', '뇨', '누', '뉴', '느', '니']
    },
    {
      'title': 'ㄷ (디귿) 조합',
      'letters': ['다', '댜', '더', '뎌', '도', '됴', '두', '듀', '드', '디']
    },
    {
      'title': 'ㄹ (리을) 조합',
      'letters': ['라', '랴', '러', '려', '로', '료', '루', '류', '르', '리']
    },
    {
      'title': 'ㅁ (미음) 조합',
      'letters': ['마', '먀', '머', '며', '모', '묘', '무', '뮤', '므', '미']
    },
    {
      'title': 'ㅂ (비읍) 조합',
      'letters': ['바', '뱌', '버', '벼', '보', '뵤', '부', '뷰', '브', '비']
    },
  ];

  @override
  void initState() {
    super.initState();
    setKoreanVoice();
  }

  Future<void> setKoreanVoice() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.35); // 동일한 느린 속도[cite: 2]
    await flutterTts.setPitch(1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('심화 학습'),
        backgroundColor: Colors.teal[400],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15.0),
        itemCount: advancedList.length,
        itemBuilder: (context, index) {
          var item = advancedList[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 20),
            color: Colors.teal[50],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  const Divider(color: Colors.teal),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(item['letters'].length, (letterIndex) {
                      String letter = item['letters'][letterIndex];
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          flutterTts.speak(letter);
                          // 🌟 여기도 나중에 실습 화면으로 예쁘게 꽂아줄게요!
                        },
                        child: Text(letter, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}