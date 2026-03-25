class Constancia {
  final int id;
  final String text;
  final String logoPath;
  final String? ruta;
  final String pdfUrl;

  Constancia({
    required this.id,
    required this.text,
    required this.logoPath,
    this.ruta,
    required this.pdfUrl,
  });

  factory Constancia.fromJson(Map<dynamic, dynamic> json) {
    return Constancia(
      id: json['id_constancia'],
      text: json['text'],
      logoPath: json['logo_path'],
      ruta: json['ruta'],
      pdfUrl: json['pdf_url'],
    );
  }
}