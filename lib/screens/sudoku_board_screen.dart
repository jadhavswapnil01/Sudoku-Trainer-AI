import 'package:flutter/material.dart';
import '../widgets/sudoku_grid.dart';
import '../providers/sudoku_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SudokuBoardScreen extends StatelessWidget {
  final String difficulty;
  const SudokuBoardScreen({Key? key, required this.difficulty}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Sudoku Trainer"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<SudokuProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.cyanAccent,
          strokeWidth: 4,
        ),
      );
    }
          return Stack(
            children: [
              // 🧩 Main Scrollable Area
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 160), // extra room for AI box
                  child: Column(
                    key: ValueKey('${provider.sudokuBoard}_${provider.mistakeExplanation}'),
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      // 🎯 Sudoku Board with Glass Panel
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GlassPanel(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: SudokuGrid(
                              board: provider.sudokuBoard,
                              selectedCell: provider.selectedCell,
                              fixedCells: provider.fixedCells,
                              onCellTap: provider.selectCell,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                      // 🔢 Number Input Panel
                       NumberInputPanel(),

                      const SizedBox(height: 20),

                      // 🧠 AI Message Box Area with Animated Padding
                      AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) => SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(animation),
                            child: FadeTransition(opacity: animation, child: child),
                          ),
                          child: Padding(
                            key: ValueKey(provider.aiMessage),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const AIMessageBox(),
                          ),
                        ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // 🧠 Floating AI Pattern Hint Button
              if (provider.showPatternHintButton)
                const Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingPatternHintButton(),
                ),
            ],
          );
        },
      ),
    );
  }
}


class FloatingPatternHintButton extends StatefulWidget {
  const FloatingPatternHintButton({super.key});

  @override
  State<FloatingPatternHintButton> createState() => _FloatingPatternHintButtonState();
}

class _FloatingPatternHintButtonState extends State<FloatingPatternHintButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();

    // Pulse animation
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Auto-hide timer
    _hideTimer = Timer(const Duration(seconds: 15), () {
      final provider = Provider.of<SudokuProvider>(context, listen: false);
      provider.showPatternHintButton = false;
      provider.notifyListeners();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: ElevatedButton.icon(
        key: const ValueKey("pattern_hint"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent.shade700,
          foregroundColor: Colors.black,
          elevation: 12,
         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shadowColor: Colors.tealAccent.withOpacity(0.5),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: const Icon(Icons.psychology_alt_outlined),
        label: const Text("Get Pattern Hint"),
        onPressed: () {
          Provider.of<SudokuProvider>(context, listen: false).revealPatternHint();
        },
      ),
    );
  }
}


class GlassPanel extends StatelessWidget {
  final Widget child;
  const GlassPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: child,
    );
  }
}


class NumberInputPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final numbers = List.generate(9, (i) => (i + 1).toString()) + ['C'];
    final provider = Provider.of<SudokuProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: numbers.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.5,
        ),
        itemBuilder: (context, index) {
          final label = numbers[index];
          final isClear = label == 'C';

          return GestureDetector(
            // onTapDown: (_) => _playTapEffect(context),
            onTap: () {
              if (isClear) {
                provider.clearSelectedCell();
              } else {
                provider.enterNumber(int.parse(label));
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isClear
                      ? [Colors.redAccent.withOpacity(0.9), Colors.red.withOpacity(0.6)]
                      : [Colors.deepPurple.withOpacity(0.85), Colors.purple.withOpacity(0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isClear ? Colors.red : Colors.deepPurple).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    shadows: [
                      Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 2),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // void _playTapEffect(BuildContext context) {
  //   final overlay = Overlay.of(context);
  //   final entry = OverlayEntry(
  //     builder: (_) => Positioned.fill(
  //       child: IgnorePointer(
  //         child: Container(
  //           color: Colors.white.withOpacity(0.02),
  //         ),
  //       ),
  //     ),
  //   );

  //   overlay.insert(entry);
  //   // Future.delayed(const Duration(milliseconds: 80), entry.remove);
  // }
}




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

class AIMessageBox extends StatefulWidget {
  const AIMessageBox({super.key});

  @override
  State<AIMessageBox> createState() => _AIMessageBoxState();
}

class _AIMessageBoxState extends State<AIMessageBox> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _fadeSlideController;
  late AnimationController _buttonShakeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _buttonShakeAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeSlideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _buttonShakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeSlideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _fadeSlideController,
      curve: Curves.easeIn,
    );

    _buttonShakeAnimation = Tween<double>(begin: 0, end: 8)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_buttonShakeController);

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });

    _buttonShakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _buttonShakeController.reset();
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _fadeSlideController.dispose();
    _buttonShakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SudokuProvider>(context);
    final message = provider.aiMessage;
    final deviationCount = provider.deviationCount;

    if (message == null || message.isEmpty) return const SizedBox.shrink();

    _fadeSlideController.forward(from: 0);

    // Categorize messages
    bool isEncouraging = message.contains('✅') ||
        message.contains('🎯') ||
        message.contains('🔍') ||
        message.contains('🚀') ||
        message.contains('🧘') ||
        message.contains('🌟') ||
        message.contains('🥇') ||
        message.contains('😎') ||
        message.contains('🎮') ||
        message.contains('🧩') ||
        message.contains('🔐') ||
        message.contains('📊') ||
        message.contains('😎') ||
        message.contains('💡') ||
        message.contains('🎵') ||
        message.contains('🌌') ||
        message.contains('👣') ||
        message.contains('🤖') ||
        message.contains('📈');

    bool isDanger = message.contains('🛑') ||
        message.contains('⚠️') ||
        message.contains('❗️') ||
        message.contains('📛') ||
        message.contains('📉') ||
        message.contains('🚨') ||
        message.contains('🧨') ||
        message.contains('⚰️') ||
        message.contains('☠️') ||
        message.contains('🧭') ||
        message.contains('🧠') ||
        message.contains('❌') ||
        message.contains('☠️');

    bool isHint = message.contains('💡') || message.contains('🔧');

    bool isCaution = message.contains('⛔️') ||
        message.contains('🚩') ||
        message.contains('📉 A') ||
        message.contains('⛔️ Careful!') ||
        message.contains('🧠 AI') ||
        message.contains('🔎 Looks') ||
        message.contains('🌀 You') ||
        message.contains('🧯 Small') ||
        message.contains('🔧 Something') ||
        message.contains('🚧 Redirection') ||
        message.contains('🌘 You') ||
        message.contains('📵 AI');

    // Dynamic UI setup
    IconData icon = Icons.psychology_alt_rounded;
    Color iconColor = Colors.amber;
    Color backgroundColor = Colors.yellow.shade50;
    Color borderColor = Colors.amber;
    String tag = "AI Message";

    if (isEncouraging) {
      icon = Icons.check_circle_outline;
      iconColor = Colors.green;
      backgroundColor = Colors.green.shade50;
      borderColor = Colors.green.shade300;
      tag = "Logic Streak";
    } else if (isDanger) {
      icon = Icons.warning_amber_rounded;
      iconColor = Colors.deepOrange;
      backgroundColor = Colors.orange.shade100;
      borderColor = Colors.deepOrange;
      tag = "Critical Warning";
      _shakeController.forward();
    } else if (isHint) {
      icon = Icons.tips_and_updates_outlined;
      iconColor = Colors.orangeAccent;
      backgroundColor = Colors.orange.shade50;
      borderColor = Colors.orangeAccent;
      tag = "AI Hint";
    } else if (isCaution) {
      icon = Icons.error_outline;
      iconColor = Colors.amber;
      backgroundColor = Colors.yellow.shade100;
      borderColor = Colors.amber;
      tag = "Caution";
    }

    if (provider.showTrackWrongMovesButton && deviationCount >= 5) {
      _buttonShakeController.forward();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final offset = isDanger ? Offset(_shakeController.value * 4, 0) : Offset.zero;

              return Transform.translate(
                offset: offset,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor.withOpacity(0.9),
                    border: Border.all(color: borderColor, width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                      if (isDanger)
                        BoxShadow(
                          color: Colors.deepOrange.withOpacity(0.6),
                          blurRadius: 18,
                          spreadRadius: 2,
                          offset: const Offset(0, 0),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🏷 Tag Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                      ),

                      // 🧠 AI Message
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(icon, color: iconColor, size: 26),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              message,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // 👀 Button with Shake
                      if (provider.showTrackWrongMovesButton)
                        Align(
                          alignment: Alignment.centerRight,
                          child: AnimatedBuilder(
                            animation: _buttonShakeController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                    deviationCount >= 5
                                        ? _buttonShakeAnimation.value
                                        : 0,
                                    0),
                                child: child,
                              );
                            },
                            child: ElevatedButton.icon(
                              onPressed: () {
                                provider.showWrongMovesComparedToSolution();
                              },
                              icon: const Icon(Icons.search_rounded, size: 18),
                              label: const Text("Track Wrong Moves"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrangeAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 14),
                                textStyle: const TextStyle(fontSize: 13),
                                elevation: 4,
                                shadowColor: Colors.deepOrangeAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

