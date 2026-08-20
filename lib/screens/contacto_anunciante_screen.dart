import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aldia/models/propiedad_destacada.dart';

/// Pantalla que se muestra al tocar una propiedad en el catálogo.
/// Aquí el interesado ve la foto/resumen del inmueble y los datos
/// de contacto de la persona encargada (quien paga la publicidad).
class ContactoAnuncianteScreen extends StatelessWidget {
  final PropiedadDestacada propiedad;

  const ContactoAnuncianteScreen({super.key, required this.propiedad});

  Future<void> _abrirUrl(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la aplicación.')),
      );
    }
  }

  void _llamar(BuildContext context) {
    _abrirUrl(context, Uri(scheme: 'tel', path: propiedad.telefonoAnunciante));
  }

  void _whatsapp(BuildContext context) {
    final numero = propiedad.whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    final mensaje = Uri.encodeComponent(
      'Hola, estoy interesado(a) en la propiedad "${propiedad.titulo}" que vi en AlDía.',
    );
    _abrirUrl(context, Uri.parse('https://wa.me/57$numero?text=$mensaje'));
  }

  void _email(BuildContext context) {
    if (propiedad.emailAnunciante == null) return;
    _abrirUrl(
      context,
      Uri(
        scheme: 'mailto',
        path: propiedad.emailAnunciante,
        query: 'subject=${Uri.encodeComponent('Interés en ${propiedad.titulo}')}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF1E4B8F);
    const rojo = Color(0xFFD32F2F);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: rojo,
        foregroundColor: Colors.white,
        title: const Text('Contactar anunciante'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Foto de la propiedad
            ClipRRect(
              child: AspectRatio(
                aspectRatio: 16 / 7,
                child: Image.network(
                  propiedad.imagenUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.home, size: 64, color: Colors.grey),
                  ),
                ),
              ),
            ),

            // Resumen de la propiedad
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    propiedad.titulo,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: azul,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          propiedad.ubicacion,
                          style: const TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    propiedad.precio,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: rojo,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 32),

            // Tarjeta de contacto del anunciante
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: azul.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: azul.withOpacity(0.1),
                          child: Text(
                            propiedad.nombreAnunciante.isNotEmpty
                                ? propiedad.nombreAnunciante[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: azul,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Encargado de la propiedad',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                propiedad.nombreAnunciante,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Botón llamar
                    _BotonContacto(
                      icono: Icons.call,
                      texto: 'Llamar · ${propiedad.telefonoAnunciante}',
                      color: azul,
                      onTap: () => _llamar(context),
                    ),
                    const SizedBox(height: 12),

                    // Botón WhatsApp
                    _BotonContacto(
                      icono: Icons.chat_bubble,
                      texto: 'Escribir por WhatsApp',
                      color: const Color(0xFF25D366),
                      onTap: () => _whatsapp(context),
                    ),

                    // Botón email (solo si existe)
                    if (propiedad.emailAnunciante != null) ...[
                      const SizedBox(height: 12),
                      _BotonContacto(
                        icono: Icons.email,
                        texto: propiedad.emailAnunciante!,
                        color: Colors.grey[700]!,
                        onTap: () => _email(context),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _BotonContacto extends StatefulWidget {
  final IconData icono;
  final String texto;
  final Color color;
  final VoidCallback onTap;

  const _BotonContacto({
    required this.icono,
    required this.texto,
    required this.color,
    required this.onTap,
  });

  @override
  State<_BotonContacto> createState() => _BotonContactoState();
}

class _BotonContactoState extends State<_BotonContacto> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _presionado = true),
      onTapUp: (_) => setState(() => _presionado = false),
      onTapCancel: () => setState(() => _presionado = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _presionado ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(widget.icono, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.texto,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}