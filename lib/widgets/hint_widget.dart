class HintSystem {
  static List<String> getHints(List<List<int>> board, List<List<int>> solution) {
    List<String> hints = [];
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (board[i][j] == 0) {
          hints.add("Try placing ${solution[i][j]} at row ${i + 1}, col ${j + 1}");
        }
      }
    }
    return hints.isNotEmpty ? hints : ["No hints available!"];
  }
}
