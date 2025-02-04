import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YanlisSorularSayfasi extends StatefulWidget {
  final List<Map<String, dynamic>> yanlisSorular;

  YanlisSorularSayfasi({required this.yanlisSorular});

  @override
  State<YanlisSorularSayfasi> createState() => _YanlisSorularSayfasiState();
}

class _YanlisSorularSayfasiState extends State<YanlisSorularSayfasi> {

  Future<void> _saveYanlisSorular() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedList = widget.yanlisSorular.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('yanlisSorular', encodedList);
  }

  void _removeSoru(int index) {
    setState(() {
      widget.yanlisSorular.removeAt(index);
      _saveYanlisSorular();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff2d2e83),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Yanlış Bilinen Sorular',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: widget.yanlisSorular.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("🎉", style: TextStyle(fontSize: 100)),
            SizedBox(height: 20),
            Text(
              'Tebrikler! \nTüm soruları doğru bildin!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info, color: Colors.grey),
                    SizedBox(width: 8),
                    Text("Silmek için sağa kaydırın", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              ),
              Container(
                      height: 690,
                child: ListView.builder(
                        itemCount: widget.yanlisSorular.length,
                        itemBuilder: (context, index) {
                final soru = widget.yanlisSorular[index];
                return Dismissible(
                  direction: DismissDirection.startToEnd,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.green ,
                    child: Row(
                      children: [

                        Icon(Icons.check, color: Colors.white, size: 30),
                        Text('Bu soruyu anladım', style: TextStyle(color: Colors.white, fontSize: 20)),
                      ],
                    ),
                  ),
                  onDismissed: (direction) {
                    _removeSoru(index);
                  },
                  key: Key(soru['soru']),
                  child: Card(
                    color: Color(0xff2d2e83),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🧐 Soru: ${soru['soru']}',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.check, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Doğru Cevap: ${soru['dogruCevap']}',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.close, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Senin Cevabın: ${soru['yanlisCevap']}',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                        },
                      ),
              ),
            ],
          ),
    );
  }
}