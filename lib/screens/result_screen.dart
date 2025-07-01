import 'package:flutter/material.dart';
import 'sudoku_board_screen.dart';

class ResultScreen extends StatelessWidget {
  final bool isSuccess;

  const ResultScreen({Key? key, required this.isSuccess}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Game Over")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.cancel,
              size: 100,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              isSuccess ? "Congratulations! You solved it!" : "Game Over! Try Again!",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SudokuBoardScreen(difficulty: "medium")),
                );
              },
              child: const Text("Play Again"),
            ),
          ],
        ),
      ),
    );
  }
}
