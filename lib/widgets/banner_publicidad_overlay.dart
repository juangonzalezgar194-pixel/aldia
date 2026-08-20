import 'dart:async';
import 'package:flutter/material.dart';
import '../models/propiedad_destacada.dart';
import '../screens/publicidad_completa_screen.dart';

class BannerPublicidadOverlay extends StatefulWidget {
  final VoidCallback onCerrar;

  const BannerPublicidadOverlay({
    super.key,
    required this.onCerrar,
  });

  @override
  State<BannerPublicidadOverlay> createState() =>
      _BannerPublicidadOverlayState();
}

class _BannerPublicidadOverlayState extends State<BannerPublicidadOverlay> {
  Timer? _timer;

  // Mostramos siempre la primera propiedad destacada de la lista.
  final PropiedadDestacada propiedad =
      PropiedadesDestacadasData.lista.first;

  @override
  void initState() {
    super.initState();
    // Se cierra automáticamente después de 30 segundos.
    _timer = Timer(const Duration(seconds: 30), () {
      if (mounted) widget.onCerrar();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _irAPublicidadCompleta() {
    _timer?.cancel();
    widget.onCerrar(); // Cierra el overlay primero
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PublicidadCompletaScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cubre toda la pantalla (Positioned.fill dentro del Stack del dashboard).
    return Positioned.fill(
      child: Material(
        color: const Color(0xFF0B1B2B),
        child: GestureDetector(
          onTap: _irAPublicidadCompleta,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen de fondo a pantalla completa
              Image.network(
                propiedad.imagenUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(color: const Color(0xFF1A3A5C));
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1A3A5C),
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.white54, size: 60),
                ),
              ),
              // Degradado oscuro para legibilidad del texto
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
              // Etiqueta "Publicidad"
              Positioned(
                top: 50,
                left: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Publicidad',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Botón X para cerrar
              Positioned(
                top: 44,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    _timer?.cancel();
                    widget.onCerrar();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
              // Info de la propiedad en la parte inferior
              Positioned(
                left: 24,
                right: 24,
                bottom: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      propiedad.titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      propiedad.descripcion,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            color: Colors.white.withOpacity(0.9), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          propiedad.ubicacion,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        propiedad.precio,
                        style: const TextStyle(
                          color: Color(0xFF0B1B2B),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Icon(Icons.touch_app_rounded,
                            color: Colors.white.withOpacity(0.7), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Toca para ver más propiedades destacadas',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}