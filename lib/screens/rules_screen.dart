import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';
import 'sudoku_board_screen.dart';
import 'background_particles.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class RulesScreen extends StatelessWidget {
  const RulesScreen({Key? key}) : super(key: key);

  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.white.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Select Difficulty",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDifficultyButton(context, "🟢 Easy", "easy"),
                  _buildDifficultyButton(context, "🟡 Medium", "medium"),
                  _buildDifficultyButton(context, "🔴 Hard", "hard"),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDifficultyButton(BuildContext context, String label, String difficulty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 5,
        ),
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SudokuBoardScreen(difficulty: difficulty),
            ),
          );
        },
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rules = [
      {
        "icon": Icons.grid_on,
        "text": "Each row must contain the numbers 1-9 **without repetition**."
      },
      {
        "icon": Icons.view_column,
        "text": "Each column must contain the numbers 1-9 **without repetition**."
      },
      {
        "icon": Icons.dashboard,
        "text": "Each 3x3 box must contain the numbers 1-9 **without repetition**."
      },
      {
        "icon": Icons.psychology_alt,
        "text": "**Use logic** and elimination to fill the blanks."
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeInSlide(
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: Lottie.asset("assets/glow.json"),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Master the Grid with Logic.",
                          style: TextStyle(
                            fontSize: 17,
                            fontStyle: FontStyle.italic,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: rules.length,
                      itemBuilder: (context, index) {
                        return FadeInSlide(
                          delay: Duration(milliseconds: 250 * index),
                          child: _buildRuleItem(rules[index]["icon"] as IconData, rules[index]["text"] as String),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 900),
                    child: ElevatedButton.icon(
                      onPressed: () => _showDifficultyDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                        elevation: 10,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 26),
                      label: const Text("Start Game", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(IconData icon, String rule) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurpleAccent, size: 26),
          const SizedBox(width: 16),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: _parseTextWithBold(rule),
                style: const TextStyle(fontSize: 15.5, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _parseTextWithBold(String input) {
    final RegExp boldExp = RegExp(r'\*\*(.*?)\*\*');
    final matches = boldExp.allMatches(input);
    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: input.substring(lastMatchEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < input.length) {
      spans.add(TextSpan(text: input.substring(lastMatchEnd)));
    }
    return spans;
  }
}

class FadeInSlide extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const FadeInSlide({required this.child, this.delay = Duration.zero, Key? key}) : super(key: key);

  @override
  _FadeInSlideState createState() => _FadeInSlideState();
}

class _FadeInSlideState extends State<FadeInSlide> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _offset = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
