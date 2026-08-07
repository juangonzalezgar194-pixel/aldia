class Comprobante {
  final int id;
  final String nombreArchivo;
  final String tipoArchivo; // 'IMAGEN' o 'PDF'
  final int? tamanioBytes;
  final DateTime fechaSubida;
  final String subidoPor;
  final String urlDescarga;

  Comprobante({
    required this.id,
    required this.nombreArchivo,
    required this.tipoArchivo,
    required this.tamanioBytes,
    required this.fechaSubida,
    required this.subidoPor,
    required this.urlDescarga,
  });

  factory Comprobante.fromJson(Map<String, dynamic> json) {
    return Comprobante(
      id: json['id'],
      nombreArchivo: json['nombreArchivo'],
      tipoArchivo: json['tipoArchivo'],
      tamanioBytes: json['tamanioBytes'],
      fechaSubida: DateTime.parse(json['fechaSubida']),
      subidoPor: json['subidoPor'],
      urlDescarga: json['urlDescarga'],
    );
  }

  bool get esPdf => tipoArchivo == 'PDF';
}