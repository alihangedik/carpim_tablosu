class PerformansVeri {
  final DateTime tarih;
  final double basariOrani;
  final int dogru;
  final int yanlis;
  final int xp;
  final String islemTuru;

  PerformansVeri({
    required this.tarih,
    required this.basariOrani,
    required this.dogru,
    required this.yanlis,
    required this.xp,
    required this.islemTuru,
  });


  factory PerformansVeri.fromJson(Map<String, dynamic> json) {
    return PerformansVeri(
      tarih: DateTime.parse(json['tarih'] ?? DateTime.now().toIso8601String()),
      basariOrani: (json['basariOrani'] ?? 0.0).toDouble(),
      dogru: json['dogru']?.toInt() ?? 0,
      yanlis: json['yanlis']?.toInt() ?? 0,
      xp: json['xp']?.toInt() ?? 0,
      islemTuru: json['islemTuru'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tarih': tarih.toIso8601String(),
      'basariOrani': basariOrani,
      'dogru': dogru,
      'yanlis': yanlis,
      'xp': xp,
      'islemTuru': islemTuru,
    };
  }

}
