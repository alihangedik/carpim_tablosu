import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
<<<<<<< Updated upstream
<<<<<<< Updated upstream
=======
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
import 'age_selection.dart';
import 'screens/legal_consent_screen.dart';
import 'mainmenu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();
  final hasGivenConsent = prefs.getBool('legal_consent_given') ?? false;
  final selectedAge = prefs.getInt('selected_age');

  runApp(KidsApp(
    hasGivenConsent: hasGivenConsent,
    selectedAge: selectedAge,
  ));
}

class KidsApp extends StatelessWidget {
  final bool hasGivenConsent;
  final int? selectedAge;

  const KidsApp({
    Key? key,
    required this.hasGivenConsent,
    this.selectedAge,
  }) : super(key: key);
<<<<<<< Updated upstream
<<<<<<< Updated upstream
=======
=======
>>>>>>> Stashed changes
=======
import 'quiz.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const KidsApp());
}

class KidsApp extends StatelessWidget {
  const KidsApp({Key? key}) : super(key: key);
>>>>>>> Stashed changes
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Çarpım Tablosu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
<<<<<<< Updated upstream
      home: _getInitialScreen(),
=======
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      home: _getInitialScreen(),
=======
      home: const QuizScreen(),
>>>>>>> Stashed changes
>>>>>>> Stashed changes
=======
      home: const QuizScreen(),
>>>>>>> Stashed changes
>>>>>>> Stashed changes
    );
  }

  Widget _getInitialScreen() {
    if (!hasGivenConsent) {
      return LegalConsentScreen();
    }

    if (selectedAge == null) {
      return AgeSelectionScreen();
    }

    return Mainmenu(yanlisSorular: []);
  }
}
