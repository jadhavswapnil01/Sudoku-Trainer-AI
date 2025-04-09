import 'dart:convert';
import 'package:http/http.dart' as http;

class SudokuAPI {
  static Future<Map<String, List<List<int>>>> fetchSudoku(String difficulty) async {
    final url = Uri.parse('https://sudoku-api.vercel.app/api/dosuku');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final board = data['newboard']['grids'][0]['value'];
      final solution = data['newboard']['grids'][0]['solution'];

      return {
        'puzzle': List<List<int>>.from(board.map((row) => List<int>.from(row))),
        'solution': List<List<int>>.from(solution.map((row) => List<int>.from(row))),
      };
    } else {
      print("Failed to load Sudoku. Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
      throw Exception('Failed to load Sudoku');
    }
  }
}

