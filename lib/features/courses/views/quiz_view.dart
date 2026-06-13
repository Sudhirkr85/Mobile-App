import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class Question {
  final String text;
  final List<String> options;
  final int correctOptionIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctOptionIndex,
  });
}

class QuizView extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;

  const QuizView({super.key, required this.lessonId, required this.lessonTitle});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  // Mock questions for course exams
  final List<Question> _questions = [
    Question(
      text: 'What is the runtime complexity of searching in a Balanced Binary Search Tree?',
      options: ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)'],
      correctOptionIndex: 1,
    ),
    Question(
      text: 'Which protocol is used for secure communications over the Internet?',
      options: ['HTTP', 'FTP', 'HTTPS', 'SMTP'],
      correctOptionIndex: 2,
    ),
    Question(
      text: 'In Flutter, which widget is the root configuration for Material design apps?',
      options: ['Scaffold', 'CupertinoApp', 'MaterialApp', 'Container'],
      correctOptionIndex: 2,
    ),
    Question(
      text: 'Which SQL keyword is used to retrieve unique records from a table?',
      options: ['UNIQUE', 'DISTINCT', 'DIFFERENT', 'GROUP BY'],
      correctOptionIndex: 1,
    ),
  ];

  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  final Map<int, int> _userAnswers = {};
  
  // Timer settings
  late Timer _timer;
  int _secondsRemaining = 120; // 2 minutes quiz limit
  bool _isQuizCompleted = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
        _submitQuiz();
      }
    });
  }

  void _nextQuestion() {
    if (_selectedAnswerIndex == null) return;
    
    _userAnswers[_currentQuestionIndex] = _selectedAnswerIndex!;
    
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = _userAnswers[_currentQuestionIndex];
      });
    } else {
      _submitQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedAnswerIndex = _userAnswers[_currentQuestionIndex];
      });
    }
  }

  void _submitQuiz() {
    _timer.cancel();
    setState(() {
      _isQuizCompleted = true;
    });
  }

  int _calculateCorrectAnswers() {
    int score = 0;
    _userAnswers.forEach((qIndex, aIndex) {
      if (_questions[qIndex].correctOptionIndex == aIndex) {
        score++;
      }
    });
    return score;
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isQuizCompleted) {
      return _buildResultsScreen();
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.lessonTitle,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: AppColors.error, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(_secondsRemaining),
                      style: GoogleFonts.firaMono(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator dots
              Row(
                children: List.generate(
                  _questions.length,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: index <= _currentQuestionIndex
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Question Text
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: GoogleFonts.inter(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                currentQuestion.text,
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(height: 40),

              // Options
              ...List.generate(
                currentQuestion.options.length,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _selectedAnswerIndex == index
                        ? AppColors.primary.withOpacity(0.12)
                        : AppColors.surface,
                    border: Border.all(
                      color: _selectedAnswerIndex == index
                          ? AppColors.primary
                          : AppColors.borderLight,
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _selectedAnswerIndex == index
                          ? AppColors.primary
                          : AppColors.border,
                      radius: 14,
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      currentQuestion.options[index],
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedAnswerIndex = index;
                      });
                    },
                  ),
                ),
              ),
              
              const Spacer(),

              // Navigation Actions
              Row(
                children: [
                  if (_currentQuestionIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousQuestion,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'BACK',
                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedAnswerIndex == null ? null : _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _currentQuestionIndex == _questions.length - 1 ? 'SUBMIT' : 'NEXT',
                        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    final correct = _calculateCorrectAnswers();
    final percent = (correct / _questions.length) * 100;
    final isPassed = percent >= 70; // 70% passing threshold matching schema

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isPassed ? '🎉 Congratulations!' : '😢 Keep Practicing',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isPassed ? 'You passed the exam!' : 'You did not meet the passing score of 70%.',
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Circle Indicator Score
              Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(
                      color: isPassed ? AppColors.success : AppColors.error,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isPassed ? AppColors.success : AppColors.error).withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 5,
                      )
                    ]
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${percent.toInt()}%',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$correct / ${_questions.length} Correct',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // Breakdown Review
              Text(
                'Correct answers checklist is stored locally. You can review your quiz records below.',
                style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'CLOSE EXAM',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
