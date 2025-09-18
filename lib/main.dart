import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
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





  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dört İşlem',
      theme: ThemeData.dark(
      ),

      home:  _getInitialScreen(),
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
