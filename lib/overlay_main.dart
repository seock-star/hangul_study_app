import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_application_1/utils/quiz_data_loader.dart';

// 오버레이 위에 표시될 퀴즈 위젯
@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OverlayQuizApp());
}

class OverlayQuizApp extends StatelessWidget {
  const OverlayQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const OverlayQuizScreen(),
    );
  }
}

class OverlayQuizScreen extends StatefulWidget {
  const OverlayQuizScreen({super.key});
  @override
  State<OverlayQuizScreen> createState() => _OverlayQuizScreenState();
}

class _OverlayQuizScreenState extends State<OverlayQuizScreen> {
  final FlutterTts _tts = FlutterTts();
  List<WordQuiz> _quizList = [];
  int _step = 0;
  int _correct = 0;
  String? _selected;
  bool _answered = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("ko-KR");
    _tts.setSpeechRate(0.35);
    _loadQuiz();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    final words = await loadAllPracticalWords();
    final quizList = buildWordQuizList(words, 3);
    setState(() {
      _quizList = quizList;
      _isLoading = false;
    });
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      _tts.speak('공부 시간이에요! 문제 3개만 풀면 돼요!');
    }
  }

  void _select(String opt) {
    if (_answered) return;
    final correct = _quizList[_step].item.word;
    setState(() {
      _selected = opt;
      _answered = true;
    });
    if (opt == correct) {
      _correct++;
      _tts.speak(getRandomPraise());
    } else {
      _tts.speak('아쉬워요! 정답은 $correct 예요.');
    }
  }

  void _next() {
    if (_step + 1 >= _quizList.length) {
      _complete();
      return;
    }
    setState(() {
      _step++;
      _selected = null;
      _answered = false;
    });
  }

  void _complete() {
    _tts.speak('${_correct}개 맞혔어요! 수고하셨어요!');
    Future.delayed(const Duration(seconds: 2), () {
      // 오버레이 닫기
      FlutterOverlayWindow.closeOverlay();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final quiz = _quizList[_step];
    final correct = quiz.item.word;

    return Scaffold(
      backgroundColor: Colors.orange[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── 헤더 ──
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.orange[700],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Text('🔒',
                        style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        '공부하고 잠금 해제!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // 진행 상태
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_step + 1} / ${_quizList.length}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 진행 바 ──
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (_step + 1) / _quizList.length,
                  minHeight: 12,
                  color: Colors.orange[700],
                  backgroundColor: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 20),

              // ── 문제 카드 ──
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24, horizontal: 16),
                  child: Column(
                    children: [
                      const Text(
                        '이 그림은 무엇일까요?',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(quiz.item.icon,
                          style: const TextStyle(fontSize: 80)),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.volume_up, size: 18),
                        label: const Text('소리 듣기',
                            style: TextStyle(fontSize: 16)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange[700],
                          side: BorderSide(
                              color: Colors.orange[700]!, width: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () => _tts.speak(quiz.item.word),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── 보기 버튼 ──
              ...quiz.options.map((opt) {
                Color bgColor = Colors.white;
                Color borderColor = Colors.grey[300]!;
                Color textColor = Colors.black87;
                IconData? icon;

                if (_answered) {
                  if (opt == correct) {
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
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => _select(opt),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 16),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: borderColor, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          if (icon != null) ...[
                            Icon(icon, color: textColor, size: 24),
                            const SizedBox(width: 10),
                          ] else
                            const SizedBox(width: 34),
                          Expanded(
                            child: Text(
                              opt,
                              style: TextStyle(
                                fontSize: 22,
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

              // ── 다음/완료 버튼 ──
              if (_answered)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selected == correct
                        ? Colors.green
                        : Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _next,
                  child: Text(
                    _step + 1 >= _quizList.length
                        ? '완료! 잠금 해제 🔓'
                        : '다음 문제 👉',
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}