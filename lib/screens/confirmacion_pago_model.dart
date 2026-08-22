class ConfirmacionPago {
  final int id;
  final int contratoId;
  final DateTime periodoPago;
  final String metodo; // 'EFECTIVO' o 'COMPROBANTE'
  final int? documentoId;
  final double? valor;
  final String? nombrePagador;
  final DateTime? fechaPago;
  final String estado; // 'PENDIENTE' o 'CONFIRMADO'
  final DateTime confirmadoEn;

  ConfirmacionPago({
    required this.id,
    required this.contratoId,
    required this.periodoPago,
    required this.metodo,
    this.documentoId,
    this.valor,
    this.nombrePagador,
    this.fechaPago,
    required this.estado,
    required this.confirmadoEn,
  });

  factory ConfirmacionPago.fromJson(Map<String, dynamic> json) {
    return ConfirmacionPago(
      id: json['id'],
      contratoId: json['contratoId'],
      periodoPago: DateTime.parse(json['periodoPago']),
      metodo: json['metodo'],
      documentoId: json['documentoId'],
      valor: json['valor'] != null ? (json['valor'] as num).toDouble() : null,
      nombrePagador: json['nombrePagador'],
      fechaPago: json['fechaPago'] != null ? DateTime.parse(json['fechaPago']) : null,
      estado: json['estado'],
      confirmadoEn: DateTime.parse(json['confirmadoEn']),
    );
  }

  bool get estaPendiente => estado == 'PENDIENTE';
}