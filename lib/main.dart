import 'package:carpim_tablosu/mainmenu.dart';
import 'package:carpim_tablosu/provider.dart';
import 'package:carpim_tablosu/yanlis_cevaplar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => YanlisSorularProvider()..loadYanlisSorularFromPrefs()),
        // diğer provider'lar burada
      ],

      child: KidsApp(),
    ),

  );
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown]);
}
// void main() {
//   runApp(KidsApp());
//   MultiProvider(providers: [
//     ChangeNotifierProvider(create: (_) => YanlisSorularProvider()),
//     // diğer provider'lar burada
//   ], child: KidsApp());
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown]);
// }

class KidsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Çarpım Tablosu Quiz',
      home: Scaffold(
        body: Mainmenu(
          mevcutPuan: 0,
          yanlisSorular: [],
        ),
      ),
    );
  }
}
