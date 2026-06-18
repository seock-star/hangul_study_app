import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_application_1/utils/quiz_data_loader.dart';

/// 앱 켤 때 4시간마다 강제로 나오는 퀴즈 화면
class ForcedQuizScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const ForcedQuizScreen({super.key, required this.onComplete});

  @override
  State<ForcedQuizScreen> createState() => _ForcedQuizScreenState();
}

class _ForcedQuizScreenState extends State<ForcedQuizScreen> {
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
    // 3문제만 (너무 많으면 힘드니까)
    final words = await loadAllPracticalWords();
    final quizList = buildWordQuizList(words, 3);
    setState(() {
      _quizList = quizList;
      _isLoading = false;
    });
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      _tts.speak(
          '공부할 시간이에요! 문제 3개만 풀면 들어갈 수 있어요!');
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
      _showComplete();
      return;
    }
    setState(() {
      _step++;
      _selected = null;
      _answered = false;
    });
  }

  void _showComplete() {
    widget.onComplete();
    _tts.speak('${_quizList.length}문제 중 $_correct개 맞혔어요! 이제 들어가세요!');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 통과!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28)),
        content: Text(
          '${_quizList.length}문제 중 $_correct개 맞혔어요!\n이제 앱을 사용할 수 있어요 😊',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, height: 1.6),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 22),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                _tts.stop();
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pop(context); // 강제퀴즈 화면 닫기
              },
              child: const Text('홈으로 가기 🏠'),
            ),
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

    final quiz = _quizList[_step];
    final correct = quiz.item.word;
    final progress = (_step + 1) / _quizList.length;

    return PopScope(
      // 🌟 뒤로가기 완전 차단!
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.orange[50],
        appBar: AppBar(
          backgroundColor: Colors.orange[700],
          foregroundColor: Colors.white,
          // 🌟 뒤로가기 버튼 없애기
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              const Text('📚 입장 퀴즈',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              // 문제 번호
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_step + 1} / ${_quizList.length}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── 안내 배너 ──
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.orange[700],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Text('🔒', style: TextStyle(fontSize: 28)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '문제 3개를 풀어야\n앱을 사용할 수 있어요!',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── 진행 바 ──
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 14,
                  color: Colors.orange[700],
                  backgroundColor: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 24),

              // ── 문제 카드 ──
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 28, horizontal: 20),
                  child: Column(
                    children: [
                      const Text(
                        '이 그림은 무엇일까요?',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(quiz.item.icon,
                          style: const TextStyle(fontSize: 100)),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.volume_up, size: 20),
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
              const SizedBox(height: 20),

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
                        border: Border.all(
                            color: borderColor, width: 2.5),
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
                          ] else
                            const SizedBox(width: 38),
                          Expanded(
                            child: Text(
                              opt,
                              style: TextStyle(
                                fontSize: 24,
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

              // ── 다음 버튼 ──
              if (_answered)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selected == correct
                        ? Colors.green
                        : Colors.orange,
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
                    _step + 1 >= _quizList.length
                        ? '완료! 들어가기 🏠'
                        : '다음 문제 👉',
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}