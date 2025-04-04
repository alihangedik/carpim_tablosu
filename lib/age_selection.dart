import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:carpim_tablosu/mainmenu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class AgeSelectionScreen extends StatefulWidget {
  @override
  _AgeSelectionScreenState createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  // Yaş aralığını sabit olarak tanımlayalım
  static const int minAge = 5;
  static const int maxAge = 15;
  late int selectedAge;
  bool isFirstTime = true;

  @override
  void initState() {
    super.initState();
    // Başlangıç yaşını minimum yaş olarak ayarlayalım
    selectedAge = minAge;
    checkFirstTime();
  }

  Future<void> checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    isFirstTime = prefs.getBool('isFirstTime') ?? true;
    if (!isFirstTime) {
      // Kaydedilmiş yaşı minAge ve maxAge aralığında kontrol edelim
      int savedAge = prefs.getInt('userAge') ?? minAge;
      if (savedAge < minAge) savedAge = minAge;
      if (savedAge > maxAge) savedAge = maxAge;

      setState(() {
        selectedAge = savedAge;
      });
      // Eğer ilk kez değilse direkt ana menüye yönlendir
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Mainmenu(mevcutPuan: 0, yanlisSorular: []),
        ),
      );
    }
  }

  Future<void> saveAgeAndProceed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userAge', selectedAge);
    await prefs.setBool('isFirstTime', false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => Mainmenu(mevcutPuan: 0, yanlisSorular: []),
      ),
    );
  }

  void _showAgePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'İptal',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      'Yaş Seçin',
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Tamam',
                        style: TextStyle(
                          color: Color(0xff2d2e83),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      selectedAge = index + minAge;
                    });
                  },
                  children: List<Widget>.generate(
                    maxAge - minAge + 1,
                    (index) => Center(
                      child: Text(
                        '${index + minAge} yaş',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedAge - minAge,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToMainMenu(BuildContext context, int age) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_age', age);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Mainmenu(yanlisSorular: []),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2d2e83),
      body: Stack(
        children: [
          Opacity(
            opacity: .4,
            child: Image.asset(
              "assets/backgroud_image_2.png",
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Yaşınızı Seçin',
                  style: GoogleFonts.quicksand(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: _showAgePicker,
                  child: Container(
                    width: 200,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$selectedAge yaş',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xff2d2e83),
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xff2d2e83),
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: saveAgeAndProceed,
                  child: Text(
                    'Devam Et',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff2d2e83),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
