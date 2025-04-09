import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/sudoku_provider.dart';
import 'screens/loading_screen.dart'; // <-- Use landing screen as initial screen
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SudokuProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<SudokuProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sudoku Trainer',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.black87, fontSize: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      // Start with LandingScreen
      // navigatorKey: navigatorKey,
      home: const LandingScreen(),
    );
  }
}
