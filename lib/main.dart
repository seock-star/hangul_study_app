import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // 🌟 알림 기능을 위한 새로운 부품
import 'package:flutter/services.dart' show rootBundle;
import 'package:signature/signature.dart'; // 글씨 그리기 도구
import 'package:speech_to_text/speech_to_text.dart' as stt; // 음성 인식 도구
import 'package:shared_preferences/shared_preferences.dart'; // 🌟 앱이 꺼져도 기억하게 해주는 '기억 창고' 도구입니다!
// 앱 전체에서 알림 도구를 쓸 수 있게 미리 준비해 둡니다.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


// 🌟 파일을 읽어와서 무작위로 단어들을 뽑아주는 마법의 도우미
Future<List<Map<String, String>>> loadRandomQuizData(int count) async {
  String fileText = await rootBundle.loadString('assets/practical_words.txt');
  var allWords = fileText.split('\n')
      .where((line) => line.contains(':'))
      .map((line) {
        var parts = line.split(':');
        return {'word': parts[1].trim()};
      }).toList();
  
  allWords.shuffle(); // 섞기
  return allWords.take(count).toList(); // count만큼만 가져오기
}

void main() async {
  // 알림 도구를 세팅하기 위해 앱이 시작하기 전에 잠시 준비 시간을 가집니다.
  WidgetsFlutterBinding.ensureInitialized();
  
  // 안드로이드 폰에서 기본 앱 아이콘을 알림 아이콘으로 쓰겠다고 설정합니다.
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
 // 이렇게 앞에 '이름표:'를 붙여주면 끝!
 // 🌟 앞쪽 이름표를 'settings:' 로 딱 바꿔치기해 줘!
  await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);

  runApp(const HangulApp());
}

class HangulApp extends StatelessWidget {
  const HangulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '기초 한글 공부',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomeScreen(),
    );
  }
}

// ----------------------------------------------------
// 1. 첫 화면
// ----------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts flutterTts = FlutterTts();
  String todayWord = ''; 
  List<String> wordList = ['단어 불러오는 중...'];
  int waterCount = 0; // 🌟 화분에 물을 준 횟수를 기억할 공간이에요.

  @override
  void initState() {
    super.initState();
    setKoreanVoice();
    loadWordsFromFile(); 
    setupHourlyAlarm(); 
    _loadPlant(); // 🌟 화면이 켜질 때 화분이 얼마나 자랐는지 창고에서 꺼내옵니다.
  }

  // 🌟 화분 상태 불러오기 기능
  void _loadPlant() async {
    final prefs = await SharedPreferences.getInstance(); // 기억 창고 문 열기
    setState(() {
      waterCount = prefs.getInt('waterCount') ?? 0; // 물 준 횟수 꺼내오기 (없으면 0번)
    });
  }

  // 🌟 메모장에서 단어를 싹 다 읽어오는 마법의 명령어
 Future<void> loadWordsFromFile() async {
    String fileText = await rootBundle.loadString('assets/words.txt');
    setState(() {
      // 🌟 쉼표(,)나 줄바꿈(\n)이 보일 때마다 쪼개고, 양옆의 띄어쓰기 공백을 예쁘게 다듬어 줍니다.
      wordList = fileText.split(RegExp(r'[,\n]')).map((word) => word.trim()).where((word) => word.isNotEmpty).toList();
      pickRandomWord(); 
    });
  }

  // ⏰ 1시간마다 알림을 띄워주는 기능
  void setupHourlyAlarm() async {
    // 안드로이드 13 버전 이상인 최신 폰을 위해 알림 허락을 먼저 구합니다.
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    // 알림의 디자인(중요도, 알림 소리 등)을 설정합니다.
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'study_alarm', 
      '한글 공부 알림', 
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    // 1시간마다(RepeatInterval.hourly) 알림을 반복해서 보여주라고 명령합니다.
    await flutterLocalNotificationsPlugin.periodicallyShow(
      id: 0,
      title: '⏰ 한글 공부할 시간이에요!',
      body: '오늘의 단어와 숙제가 기다리고 있어요. 앱을 켜서 확인해 보세요!',
      repeatInterval: RepeatInterval.hourly,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // 🌟 이 한 줄을 추가해 줘!
    );
  }

  // 🌟 요구사항 1번: 어르신이 듣기 좋게 말하기 속도(SpeechRate)를 대폭 늦춥니다.
  Future<void> setKoreanVoice() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.35); // 원래 1.0이었던 속도를 0.35로 아주 천천히 조절했습니다!
    await flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  void pickRandomWord() {
    final random = Random();
    int randomIndex = random.nextInt(wordList.length);
    setState(() { todayWord = wordList[randomIndex]; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('기초 한글 공부', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[500],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 오늘의 단어 카드 (상단)
            Card(
              elevation: 4,
              color: Colors.blue[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('💡 오늘의 단어: ', style: TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
                    Text(todayWord, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    IconButton(icon: const Icon(Icons.volume_up, size: 30, color: Colors.blue), onPressed: () => speak(todayWord)),
                    IconButton(icon: const Icon(Icons.refresh, size: 26, color: Colors.blueGrey), onPressed: () => pickRandomWord()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // ── 메인 3대 메뉴 버튼 ──
            Expanded(
              child: Column(
                children: [
                  // 1. 화분 (출석체크)
                  Expanded(
                    child: _MainMenuButton(
                      emoji: '🪴',
                      label: '화분',
                      subLabel: '출석 체크',
                      color: Colors.pink[400]!,
                      lightColor: Colors.pink[50]!,
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => PlantScreen(waterCount: waterCount)));
                        _loadPlant(); // 돌아오면 화분 상태 갱신
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. 공부하기
                  Expanded(
                    child: _MainMenuButton(
                      emoji: '📖',
                      label: '공부하기',
                      subLabel: '자음·모음·가나다·심화',
                      color: Colors.green[600]!,
                      lightColor: Colors.green[50]!,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const StudyMenuScreen()));
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. 실습하기
                  Expanded(
                    child: _MainMenuButton(
                      emoji: '✏️',
                      label: '실습하기',
                      subLabel: '낱말·숙제·소리 게임',
                      color: Colors.orange[700]!,
                      lightColor: Colors.orange[50]!,
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => const PracticeMenuScreen()));
                        _loadPlant();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── 메인 메뉴 버튼 위젯 ──
class _MainMenuButton extends StatelessWidget {
  final String emoji;
  final String label;
  final String subLabel;
  final Color color;
  final Color lightColor;
  final VoidCallback onTap;

  const _MainMenuButton({
    required this.emoji,
    required this.label,
    required this.subLabel,
    required this.color,
    required this.lightColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: lightColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color, width: 2.5),
          boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 90,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(22), bottomLeft: Radius.circular(22)),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 48)),
            ),
            const SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 4),
                Text(subLabel, style: const TextStyle(fontSize: 17, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 화분 화면 (출석체크)
// ============================================================
class PlantScreen extends StatelessWidget {
  final int waterCount;
  const PlantScreen({super.key, required this.waterCount});

  String get plantEmoji {
    if (waterCount == 0) return '🪹';
    if (waterCount < 3) return '🌱';
    if (waterCount < 7) return '🌿';
    return '🌸';
  }

  String get plantName {
    if (waterCount == 0) return '빈 화분';
    if (waterCount < 3) return '새싹이 돋았어요!';
    if (waterCount < 7) return '잎사귀가 자랐어요!';
    return '꽃이 활짝 피었어요! 🎉';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🪴 나의 화분'),
        backgroundColor: Colors.pink[400],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.pink[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(plantEmoji, style: const TextStyle(fontSize: 120)),
              const SizedBox(height: 20),
              Text(plantName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.pink)),
              const SizedBox(height: 16),
              Text('물 준 횟수: $waterCount 번', style: const TextStyle(fontSize: 22, color: Colors.black87)),
              const SizedBox(height: 10),
              const Text('숙제를 마치면 물을 줄 수 있어요!', style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 40),
              // 출석 달력 안내
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text('🗓️ 출석 현황', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.pink)),
                      SizedBox(height: 12),
                      Text('매일 숙제를 완료하면\n화분이 쑥쑥 자라요! 🌱', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, height: 1.6)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 공부하기 메뉴 화면
// ============================================================
class StudyMenuScreen extends StatelessWidget {
  const StudyMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 공부하기'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.green[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            _StudyButton(
              emoji: '🔤',
              title: '자음 (ㄱ, ㄴ, ㄷ...)',
              color: Colors.green[700]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningScreen(type: 'consonant', title: '자음'))),
            ),
            const SizedBox(height: 18),
            _StudyButton(
              emoji: '🔡',
              title: '모음 (ㅏ, ㅑ, ㅓ...)',
              color: Colors.teal[600]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningScreen(type: 'vowel', title: '모음'))),
            ),
            const SizedBox(height: 18),
            _StudyButton(
              emoji: '🅰️',
              title: '가나다 (가, 나, 다...)',
              color: Colors.cyan[700]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningScreen(type: 'syllable', title: '가나다'))),
            ),
            const SizedBox(height: 18),
            _StudyButton(
              emoji: '📚',
              title: '심화 학습 (가갸거겨...)',
              color: Colors.indigo[600]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvancedLearningScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudyButton extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _StudyButton({required this.emoji, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 4,
      ),
      onPressed: onTap,
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Text(title),
        ],
      ),
    );
  }
}

// ============================================================
// 실습하기 메뉴 화면
// ============================================================
class PracticeMenuScreen extends StatelessWidget {
  const PracticeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✏️ 실습하기'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.orange[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            _StudyButton(
              emoji: '🖼️',
              title: '숙제 : 실전 낱말 학습',
              color: Colors.blueAccent[400]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PracticalLearningScreen())),
            ),
            const SizedBox(height: 18),
            _StudyButton(
              emoji: '⭐',
              title: '숙제 : 글자 맞히기',
              color: Colors.amber[700]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeworkScreen())),
            ),
            const SizedBox(height: 18),
            _StudyButton(
              emoji: '🎧',
              title: '숙제 : 소리 듣고 맞히기',
              color: Colors.purple[500]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ListeningGameScreen())),
            ),
            const SizedBox(height: 18),
            _StudyButton(
              emoji: '🎮',
              title: '게임하기',
              color: Colors.red[500]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameMenuScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// 🌟 2. 새로 추가된 심화 학습 화면 (가갸거겨...)
// ----------------------------------------------------
class AdvancedLearningScreen extends StatefulWidget {
  const AdvancedLearningScreen({super.key});

  @override
  State<AdvancedLearningScreen> createState() => _AdvancedLearningScreenState();
}

class _AdvancedLearningScreenState extends State<AdvancedLearningScreen> {
  final FlutterTts flutterTts = FlutterTts();

  // ㄱ부터 ㅂ까지 모음(ㅏ,ㅑ,ㅓ,ㅕ,ㅗ,ㅛ,ㅜ,ㅠ,ㅡ,ㅣ)과 조합한 글자 목록
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
    await flutterTts.setSpeechRate(0.35); // 여기도 똑같이 어르신용 느린 속도로!
    await flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('심화 학습'),
        backgroundColor: Colors.teal[400],
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
                  const Divider(color: Colors.teal), // 밑줄을 살짝 그어줍니다.
                  const SizedBox(height: 10),
                  // 글자들을 격자무늬(바둑판)처럼 예쁘게 나열해 주는 부품(Wrap)
                  Wrap(
                    spacing: 10, // 양옆 간격
                    runSpacing: 10, // 위아래 간격
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
                          // 🌟 누르면 3단계 실습 화면으로 넘어갑니다!
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PracticeFlowScreen(
                            letter: letter,
                            sound: letter, // 심화학습은 소리와 글자가 똑같아요
                          )));
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

// ----------------------------------------------------
// 3. 기존 메뉴들 (글자 숙제, 기본 학습 등)
// 아래 화면들도 모두 말하기 속도를 0.35로 대폭 낮췄습니다.
// ----------------------------------------------------
class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});
  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final List<Map<String, dynamic>> quizList = [
    { 'question': 'ㄱ', 'options': ['니은', '기역', '디귿'], 'answer': '기역' },
    { 'question': 'ㅏ', 'options': ['어', '오', '아'], 'answer': '아' },
    { 'question': '가', 'options': ['나', '가', '다'], 'answer': '가' },
  ];
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    setKoreanVoice();
  }

  Future<void> setKoreanVoice() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.35); 
    await flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  void checkAnswer(String selectedOption) {
    String correctAnswer = quizList[currentStep]['answer'];
    if (selectedOption == correctAnswer) {
      speak('딩동댕!');
      setState(() { currentStep++; });
      if (currentStep >= quizList.length) { showCompletionDialog(); }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('앗, 다시 한번 생각해 볼까요? 🤔'), backgroundColor: Colors.red[400], duration: const Duration(seconds: 1)),
      );
    }
  }

  // 🌟 화분에 물 주는 기능!
  void _giveWater() async {
    final prefs = await SharedPreferences.getInstance(); // 기억 창고 열기
    String today = DateTime.now().toString().substring(0, 10); // 오늘 달력 날짜만 글자로 뽑아내기 (예: 2026-06-15)
    String lastDate = prefs.getString('lastWaterDate') ?? '';

    // 오늘 아직 물을 안 줬다면?
    if (today != lastDate) { 
      int count = prefs.getInt('waterCount') ?? 0;
      await prefs.setInt('waterCount', count + 1); // 물 준 횟수 1 올리기
      await prefs.setString('lastWaterDate', today); // 오늘 물 줬다고 달력에 도장 찍기
    }
  }

  void showCompletionDialog() {
    _giveWater(); // 🌟 칭찬 창이 뜨기 직전에 화분에 물을 줍니다!
    
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('🎉 숙제 완료!'),
          content: const Text('대단해요! 오늘의 한글 숙제를 모두 마쳤어요.\n경험치 +50 XP 획득!'),
          actions: [
            TextButton(onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); }, child: const Text('확인', style: TextStyle(fontSize: 20))),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentStep >= quizList.length) { return const Scaffold(); }
    var currentQuiz = quizList[currentStep];
    double progress = currentStep / quizList.length;

    return Scaffold(
      appBar: AppBar(title: const Text('숙제: 글자 맞히기'), backgroundColor: Colors.green[400]),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: progress, minHeight: 15, backgroundColor: Colors.grey[300], color: Colors.green, borderRadius: BorderRadius.circular(10)),
            const SizedBox(height: 50),
            const Text('이 글자는 어떻게 읽을까요?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 30),
            Center(child: Text(currentQuiz['question'], style: const TextStyle(fontSize: 100, fontWeight: FontWeight.bold))),
            const Spacer(),
            ...List.generate(currentQuiz['options'].length, (index) {
              String option = currentQuiz['options'][index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20), textStyle: const TextStyle(fontSize: 24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: () => checkAnswer(option), child: Text(option),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ListeningGameScreen extends StatefulWidget {
  const ListeningGameScreen({super.key});
  @override
  State<ListeningGameScreen> createState() => _ListeningGameScreenState();
}

class _ListeningGameScreenState extends State<ListeningGameScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final List<Map<String, dynamic>> quizList = [
    { 'sound': '나', 'options': ['가', '나', '다'], 'answer': '나' },
    { 'sound': '어', 'options': ['아', '어', '오'], 'answer': '어' },
    { 'sound': '우', 'options': ['오', '우', '유'], 'answer': '우' },
    { 'sound': '바', 'options': ['마', '바', '사'], 'answer': '바' },
  ];
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    setKoreanVoice();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) speak(quizList[currentStep]['sound']);
    });
  }

  Future<void> setKoreanVoice() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.35);
    await flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  void checkAnswer(String selectedOption) {
    String correctAnswer = quizList[currentStep]['answer'];
    if (selectedOption == correctAnswer) {
      speak('딩동댕!');
      setState(() { currentStep++; });
      if (currentStep >= quizList.length) {
        showCompletionDialog();
      } else {
        Future.delayed(const Duration(seconds: 1), () { speak(quizList[currentStep]['sound']); });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('앗, 다른 소리 같아요! 다시 들어볼까요? 🎧'), backgroundColor: Colors.red[400], duration: const Duration(seconds: 1)),
      );
    }
  }

  void showCompletionDialog() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('🎉 듣기 평가 완료!'),
          content: const Text('황금 귀를 가지셨네요!\n경험치 +100 XP 획득!'),
          actions: [
            TextButton(onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); }, child: const Text('확인', style: TextStyle(fontSize: 20))),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentStep >= quizList.length) { return const Scaffold(); }
    var currentQuiz = quizList[currentStep];
    double progress = currentStep / quizList.length;

    return Scaffold(
      appBar: AppBar(title: const Text('소리 듣고 맞히기'), backgroundColor: Colors.purple[400]),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: progress, minHeight: 15, backgroundColor: Colors.grey[300], color: Colors.purple, borderRadius: BorderRadius.circular(10)),
            const SizedBox(height: 50),
            const Text('스피커를 누르고 어떤 글자인지 맞춰보세요!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(40), backgroundColor: Colors.purple[100], elevation: 8),
                onPressed: () => speak(currentQuiz['sound']), child: const Icon(Icons.volume_up, size: 80, color: Colors.purple),
              ),
            ),
            const SizedBox(height: 20),
            const Center(child: Text('소리 다시 듣기', style: TextStyle(fontSize: 16, color: Colors.grey))),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(currentQuiz['options'].length, (index) {
                String option = currentQuiz['options'][index];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 30), textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: () => checkAnswer(option), child: Text(option),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

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
  void initState() { super.initState(); setKoreanVoice(); }
  Future<void> setKoreanVoice() async { await flutterTts.setLanguage("ko-KR"); await flutterTts.setSpeechRate(0.35); await flutterTts.setPitch(1.0); }
  Future<void> speak(String text) async { await flutterTts.speak(text); }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> currentList;
    if (widget.type == 'consonant') { currentList = consonants; } 
    else if (widget.type == 'vowel') { currentList = vowels; } 
    else { currentList = syllables; }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.green[400]),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: currentList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
             onTap: () {
                // 🌟 누르면 3단계 실습 화면으로 넘어갑니다!
                Navigator.push(context, MaterialPageRoute(builder: (context) => PracticeFlowScreen(
                  letter: currentList[index]['letter']!,
                  sound: currentList[index]['sound']!,
                )));
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
// ----------------------------------------------------
// 🌟 대망의 3단계 실습 화면 (1. 듣기 -> 2. 따라쓰기 -> 3. 발음하기)
// ----------------------------------------------------
class PracticeFlowScreen extends StatefulWidget {
  final String letter;
  final String sound;
  const PracticeFlowScreen({super.key, required this.letter, required this.sound});

  @override
  State<PracticeFlowScreen> createState() => _PracticeFlowScreenState();
}

class _PracticeFlowScreenState extends State<PracticeFlowScreen> {
  int step = 1; // 1: 듣기, 2: 따라쓰기, 3: 발음하기
  
  final FlutterTts flutterTts = FlutterTts();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 15, // 어르신들이 쓰기 좋게 펜을 두껍게 설정
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _spokenText = "버튼을 누르고 말해보세요!";
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initStt();
  }

void _initTts() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.35); // 어르신용 느린 속도
    
    // 🌟 화면이 켜지자마자 1단계 안내 멘트를 바로 읽어줍니다!
    _speakInstruction(1);
  }

  // 🌟 각 단계별로 친절하게 안내 방송을 해주는 기능 (새로 추가)
  void _speakInstruction(int currentStep) async {
    if (currentStep == 1) {
      await flutterTts.speak('글자를 보고 소리를 들어보세요.');
    } else if (currentStep == 2) {
      // 쉼표(,)를 넣으면 핸드폰이 숨을 살짝 쉬면서 더 자연스럽게 읽어줘요.
      await flutterTts.speak('아래 빈칸에 직접, ${widget.letter}, 글자를 써보세요.'); 
    } else if (currentStep == 3) {
      await flutterTts.speak('마이크 버튼을 누르고, ${widget.sound}, 라고 또박또박 말해보세요!');
    }
  }

  void _initStt() async {
    await _speechToText.initialize(); // 음성 인식 도구 준비
  }

  void _speakLetter() {
    flutterTts.speak(widget.sound);
  }

  void _listenToVoice() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          localeId: "ko_KR",
          onResult: (result) {
            setState(() {
              _spokenText = result.recognizedWords;
              // 🌟 인식한 목소리에 해당 글자(가)나 소리(기역)가 포함되어 있으면 정답 처리!
              if (_spokenText.contains(widget.letter) || _spokenText.contains(widget.sound)) {
                _isCorrect = true;
              }
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // AppBar 뒤로가기 버튼은 Flutter가 자동으로 만들어 주므로 살려둠 (언제든 전 메뉴로 복귀 가능)
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.letter} 학습하기'),
        backgroundColor: Colors.blue[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 현재 몇 단계인지 알려주는 상태바
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('1. 듣기', style: TextStyle(fontSize: 18, fontWeight: step >= 1 ? FontWeight.bold : FontWeight.normal, color: step >= 1 ? Colors.blue : Colors.grey)),
                Text('👉 2. 따라쓰기', style: TextStyle(fontSize: 18, fontWeight: step >= 2 ? FontWeight.bold : FontWeight.normal, color: step >= 2 ? Colors.blue : Colors.grey)),
                Text('👉 3. 발음하기', style: TextStyle(fontSize: 18, fontWeight: step >= 3 ? FontWeight.bold : FontWeight.normal, color: step >= 3 ? Colors.blue : Colors.grey)),
              ],
            ),
            const SizedBox(height: 30),

            // ------------------ [1단계: 소리 듣기] ------------------
            if (step == 1) ...[
              const Text('글자를 보고 소리를 들어보세요.', style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
              const Spacer(),
              Center(child: Text(widget.letter, style: const TextStyle(fontSize: 150, fontWeight: FontWeight.bold))),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.volume_up, size: 40, color: Colors.blue),
                label: const Text(' 소리 듣기'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20), textStyle: const TextStyle(fontSize: 24)),
                onPressed: _speakLetter,
              ),
              const SizedBox(height: 20),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(20), textStyle: const TextStyle(fontSize: 24)),
                onPressed: () { 
                  setState(() { step = 2; }); 
                  _speakInstruction(2); // 🌟 2단계로 넘어가면서 안내 멘트 소리 내기!
                },
                child: const Text('다음으로 👉'),
              )
            ],

            // ------------------ [2단계: 따라쓰기] ------------------
            if (step == 2) ...[
              Text('아래 빈칸에 직접 "${widget.letter}" 글자를 써보세요.', style: const TextStyle(fontSize: 22), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              // 그림 그리는 스케치북 도구
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 3), borderRadius: BorderRadius.circular(10)),
                child: Signature(controller: _signatureController, height: 300, backgroundColor: Colors.yellow[50]!),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh), label: const Text('지우기'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15), textStyle: const TextStyle(fontSize: 20)),
                    onPressed: () => _signatureController.clear(),
                  ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(15), textStyle: const TextStyle(fontSize: 20)),
                    onPressed: () { 
                      setState(() { step = 3; }); 
                      _speakInstruction(3); // 🌟 3단계로 넘어가면서 안내 멘트 소리 내기!
                    },
                    child: const Text('다음으로 👉'),
                  ),
                ],
              )
            ],

            // ------------------ [3단계: 발음하기] ------------------
            if (step == 3) ...[
              Text('마이크 버튼을 누르고 "${widget.sound}" 라고 또박또박 말해보세요!', style: const TextStyle(fontSize: 22), textAlign: TextAlign.center),
              const Spacer(),
              Center(
                child: IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 80, color: _isListening ? Colors.red : Colors.blue),
                  onPressed: _listenToVoice,
                ),
              ),
              const SizedBox(height: 20),
              Text(_spokenText, style: const TextStyle(fontSize: 24, color: Colors.grey), textAlign: TextAlign.center),
              const Spacer(),
              
              // 정답을 맞혔을 때만 '완료' 버튼이 나타납니다!
              if (_isCorrect) ...[
                const Text('🎉 참 잘했어요! 정답입니다!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.all(20), textStyle: const TextStyle(fontSize: 24)),
                  onPressed: () {
                    // 완료 버튼을 누르면 전 메뉴(이전 화면)로 돌아갑니다.
                    Navigator.pop(context); 
                  },
                  child: const Text('완료하고 돌아가기 🏠'),
                )
              ] else if (!_isListening && _spokenText != "버튼을 누르고 말해보세요!") ...[
                const Text('다시 한번 천천히 말해볼까요? 🤔', style: TextStyle(fontSize: 20, color: Colors.red), textAlign: TextAlign.center),
              ]
            ],
          ],
        ),
      ),
    );
  }
}
class PracticalLearningScreen extends StatefulWidget {
  const PracticalLearningScreen({super.key});
  @override
  State<PracticalLearningScreen> createState() => _PracticalLearningScreenState();
}
class _PracticalLearningScreenState extends State<PracticalLearningScreen> {
  List<Map<String, String>> practicalWords = [];
  int currentIndex = 0;
  final SignatureController _sigController = SignatureController(penStrokeWidth: 10, penColor: Colors.black);
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadDataFromFile(); 
  }

  Future<void> _loadDataFromFile() async {
    String fileText = await rootBundle.loadString('assets/practical_words.txt');
    setState(() {
      practicalWords = fileText.split('\n')
          .where((line) => line.contains(':'))
          .map((line) {
            var parts = line.split(':');
            return {'icon': parts[0].trim(), 'word': parts[1].trim()};
          }).toList();
    });
    _playInstruction();
  }

  void _playInstruction() async {
    await flutterTts.setSpeechRate(0.35);
    await flutterTts.speak('사진을 보고 무엇인지 들어보세요. 그 다음 아래에 따라 써보세요.');
    await Future.delayed(const Duration(seconds: 3));
    if (practicalWords.isNotEmpty) {
      await flutterTts.speak(practicalWords[currentIndex]['word']!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (practicalWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('실전 낱말 학습')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    var item = practicalWords[currentIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('실전 낱말 학습')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(item['icon']!, style: const TextStyle(fontSize: 100)),
            Text(item['word']!, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(10)),
              child: Signature(controller: _sigController, backgroundColor: Colors.white),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () => _sigController.clear(), child: const Text('지우기')),
                ElevatedButton(onPressed: () {
                  if (currentIndex < practicalWords.length - 1) {
                    setState(() { currentIndex++; _sigController.clear(); _playInstruction(); });
                  } else { Navigator.pop(context); }
                }, child: const Text('다음 단어 👉')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
class ForcedQuizScreen extends StatefulWidget {
  const ForcedQuizScreen({super.key});

  @override
  State<ForcedQuizScreen> createState() => _ForcedQuizScreenState();
}

class _ForcedQuizScreenState extends State<ForcedQuizScreen> {
  final FlutterTts flutterTts = FlutterTts();
  // 퀴즈 데이터 (나중에는 파일에서 불러오도록 확장할 수 있어)
  final List<Map<String, dynamic>> quizData = [
    {'q': 'ㄱ', 'a': '기역', 'o': ['기역', '니은', '디귿']},
    {'q': '가', 'a': '가', 'o': ['나', '가', '다']},
    {'q': '사과', 'a': '사과', 'o': ['바나나', '포도', '사과']},
  ];
  
  late Map<String, dynamic> currentQuiz;

  @override
  void initState() {
    super.initState();
    currentQuiz = quizData[Random().nextInt(quizData.length)];
    _speakQuestion();
  }

  void _speakQuestion() async {
    await flutterTts.setSpeechRate(0.35);
    await flutterTts.speak('공부 시작 전에 문제 하나 풀어볼까요? ${currentQuiz['q']}는 무엇일까요?');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('오늘의 입장 퀴즈', style: TextStyle(fontSize: 24, color: Colors.orange, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Text(currentQuiz['q'], style: const TextStyle(fontSize: 100, fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            ...List.generate(currentQuiz['o'].length, (index) {
              String option = currentQuiz['o'][index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    textStyle: const TextStyle(fontSize: 28),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    if (option == currentQuiz['a']) {
                      // 정답이면 메인 화면으로!
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('다시 한번 생각해보세요! 🤔')));
                    }
                  },
                  child: Text(option),
                ),
              );
            }),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
              child: const Text('건너뛰고 바로 시작하기', style: TextStyle(color: Colors.grey, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
// ============================================================
// 🎮 게임하기 메뉴
// ============================================================
class GameMenuScreen extends StatelessWidget {
  const GameMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 게임하기'),
        backgroundColor: Colors.red[500],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.red[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            _GameMenuCard(
              emoji: '🃏',
              title: '짝 맞추기',
              desc: '그림과 글자를 짝지어 맞춰요',
              color: Colors.pink[400]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MatchingGameScreen())),
            ),
            const SizedBox(height: 16),
            _GameMenuCard(
              emoji: '🔤',
              title: '빈칸 채우기',
              desc: '빠진 글자를 찾아 완성해요',
              color: Colors.blue[500]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FillBlankGameScreen())),
            ),
            const SizedBox(height: 16),
            _GameMenuCard(
              emoji: '🔀',
              title: '순서 맞추기',
              desc: '뒤섞인 글자를 바른 순서로 놓아요',
              color: Colors.green[600]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WordOrderGameScreen())),
            ),
            const SizedBox(height: 16),
            _GameMenuCard(
              emoji: '🎤',
              title: '따라 읽기 챌린지',
              desc: '들리는 단어를 따라 말해요',
              color: Colors.orange[700]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShadowingGameScreen())),
            ),
            const SizedBox(height: 16),
            _GameMenuCard(
              emoji: '🔗',
              title: '끝말잇기',
              desc: '마지막 글자로 시작하는 단어를 골라요',
              color: Colors.purple[500]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WordChainGameScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameMenuCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  final Color color;
  final VoidCallback onTap;

  const _GameMenuCard({required this.emoji, required this.title, required this.desc, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2.5),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 38))),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 🃏 게임 1: 짝 맞추기 (그림 ↔ 글자)
// ============================================================
class MatchingGameScreen extends StatefulWidget {
  const MatchingGameScreen({super.key});
  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  // practical_words.txt 에서 가져온 쉬운 단어 20쌍
  final List<Map<String, String>> _allPairs = [
    {'icon': '🍎', 'word': '사과'}, {'icon': '🍌', 'word': '바나나'},
    {'icon': '🍇', 'word': '포도'}, {'icon': '🐕', 'word': '개'},
    {'icon': '🐈', 'word': '고양이'}, {'icon': '✏️', 'word': '연필'},
    {'icon': '📚', 'word': '책'}, {'icon': '🚗', 'word': '자동차'},
    {'icon': '✈️', 'word': '비행기'}, {'icon': '🏠', 'word': '집'},
    {'icon': '🌙', 'word': '달'}, {'icon': '☀️', 'word': '해'},
    {'icon': '🌊', 'word': '파도'}, {'icon': '🥛', 'word': '우유'},
    {'icon': '🍞', 'word': '빵'}, {'icon': '👒', 'word': '모자'},
    {'icon': '👟', 'word': '운동화'}, {'icon': '⌚', 'word': '시계'},
    {'icon': '🎈', 'word': '풍선'}, {'icon': '🌹', 'word': '장미'},
  ];

  late List<_MatchCard> _cards;
  int? _firstIndex;
  bool _isChecking = false;
  int _matchedCount = 0;
  int _tries = 0;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    // 6쌍 무작위 선택 → 아이콘 카드 + 글자 카드 섞기
    final rand = Random();
    final selected = List.of(_allPairs)..shuffle(rand);
    final pairs = selected.take(6).toList();

    List<_MatchCard> cards = [];
    for (int i = 0; i < pairs.length; i++) {
      cards.add(_MatchCard(id: i, isIcon: true,  text: pairs[i]['icon']!,  word: pairs[i]['word']!));
      cards.add(_MatchCard(id: i, isIcon: false, text: pairs[i]['word']!,  word: pairs[i]['word']!));
    }
    cards.shuffle(rand);
    setState(() {
      _cards = cards;
      _firstIndex = null;
      _matchedCount = 0;
      _tries = 0;
    });
  }

  void _onTap(int index) {
    if (_isChecking) return;
    if (_cards[index].isFlipped || _cards[index].isMatched) return;

    setState(() => _cards[index].isFlipped = true);

    if (_firstIndex == null) {
      _firstIndex = index;
    } else {
      _tries++;
      _isChecking = true;
      final first = _cards[_firstIndex!];
      final second = _cards[index];

      if (first.id == second.id && first.isIcon != second.isIcon) {
        // 정답!
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _cards[_firstIndex!].isMatched = true;
            _cards[index].isMatched = true;
            _matchedCount++;
            _firstIndex = null;
            _isChecking = false;
          });
          if (_matchedCount == 6) _showResult();
        });
      } else {
        // 오답 → 뒤집기
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() {
            _cards[_firstIndex!].isFlipped = false;
            _cards[index].isFlipped = false;
            _firstIndex = null;
            _isChecking = false;
          });
        });
      }
    }
  }

  void _showResult() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 모두 찾았어요!'),
        content: Text('시도 횟수: $_tries 번\n훌륭해요! 👏'),
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
      appBar: AppBar(
        title: Text('🃏 짝 맞추기  |  $_matchedCount / 6 쌍'),
        backgroundColor: Colors.pink[400],
        foregroundColor: Colors.white,
      ),
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
                  color: card.isMatched
                      ? Colors.green[200]
                      : card.isFlipped
                          ? Colors.white
                          : Colors.pink[300],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: card.isMatched ? Colors.green : Colors.pink[200]!, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))],
                ),
                child: Center(
                  child: card.isFlipped || card.isMatched
                      ? Text(card.text, style: TextStyle(fontSize: card.isIcon ? 40 : 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center)
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
  _MatchCard({required this.id, required this.isIcon, required this.text, required this.word, this.isFlipped = false, this.isMatched = false});
}

// ============================================================
// 🔤 게임 2: 빈칸 채우기
// ============================================================
class FillBlankGameScreen extends StatefulWidget {
  const FillBlankGameScreen({super.key});
  @override
  State<FillBlankGameScreen> createState() => _FillBlankGameScreenState();
}

class _FillBlankGameScreenState extends State<FillBlankGameScreen> {
  final FlutterTts _tts = FlutterTts();

  final List<Map<String, dynamic>> _quizList = [
    {'word': '사과', 'blank': 0, 'hint': '🍎', 'options': ['사', '바', '나', '가']},
    {'word': '바나나', 'blank': 0, 'hint': '🍌', 'options': ['바', '사', '가', '나']},
    {'word': '자동차', 'blank': 1, 'hint': '🚗', 'options': ['동', '차', '자', '통']},
    {'word': '비행기', 'blank': 0, 'hint': '✈️', 'options': ['비', '기', '행', '차']},
    {'word': '고양이', 'blank': 1, 'hint': '🐈', 'options': ['양', '고', '이', '강']},
    {'word': '운동화', 'blank': 2, 'hint': '👟', 'options': ['화', '동', '운', '가']},
    {'word': '할머니', 'blank': 0, 'hint': '👵', 'options': ['할', '머', '니', '나']},
    {'word': '학교', 'blank': 1, 'hint': '🏫', 'options': ['교', '학', '원', '장']},
    {'word': '버스', 'blank': 0, 'hint': '🚌', 'options': ['버', '스', '차', '기']},
    {'word': '컴퓨터', 'blank': 2, 'hint': '💻', 'options': ['터', '퓨', '컴', '기']},
  ];

  int _step = 0;
  int _correct = 0;
  String? _selected;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("ko-KR");
    _tts.setSpeechRate(0.35);
    _speakQuestion();
  }

  void _speakQuestion() {
    final q = _quizList[_step];
    final word = q['word'] as String;
    final blank = q['blank'] as int;
    final chars = word.split('');
    chars[blank] = '빈칸';
    _tts.speak(chars.join(' '));
  }

  void _select(String opt) {
    if (_answered) return;
    final q = _quizList[_step];
    final word = q['word'] as String;
    final answer = word[q['blank'] as int];
    setState(() {
      _selected = opt;
      _answered = true;
      if (opt == answer) {
        _correct++;
        _tts.speak('딩동댕! 정답이에요!');
      } else {
        _tts.speak('아쉬워요. 정답은 $answer 예요.');
      }
    });
  }

  void _next() {
    if (_step + 1 >= _quizList.length) {
      _showResult();
    } else {
      setState(() { _step++; _selected = null; _answered = false; });
      _speakQuestion();
    }
  }

  void _showResult() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 완료!'),
        content: Text('${_quizList.length}문제 중 $_correct개 맞혔어요! 👏'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); setState(() { _step = 0; _correct = 0; _selected = null; _answered = false; }); _speakQuestion(); }, child: const Text('다시 하기', style: TextStyle(fontSize: 20))),
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('끝내기', style: TextStyle(fontSize: 20))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _quizList[_step];
    final word = q['word'] as String;
    final blank = q['blank'] as int;
    final answer = word[blank];
    final chars = word.split('');

    return Scaffold(
      appBar: AppBar(
        title: Text('🔤 빈칸 채우기  ${_step + 1}/${_quizList.length}'),
        backgroundColor: Colors.blue[500],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.blue[50],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_step + 1) / _quizList.length, minHeight: 12, color: Colors.blue, backgroundColor: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
            const SizedBox(height: 30),
            Text(q['hint'], style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            // 단어 표시 (빈칸 강조)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(chars.length, (i) {
                final isBlank = i == blank;
                final filled = isBlank && _answered ? _selected ?? '_' : null;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: isBlank
                        ? (_answered ? (_selected == answer ? Colors.green[100] : Colors.red[100]) : Colors.yellow[100])
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isBlank ? Colors.blue : Colors.grey[300]!, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      isBlank ? (filled ?? '_') : chars[i],
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: isBlank ? Colors.blue[800] : Colors.black87),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            IconButton(icon: const Icon(Icons.volume_up, size: 36, color: Colors.blue), onPressed: _speakQuestion),
            const Spacer(),
            Wrap(
              spacing: 16, runSpacing: 16,
              alignment: WrapAlignment.center,
              children: (q['options'] as List<String>).map((opt) {
                Color btnColor = Colors.white;
                if (_answered) {
                  if (opt == answer) btnColor = Colors.green[200]!;
                  else if (opt == _selected) btnColor = Colors.red[200]!;
                }
                return SizedBox(
                  width: 120, height: 70,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: btnColor, foregroundColor: Colors.black87, textStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 4),
                    onPressed: () => _select(opt),
                    child: Text(opt),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            if (_answered)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18), textStyle: const TextStyle(fontSize: 22)),
                onPressed: _next,
                child: Text(_step + 1 >= _quizList.length ? '결과 보기 🏆' : '다음 문제 👉'),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 🔀 게임 3: 순서 맞추기
// ============================================================
class WordOrderGameScreen extends StatefulWidget {
  const WordOrderGameScreen({super.key});
  @override
  State<WordOrderGameScreen> createState() => _WordOrderGameScreenState();
}

class _WordOrderGameScreenState extends State<WordOrderGameScreen> {
  final FlutterTts _tts = FlutterTts();

  final List<Map<String, dynamic>> _quizList = [
    {'word': '사과', 'hint': '🍎'},
    {'word': '바나나', 'hint': '🍌'},
    {'word': '자동차', 'hint': '🚗'},
    {'word': '비행기', 'hint': '✈️'},
    {'word': '고양이', 'hint': '🐈'},
    {'word': '운동화', 'hint': '👟'},
    {'word': '할머니', 'hint': '👵'},
    {'word': '학교', 'hint': '🏫'},
    {'word': '버스', 'hint': '🚌'},
    {'word': '컴퓨터', 'hint': '💻'},
  ];

  int _step = 0;
  int _correct = 0;
  late List<String> _shuffled;
  List<String> _answer = [];
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("ko-KR");
    _tts.setSpeechRate(0.35);
    _initStep();
  }

  void _initStep() {
    final chars = _quizList[_step]['word'].toString().split('');
    _shuffled = List.of(chars)..shuffle(Random());
    _answer = [];
    _answered = false;
    _tts.speak('글자를 순서대로 눌러서 단어를 완성해 보세요!');
  }

  void _pickChar(int i) {
    if (_answered) return;
    setState(() {
      _answer.add(_shuffled[i]);
      _shuffled.removeAt(i);
    });
    if (_shuffled.isEmpty) _checkAnswer();
  }

  void _removeChar(int i) {
    if (_answered) return;
    setState(() {
      _shuffled.add(_answer[i]);
      _answer.removeAt(i);
    });
  }

  void _checkAnswer() {
    final word = _quizList[_step]['word'] as String;
    final composed = _answer.join();
    setState(() => _answered = true);
    if (composed == word) {
      _correct++;
      _tts.speak('딩동댕! $word 맞아요!');
    } else {
      _tts.speak('아쉬워요. 정답은 $word 예요.');
    }
  }

  void _next() {
    if (_step + 1 >= _quizList.length) {
      _showResult();
    } else {
      setState(() { _step++; });
      _initStep();
    }
  }

  void _showResult() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 완료!'),
        content: Text('${_quizList.length}문제 중 $_correct개 맞혔어요!'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); setState(() { _step = 0; _correct = 0; }); _initStep(); }, child: const Text('다시 하기', style: TextStyle(fontSize: 20))),
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('끝내기', style: TextStyle(fontSize: 20))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _quizList[_step];
    final word = q['word'] as String;
    final isCorrect = _answered && _answer.join() == word;

    return Scaffold(
      appBar: AppBar(
        title: Text('🔀 순서 맞추기  ${_step + 1}/${_quizList.length}'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.green[50],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_step + 1) / _quizList.length, minHeight: 12, color: Colors.green, backgroundColor: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
            const SizedBox(height: 24),
            Text(q['hint'], style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 8),
            Text('글자를 순서대로 눌러 단어를 완성하세요!', style: TextStyle(fontSize: 18, color: Colors.green[800])),
            const SizedBox(height: 20),
            // 정답 슬롯
            Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: _answered ? (isCorrect ? Colors.green[100] : Colors.red[100]) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _answer.isEmpty
                    ? [Text('여기에 글자가 채워져요', style: TextStyle(fontSize: 20, color: Colors.grey[400]))]
                    : _answer.asMap().entries.map((e) => GestureDetector(
                        onTap: () => _removeChar(e.key),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 52, height: 52,
                          decoration: BoxDecoration(color: Colors.green[200], borderRadius: BorderRadius.circular(10)),
                          child: Center(child: Text(e.value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
                        ),
                      )).toList(),
              ),
            ),
            if (_answered)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(isCorrect ? '🎉 정답이에요!' : '❌ 정답은 "$word" 예요', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isCorrect ? Colors.green : Colors.red)),
              ),
            const SizedBox(height: 24),
            // 글자 버튼
            Wrap(
              spacing: 12, runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _shuffled.asMap().entries.map((e) => GestureDetector(
                onTap: () => _pickChar(e.key),
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: Colors.green[400], borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))]),
                  child: Center(child: Text(e.value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white))),
                ),
              )).toList(),
            ),
            const Spacer(),
            if (_answered)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18), textStyle: const TextStyle(fontSize: 22)),
                onPressed: _next,
                child: Text(_step + 1 >= _quizList.length ? '결과 보기 🏆' : '다음 문제 👉'),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 🎤 게임 4: 따라 읽기 챌린지
// ============================================================
class ShadowingGameScreen extends StatefulWidget {
  const ShadowingGameScreen({super.key});
  @override
  State<ShadowingGameScreen> createState() => _ShadowingGameScreenState();
}

class _ShadowingGameScreenState extends State<ShadowingGameScreen> {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();

  final List<Map<String, String>> _sentences = [
    {'text': '사과', 'hint': '🍎'},
    {'text': '바나나', 'hint': '🍌'},
    {'text': '자동차', 'hint': '🚗'},
    {'text': '비행기', 'hint': '✈️'},
    {'text': '안녕하세요', 'hint': '👋'},
    {'text': '감사합니다', 'hint': '🙏'},
    {'text': '할머니', 'hint': '👵'},
    {'text': '학교', 'hint': '🏫'},
    {'text': '고양이', 'hint': '🐈'},
    {'text': '운동화', 'hint': '👟'},
  ];

  int _step = 0;
  int _correct = 0;
  bool _isListening = false;
  String _spoken = '';
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("ko-KR");
    _tts.setSpeechRate(0.35);
    _stt.initialize();
    _speakCurrent();
  }

  void _speakCurrent() => _tts.speak(_sentences[_step]['text']!);

  void _listen() async {
    if (_answered) return;
    if (!_isListening) {
      bool avail = await _stt.initialize();
      if (!avail) return;
      setState(() { _isListening = true; _spoken = ''; });
      _stt.listen(localeId: "ko_KR", onResult: (r) {
        setState(() => _spoken = r.recognizedWords);
      });
    } else {
      _stt.stop();
      setState(() => _isListening = false);
      _checkAnswer();
    }
  }

  void _checkAnswer() {
    final target = _sentences[_step]['text']!;
    final isOk = _spoken.contains(target) || target.contains(_spoken.replaceAll(' ', ''));
    setState(() => _answered = true);
    if (isOk) {
      _correct++;
      _tts.speak('잘 하셨어요!');
    } else {
      _tts.speak('아쉬워요. 다시 들어볼까요?');
    }
  }

  void _next() {
    if (_step + 1 >= _sentences.length) {
      _showResult();
    } else {
      setState(() { _step++; _spoken = ''; _answered = false; _isListening = false; });
      Future.delayed(const Duration(milliseconds: 400), _speakCurrent);
    }
  }

  void _showResult() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 완료!'),
        content: Text('${_sentences.length}문제 중 $_correct개 성공! 목소리가 멋져요! 🎤'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); setState(() { _step = 0; _correct = 0; _spoken = ''; _answered = false; }); _speakCurrent(); }, child: const Text('다시 하기', style: TextStyle(fontSize: 20))),
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('끝내기', style: TextStyle(fontSize: 20))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _sentences[_step];
    return Scaffold(
      appBar: AppBar(
        title: Text('🎤 따라 읽기  ${_step + 1}/${_sentences.length}'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.orange[50],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_step + 1) / _sentences.length, minHeight: 12, color: Colors.orange, backgroundColor: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
            const SizedBox(height: 30),
            Text(s['hint']!, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text(s['text']!, style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.volume_up, size: 30),
              label: const Text('다시 듣기'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[300], foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 20), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              onPressed: _speakCurrent,
            ),
            const Spacer(),
            Text('아래 마이크를 누르고 따라 말해보세요!', style: TextStyle(fontSize: 18, color: Colors.orange[800]), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _listen,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? Colors.red : Colors.orange[400],
                  boxShadow: [BoxShadow(color: (_isListening ? Colors.red : Colors.orange).withOpacity(0.4), blurRadius: 20, spreadRadius: 4)],
                ),
                child: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 54, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(_isListening ? '🔴 듣는 중... (다시 누르면 완료)' : '마이크를 눌러 말하세요', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            if (_spoken.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text('내가 한 말: "$_spoken"', style: const TextStyle(fontSize: 18, color: Colors.blueGrey)),
              ),
            if (_answered)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _spoken.contains(s['text']!) || s['text']!.contains(_spoken.replaceAll(' ', '')) ? '🎉 잘 하셨어요!' : '❌ 다시 도전해 보세요!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _spoken.contains(s['text']!) ? Colors.green : Colors.red),
                ),
              ),
            const SizedBox(height: 20),
            if (_answered)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[700], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18), textStyle: const TextStyle(fontSize: 22)),
                onPressed: _next,
                child: Text(_step + 1 >= _sentences.length ? '결과 보기 🏆' : '다음 문제 👉'),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 🔗 게임 5: 끝말잇기
// ============================================================
class WordChainGameScreen extends StatefulWidget {
  const WordChainGameScreen({super.key});
  @override
  State<WordChainGameScreen> createState() => _WordChainGameScreenState();
}

class _WordChainGameScreenState extends State<WordChainGameScreen> {
  final FlutterTts _tts = FlutterTts();

  // 단어 체인 세트 (시작단어, 선택지 3개, 정답)
  final List<Map<String, dynamic>> _rounds = [
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
  ];

  int _step = 0;
  int _correct = 0;
  String? _selected;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("ko-KR");
    _tts.setSpeechRate(0.35);
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
    if (opt == answer) {
      _correct++;
      _tts.speak('딩동댕! $opt 맞아요! 잘 하셨어요!');
    } else {
      _tts.speak('아쉬워요. 정답은 $answer 예요.');
    }
  }

  void _next() {
    if (_step + 1 >= _rounds.length) {
      _showResult();
    } else {
      setState(() { _step++; _selected = null; _answered = false; });
      _speakQuestion();
    }
  }

  void _showResult() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 끝말잇기 완료!'),
        content: Text('${_rounds.length}문제 중 $_correct개 맞혔어요! 어휘력이 대단해요! 🏆'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); setState(() { _step = 0; _correct = 0; _selected = null; _answered = false; }); _speakQuestion(); }, child: const Text('다시 하기', style: TextStyle(fontSize: 20))),
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('끝내기', style: TextStyle(fontSize: 20))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _rounds[_step];
    final answer = r['answer'] as String;
    final chain = r['chain'] as String;
    final lastChar = chain[chain.length - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text('🔗 끝말잇기  ${_step + 1}/${_rounds.length}'),
        backgroundColor: Colors.purple[500],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.purple[50],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_step + 1) / _rounds.length, minHeight: 12, color: Colors.purple, backgroundColor: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
            const SizedBox(height: 30),
            // 현재 단어 표시
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.purple[100], borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Text(chain, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('"$lastChar"(으)로 시작하는 단어는?', style: TextStyle(fontSize: 20, color: Colors.purple[800])),
                      IconButton(icon: Icon(Icons.volume_up, color: Colors.purple[700], size: 28), onPressed: _speakQuestion),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(r['hint'], style: TextStyle(fontSize: 18, color: Colors.purple[600], fontWeight: FontWeight.bold)),
            const Spacer(),
            // 선택지
            ...( r['options'] as List<String>).map((opt) {
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
                    elevation: 4,
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  onPressed: () => _select(opt),
                  child: Text(opt),
                ),
              );
            }),
            if (_answered)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[500], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18), textStyle: const TextStyle(fontSize: 22)),
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