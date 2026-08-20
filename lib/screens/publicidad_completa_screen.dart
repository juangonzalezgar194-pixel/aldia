import 'package:flutter/material.dart';
import 'package:aldia/theme/app_theme.dart';
import 'package:aldia/models/propiedad_destacada.dart';
import 'package:aldia/screens/contacto_anunciante_screen.dart';

// Colores fijos del catálogo, replicando la referencia (banda roja + azul)
class _CatalogoColors {
  static const rojo = Color(0xFFB71C2C);
  static const azulBanda = Color(0xFF1F5FA8);
  static const bordeGris = Color(0xFFBFC7CE);
}

class PublicidadCompletaScreen extends StatelessWidget {
  const PublicidadCompletaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final secciones = PropiedadesDestacadasData.agrupadasPorTipo;

    return Scaffold(
      backgroundColor: AppColors.blanco,
      body: SafeArea(
        child: Column(
          children: [
            _EncabezadoCatalogo(onVolver: () => Navigator.of(context).pop()),
            Expanded(
              child: secciones.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay propiedades destacadas por el momento.',
                        style: TextStyle(color: AppColors.grisMedio, fontFamily: 'Nunito'),
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.zero,
                      children: secciones.entries.map((entry) {
                        return _SeccionCatalogo(tipo: entry.key, propiedades: entry.value);
                      }).toList(),
                    ),
            ),
            _PieCatalogo(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ENCABEZADO ROJO ESTILO RE/MAX
// ─────────────────────────────────────────────
class _EncabezadoCatalogo extends StatelessWidget {
  final VoidCallback onVolver;
  const _EncabezadoCatalogo({required this.onVolver});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _CatalogoColors.rojo,
      padding: const EdgeInsets.fromLTRB(10, 16, 20, 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
            onPressed: onVolver,
          ),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.home_rounded, color: _CatalogoColors.rojo, size: 30),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AlDía',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    fontFamily: 'Nunito',
                  ),
                ),
                Text(
                  'Catálogo Inmobiliario',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'Nunito',
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

// ─────────────────────────────────────────────
// PIE ESTILO RE/MAX ("NADIE VENDE MÁS...")
// ─────────────────────────────────────────────
class _PieCatalogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _CatalogoColors.rojo,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: const Text(
        'ALDÍA · SIEMPRE PUNTUAL, SIEMPRE TRANQUILO',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 14,
          fontFamily: 'Nunito',
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECCIÓN: banda azul de categoría + tabla de propiedades
// ─────────────────────────────────────────────
class _SeccionCatalogo extends StatelessWidget {
  final String tipo;
  final List<PropiedadDestacada> propiedades;

  const _SeccionCatalogo({required this.tipo, required this.propiedades});

  String get _tituloBanda =>
      tipo == 'Casa' ? 'ARRIENDO DE CASAS' : 'ARRIENDO DE ${tipo.toUpperCase()}S';

  @override
  Widget build(BuildContext context) {
    // Agrupamos las propiedades de a 2 para armar filas tipo tabla, igual
    // que la referencia (2 columnas por fila).
    final filas = <List<PropiedadDestacada>>[];
    for (var i = 0; i < propiedades.length; i += 2) {
      filas.add(propiedades.sublist(i, i + 2 > propiedades.length ? propiedades.length : i + 2));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banda azul de categoría
        Container(
          width: double.infinity,
          color: _CatalogoColors.azulBanda,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            _tituloBanda,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17,
              fontFamily: 'Nunito',
              letterSpacing: 0.6,
            ),
          ),
        ),
        // Tabla con borde exterior, como el catálogo de referencia
        Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: _CatalogoColors.bordeGris),
              right: BorderSide(color: _CatalogoColors.bordeGris),
            ),
          ),
          child: Column(
            children: filas.map((fila) => _FilaCatalogo(propiedades: fila)).toList(),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// FILA DE LA TABLA (hasta 2 propiedades lado a lado)
// ─────────────────────────────────────────────
class _FilaCatalogo extends StatelessWidget {
  final List<PropiedadDestacada> propiedades;
  const _FilaCatalogo({required this.propiedades});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < propiedades.length; i++) ...[
          Expanded(child: _CeldaCatalogo(propiedad: propiedades[i])),
        ],
        // Si la última fila tiene una sola propiedad, dejamos la celda vacía
        // para conservar la estructura de tabla de 2 columnas.
        if (propiedades.length == 1) const Expanded(child: SizedBox()),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// CELDA: foto + datos a la derecha + barra azul con el nombre debajo
// (replica el patrón "foto | texto" + "Venta Casa X" de la referencia)
//
// Ahora es interactiva: al tocarla, navega a la pantalla de contacto
// del anunciante, con un pequeño efecto de escala/sombra al presionar.
// ─────────────────────────────────────────────
class _CeldaCatalogo extends StatefulWidget {
  final PropiedadDestacada propiedad;
  const _CeldaCatalogo({required this.propiedad});

  @override
  State<_CeldaCatalogo> createState() => _CeldaCatalogoState();
}

class _CeldaCatalogoState extends State<_CeldaCatalogo> {
  bool _presionado = false;

  void _abrirContacto() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContactoAnuncianteScreen(propiedad: widget.propiedad),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final propiedad = widget.propiedad;

    return GestureDetector(
      onTapDown: (_) => setState(() => _presionado = true),
      onTapUp: (_) => setState(() => _presionado = false),
      onTapCancel: () => setState(() => _presionado = false),
      onTap: _abrirContacto,
      child: AnimatedScale(
        scale: _presionado ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            border: const Border(
              bottom: BorderSide(color: _CatalogoColors.bordeGris),
              right: BorderSide(color: _CatalogoColors.bordeGris),
            ),
            boxShadow: _presionado
                ? [
                    BoxShadow(
                      color: _CatalogoColors.azulBanda.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto cuadrada a la izquierda, como en la referencia
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 130,
                      height: 130,
                      child: Image.network(
                        propiedad.imagenUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(color: AppColors.grisClaro);
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.grisClaro,
                          child: const Icon(Icons.image_not_supported,
                              color: AppColors.grisMedio, size: 32),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Datos a la derecha, en formato de lista compacta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          propiedad.descripcion,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF333333),
                            fontFamily: 'Nunito',
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          propiedad.ubicacion,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.grisMedio,
                            fontFamily: 'Nunito',
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          propiedad.precio,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: _CatalogoColors.rojo,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Barra azul con el nombre de la propiedad (como "Venta Casa San Miguel")
              Container(
                width: double.infinity,
                color: _CatalogoColors.azulBanda,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  propiedad.titulo,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}