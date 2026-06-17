import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_application_1/screens/study/practice_flow_screen.dart';

class AdvancedLearningScreen extends StatefulWidget {
  const AdvancedLearningScreen({super.key});

  @override
  State<AdvancedLearningScreen> createState() => _AdvancedLearningScreenState();
}

class _AdvancedLearningScreenState extends State<AdvancedLearningScreen> {
  final FlutterTts flutterTts = FlutterTts();

  final List<Map<String, dynamic>> advancedList = [
  {'title': 'ㄱ (기역) 조합', 'letters': ['가','갸','거','겨','고','교','구','규','그','기']},
  {'title': 'ㄴ (니은) 조합', 'letters': ['나','냐','너','녀','노','뇨','누','뉴','느','니']},
  {'title': 'ㄷ (디귿) 조합', 'letters': ['다','댜','더','뎌','도','됴','두','듀','드','디']},
  {'title': 'ㄹ (리을) 조합', 'letters': ['라','랴','러','려','로','료','루','류','르','리']},
  {'title': 'ㅁ (미음) 조합', 'letters': ['마','먀','머','며','모','묘','무','뮤','므','미']},
  {'title': 'ㅂ (비읍) 조합', 'letters': ['바','뱌','버','벼','보','뵤','부','뷰','브','비']},
  {'title': 'ㅅ (시옷) 조합', 'letters': ['사','샤','서','셔','소','쇼','수','슈','스','시']},
  {'title': 'ㅇ (이응) 조합', 'letters': ['아','야','어','여','오','요','우','유','으','이']},
  {'title': 'ㅈ (지읒) 조합', 'letters': ['자','쟈','저','져','조','죠','주','쥬','즈','지']},
  {'title': 'ㅊ (치읓) 조합', 'letters': ['차','챠','처','쳐','초','쵸','추','츄','츠','치']},
  {'title': 'ㅋ (키읔) 조합', 'letters': ['카','캬','커','켜','코','쿄','쿠','큐','크','키']},
  {'title': 'ㅌ (티읕) 조합', 'letters': ['타','탸','터','텨','토','툐','투','튜','트','티']},
  {'title': 'ㅍ (피읖) 조합', 'letters': ['파','퍄','퍼','펴','포','표','푸','퓨','프','피']},
  {'title': 'ㅎ (히읗) 조합', 'letters': ['하','햐','허','혀','호','효','후','휴','흐','히']},
];

  @override
  void initState() {
    super.initState();
    _setKoreanVoice();
  }

  Future<void> _setKoreanVoice() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.35);
    await flutterTts.setPitch(1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('심화 학습'), backgroundColor: Colors.teal[400]),
      body: ListView.builder(
        padding: const EdgeInsets.all(15.0),
        itemCount: advancedList.length,
        itemBuilder: (context, index) {
          final item = advancedList[index];
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
                  Text(item['title'],
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const Divider(color: Colors.teal),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(item['letters'].length, (i) {
                      final letter = item['letters'][i] as String;
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PracticeFlowScreen(letter: letter, sound: letter),
                          ),
                        ),
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
