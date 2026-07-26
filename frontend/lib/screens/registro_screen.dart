import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aldia/theme/app_theme.dart';
import 'package:aldia/widgets/aldia_logo.dart';
import 'package:aldia/services/usuario_service.dart';
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _nombreUsuarioController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _documentoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();

  bool _verPassword = false;
  bool _verConfirmar = false;
  bool _cargando = false;
  String _rolSeleccionado = 'ARRENDATARIO';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _nombreUsuarioController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _documentoController.dispose();
    _passwordController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);

    final resultado = await UsuarioService.registrar(
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      nombreUsuario: _nombreUsuarioController.text.trim(),
      correo: _correoController.text.trim(),
      contrasena: _passwordController.text,
      numDocumento: _documentoController.text.trim(),
      telefono: _telefonoController.text.trim(),
    );

    setState(() => _cargando = false);

    if (!mounted) return;

    if (resultado['exito'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Cuenta creada exitosamente!'),
          backgroundColor: AppColors.esmeralda,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar: ${resultado['mensaje']}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisClaro,
      appBar: AppBar(
        backgroundColor: AppColors.blanco,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.azulPrincipal, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Crear cuenta',
          style: TextStyle(
            color: AppColors.azulPrincipal,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: AlDiaLogo(size: 52, showText: false),
                  ),
                  const SizedBox(height: 20),

                  _sectionTitle('¿Cuál es tu rol?'),
                  const SizedBox(height: 12),
                  _rolSelector(),

                  const SizedBox(height: 28),
                  _sectionTitle('Datos personales'),
                  const SizedBox(height: 16),

                  _labelCampo('Nombre completo'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nombreController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Ej: Carlos Andrés Pérez',
                      prefixIcon: Icon(Icons.person_outline_rounded,
                          color: AppColors.grisMedio, size: 20),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Ingresa tu nombre';
                      if (v.trim().split(' ').length < 2)
                        return 'Ingresa nombre y apellido';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _labelCampo('Apellido'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _apellidoController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Ej: Pérez Gómez',
                      prefixIcon: Icon(Icons.person_outline_rounded,
                          color: AppColors.grisMedio, size: 20),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Ingresa tu apellido';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _labelCampo('Nombre de usuario'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nombreUsuarioController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Ej: juanperez23',
                      prefixIcon: Icon(Icons.alternate_email_rounded,
                          color: AppColors.grisMedio, size: 20),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Ingresa un nombre de usuario';
                      if (v.trim().length < 4) return 'Mínimo 4 caracteres';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _labelCampo('Número de documento'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _documentoController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      hintText: 'Cédula de ciudadanía',
                      prefixIcon: Icon(Icons.badge_outlined,
                          color: AppColors.grisMedio, size: 20),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa tu documento';
                      if (v.length < 6) return 'Documento inválido';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _labelCampo('Teléfono celular'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      hintText: '300 000 0000',
                      prefixIcon: Icon(Icons.phone_outlined,
                          color: AppColors.grisMedio, size: 20),
                      prefixText: '+57 ',
                      prefixStyle: TextStyle(
                        color: AppColors.grisTexto,
                        fontFamily: 'Nunito',
                        fontSize: 14,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa tu teléfono';
                      if (v.length < 10) return 'Teléfono inválido';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _labelCampo('Correo electrónico'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'ejemplo@correo.com',
                      prefixIcon: Icon(Icons.mail_outline_rounded,
                          color: AppColors.grisMedio, size: 20),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa tu correo';
                      if (!v.contains('@') || !v.contains('.'))
                        return 'Correo inválido';
                      return null;
                    },
                  ),

                  const SizedBox(height: 28),
                  _sectionTitle('Seguridad'),
                  const SizedBox(height: 16),

                  _labelCampo('Contraseña'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_verPassword,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'Mínimo 8 caracteres',
                      prefixIcon: const Icon(Icons.lock_outline_rounded,
                          color: AppColors.grisMedio, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _verPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.grisMedio,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _verPassword = !_verPassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                      if (v.length < 8) return 'Mínimo 8 caracteres';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _labelCampo('Confirmar contraseña'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmarPasswordController,
                    obscureText: !_verConfirmar,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _registrar(),
                    decoration: InputDecoration(
                      hintText: 'Repite tu contraseña',
                      prefixIcon: const Icon(Icons.lock_outline_rounded,
                          color: AppColors.grisMedio, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _verConfirmar
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.grisMedio,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _verConfirmar = !_verConfirmar),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                      if (v != _passwordController.text)
                        return 'Las contraseñas no coinciden';
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.naranjaClaro,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.naranja.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppColors.naranja, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tus datos serán tratados conforme a la Ley 1581 de 2012 (Habeas Data Colombia).',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.naranja.withOpacity(0.85),
                              fontFamily: 'Nunito',
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  ElevatedButton(
                    onPressed: _cargando ? null : _registrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.azulPrincipal,
                      disabledBackgroundColor:
                          AppColors.azulPrincipal.withOpacity(0.5),
                    ),
                    child: _cargando
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Crear mi cuenta'),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.grisMedio),
                      child: const Text(
                        '¿Ya tienes cuenta? Inicia sesión',
                        style: TextStyle(fontSize: 13, fontFamily: 'Nunito'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _rolSelector() {
    final roles = [
      {
        'value': 'ARRENDATARIO',
        'label': 'Arrendatario',
        'desc': 'Pago arriendo mensual',
        'icon': Icons.home_outlined,
      },
      {
        'value': 'ARRENDADOR',
        'label': 'Arrendador',
        'desc': 'Gestiono inmuebles',
        'icon': Icons.apartment_outlined,
      },
    ];

    return Row(
      children: roles.map((rol) {
        final selected = _rolSeleccionado == rol['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _rolSeleccionado = rol['value'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                  right: rol['value'] == 'ARRENDATARIO' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: selected ? AppColors.azulPrincipal : AppColors.blanco,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? AppColors.azulPrincipal
                      : AppColors.azulClaro,
                  width: 1.5,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.azulPrincipal.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  Icon(
                    rol['icon'] as IconData,
                    color: selected ? AppColors.blanco : AppColors.grisMedio,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rol['label'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.blanco : AppColors.azulPrincipal,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    rol['desc'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: selected
                          ? AppColors.blanco.withOpacity(0.75)
                          : AppColors.grisMedio,
                      fontFamily: 'Nunito',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.naranja,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.azulPrincipal,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }

  Widget _labelCampo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.azulPrincipal,
        fontFamily: 'Nunito',
      ),
    );
  }
}