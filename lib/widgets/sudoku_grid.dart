import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sudoku_provider.dart';

class SudokuGrid extends StatelessWidget {
  final List<List<int>> board;
  final List<List<bool>> fixedCells;
  final Function(int, int) onCellTap;
  final (int, int)? selectedCell;

  const SudokuGrid({
    Key? key,
    required this.board,
    required this.fixedCells,
    required this.onCellTap,
    this.selectedCell,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SudokuProvider>(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF121212), Color(0xFF1F1F1F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 81,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            final row = index ~/ 9;
            final col = index % 9;
            final isSelected = selectedCell?.$1 == row && selectedCell?.$2 == col;
            final isFixed = fixedCells[row][col];
            final hasMistake = provider.mistakeExplanation != null && isSelected;
            final isBlinking = provider.blinkingWrongMoves.contains((row, col));

            // Grid lines
            final bool isThickBottom = (row + 1) % 3 == 0 && row != 8;
            final bool isThickRight = (col + 1) % 3 == 0 && col != 8;

            // Cell background color
            Color tileColor = const Color(0xFF1E1E1E);
            if (isFixed) tileColor = const Color(0xFF2A265F); // Deep purple-blue
            if (isSelected) tileColor = const Color(0xFF00FFE5).withOpacity(0.25); // Light neon glow

            // Number color
            Color numberColor = isFixed ? Colors.white : Colors.cyanAccent;

            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // 🎯 Mistake Tooltip (improved)
                if (hasMistake)
                  Positioned(
                    top: row < 2 ? 50 : -40,
                    left: (-50).clamp(-col * 40.0, (9 - col) * 40.0).toDouble(),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: 1,
                      child: Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.red.shade600,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 140),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Text(
                            provider.mistakeExplanation ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // 🔳 Cell
                GestureDetector(
                  onTap: () => onCellTap(row, col),
                  child: AnimatedOpacity(
                    opacity: isBlinking ? 0.3 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                        top: 1.5,
                        bottom: isThickBottom ? 4.5 : 1.5,
                        left: 1.5,
                        right: isThickRight ? 4.5 : 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: tileColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? Colors.cyanAccent : Colors.grey.shade800,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.cyanAccent.withOpacity(0.6),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Text(
                            board[row][col] == 0 ? '' : board[row][col].toString(),
                            key: ValueKey(board[row][col]),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: numberColor,
                              shadows: [
                                if (!isFixed)
                                  const Shadow(
                                    color: Colors.black54,
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
