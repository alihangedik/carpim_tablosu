import 'package:flutter/material.dart';

import 'mainmenu.dart';

class CarpimTablosuSayfasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,  leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded,color: Colors.white,),
        onPressed: () {
          Navigator.pop(context);

        },
      ),


        title: Text('Çarpım Tablosu', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff2d2e83),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
         color: Color(0xff2d2e83)
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // Çarpım tablosu içeriği
              for (int i = 1; i <= 10; i++) _buildCarpimSatiri(i),
            ],
          ),
        ),
      ),
    );
  }

  // Çarpım satırı oluşturma fonksiyonu
  Widget _buildCarpimSatiri(int sayi) {
    List<Widget> carpimlar = [];
    for (int i = 1; i <= 10; i++) {
      carpimlar.add(
        Container(

          padding: EdgeInsets.all(8),
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),

          ),
          child: Container(
            width: 150,
            child: Text(
              '$sayi x $i = ${sayi * i}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$sayi\ Çarpım Tablosu',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: carpimlar,
          ),
        ],
      ),
    );
  }
}