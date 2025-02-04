import 'package:carpim_tablosu/mainmenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(KidsApp());
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown]);
}

class KidsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Çarpım Tablosu Quiz',
      home: Scaffold(

        body: Mainmenu(mevcutPuan: 0, yanlisSorular: [],),
      ),
    );
  }
}
