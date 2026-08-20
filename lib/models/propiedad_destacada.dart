class PropiedadDestacada {
  final String id;
  final String tipo; // 'Apartamento' o 'Casa' — se usa para agrupar en secciones
  final String titulo;
  final String descripcion;
  final String imagenUrl;
  final String precio;
  final String ubicacion;

  // --- Datos del anunciante (quien paga por la publicidad) ---
  final String nombreAnunciante;
  final String telefonoAnunciante; // formato: '3001234567' (sin espacios ni guiones)
  final String? whatsappAnunciante; // opcional, si es distinto al teléfono
  final String? emailAnunciante; // opcional

  const PropiedadDestacada({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.imagenUrl,
    required this.precio,
    required this.ubicacion,
    required this.nombreAnunciante,
    required this.telefonoAnunciante,
    this.whatsappAnunciante,
    this.emailAnunciante,
  });

  // Si no se definió un WhatsApp específico, usamos el mismo teléfono.
  String get whatsapp => whatsappAnunciante ?? telefonoAnunciante;
}

// Datos de prueba (provisionales) para la exposición.
// Aquí defines tú mismo las propiedades que quieres destacar.
//
// Las imágenes son fotos REALES de Unsplash, elegidas a mano para que
// coincidan con cada descripción. Son de uso libre (Unsplash License):
// gratis para uso comercial y no comercial, sin necesidad de atribución.
// Más info: https://unsplash.com/license
class PropiedadesDestacadasData {
  static const List<PropiedadDestacada> lista = [
    PropiedadDestacada(
      id: '1',
      tipo: 'Apartamento',
      titulo: 'Apartamento en Fusagasugá',
      descripcion:
          'Cómodo apartamento de 2 habitaciones y 1 baño, cerca al centro de Fusagasugá. Cuenta con sala-comedor amplia, cocina integral y balcón. Ideal para pareja o pequeña familia que busca cercanía a la zona comercial.',
      imagenUrl:
          'https://images.unsplash.com/photo-1748679767437-00b5c0327b1a?fm=jpg&q=80&w=800&auto=format&fit=crop',
      precio: '\$850.000/mes',
      ubicacion: 'Fusagasugá, Cundinamarca',
      nombreAnunciante: 'María Fernanda Rojas',
      telefonoAnunciante: '3001234567',
      emailAnunciante: 'maria.rojas@example.com',
    ),
    PropiedadDestacada(
      id: '2',
      tipo: 'Casa',
      titulo: 'Casa Campestre',
      descripcion:
          'Casa de 3 habitaciones con jardín amplio y zona verde privada, ideal para familias. Cuenta con parqueadero cubierto, cocina abierta y espacio para mascotas. Ambiente tranquilo, rodeado de naturaleza.',
      imagenUrl:
          'https://images.unsplash.com/photo-1636301587190-88cbb412fea0?fm=jpg&q=80&w=800&auto=format&fit=crop',
      precio: '\$1.200.000/mes',
      ubicacion: 'Fusagasugá, Cundinamarca',
      nombreAnunciante: 'Carlos Andrés Pérez',
      telefonoAnunciante: '3109876543',
    ),
    PropiedadDestacada(
      id: '3',
      tipo: 'Apartamento',
      titulo: 'Apartaestudio Moderno',
      descripcion:
          'Apartaestudio amoblado y remodelado, ideal para una persona o pareja joven. Incluye cama, escritorio y clóset empotrado. Servicios de internet y administración incluidos en el canon mensual.',
      imagenUrl:
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?fm=jpg&q=80&w=800&auto=format&fit=crop',
      precio: '\$650.000/mes',
      ubicacion: 'Fusagasugá, Cundinamarca',
      nombreAnunciante: 'Laura Jiménez',
      telefonoAnunciante: '3157654321',
      whatsappAnunciante: '3157654321',
      emailAnunciante: 'laura.jimenez@example.com',
    ),
    PropiedadDestacada(
      id: '4',
      tipo: 'Casa',
      titulo: 'Casa en Conjunto Cerrado',
      descripcion:
          'Casa de 3 habitaciones y 2 baños dentro de conjunto cerrado con vigilancia 24 horas. Incluye zonas comunes, parque infantil y parqueadero visitantes. Excelente opción de seguridad para familias con niños.',
      imagenUrl:
          'https://images.unsplash.com/photo-1628624747186-a941c476b7ef?fm=jpg&q=80&w=800&auto=format&fit=crop',
      precio: '\$1.450.000/mes',
      ubicacion: 'Fusagasugá, Cundinamarca',
      nombreAnunciante: 'Jorge Martínez',
      telefonoAnunciante: '3204561234',
    ),
    // Puedes agregar más propiedades aquí siguiendo el mismo formato.
    // El "tipo" (Apartamento / Casa) determina en qué sección aparece.
    // Para nuevas imágenes: busca en https://unsplash.com, entra a la
    // foto, clic derecho sobre la imagen > "Copiar dirección de imagen".
    //
    // Recuerda incluir nombreAnunciante y telefonoAnunciante: son los
    // datos que verá el interesado al tocar la tarjeta de la propiedad.
  ];

  // Agrupa las propiedades por tipo, para armar las secciones del catálogo.
  static Map<String, List<PropiedadDestacada>> get agrupadasPorTipo {
    final Map<String, List<PropiedadDestacada>> mapa = {};
    for (final propiedad in lista) {
      mapa.putIfAbsent(propiedad.tipo, () => []).add(propiedad);
    }
    return mapa;
  }
}