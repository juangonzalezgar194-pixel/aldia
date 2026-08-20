import 'package:flutter/material.dart';
import 'package:aldia/theme/app_theme.dart';
import 'package:aldia/services/api_service.dart';

class ActivarCuentaScreen extends StatefulWidget {
  const ActivarCuentaScreen({super.key});

  @override
  State<ActivarCuentaScreen> createState() => _ActivarCuentaScreenState();
}

class _ActivarCuentaScreenState extends State<ActivarCuentaScreen> {
  final _formKeyDatos = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();

  final _correoController = TextEditingController();
  final _codigoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();

  int _paso = 1; // 1: correo + código, 2: nueva contraseña
  bool _cargando = false;
  bool _verPassword = false;

  @override
  void dispose() {
    _correoController.dispose();
    _codigoController.dispose();
    _passwordController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  void _mostrarMensaje(String mensaje, {bool esError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red : AppColors.esmeralda,
      ),
    );
  }

  void _continuarConDatos() {
    if (!_formKeyDatos.currentState!.validate()) return;
    if (_codigoController.text.trim().length != 6) {
      _mostrarMensaje('El código debe tener 6 dígitos');
      return;
    }
    setState(() => _paso = 2);
  }

  Future<void> _reenviarCodigo() async {
    if (_correoController.text.trim().isEmpty ||
        !_correoController.text.contains('@')) {
      _mostrarMensaje('Ingresa tu correo primero para reenviar el código');
      return;
    }

    setState(() => _cargando = true);

    final resultado = await ApiService.olvidePassword(
      _correoController.text.trim(),
    );

    setState(() => _cargando = false);

    if (resultado['exito'] == true) {
      _mostrarMensaje('Código reenviado a tu correo', esError: false);
    } else {
      _mostrarMensaje(resultado['mensaje']);
    }
  }

  Future<void> _activarCuenta() async {
    if (!_formKeyPassword.currentState!.validate()) return;

    if (_passwordController.text != _confirmarPasswordController.text) {
      _mostrarMensaje('Las contraseñas no coinciden');
      return;
    }

    setState(() => _cargando = true);

    // Reusa el mismo endpoint de reseteo de contraseña: activar cuenta y
    // recuperar contraseña son, en el backend, exactamente la misma operación.
    final resultado = await ApiService.resetPassword(
      _correoController.text.trim(),
      _codigoController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _cargando = false);

    if (resultado['exito'] == true) {
      _mostrarMensaje('Cuenta activada. Ya puedes iniciar sesión', esError: false);
      if (mounted) Navigator.pop(context);
    } else {
      _mostrarMensaje(resultado['mensaje']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisClaro,
      appBar: AppBar(
        backgroundColor: AppColors.grisClaro,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.azulPrincipal),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tituloPaso(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.azulPrincipal,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _subtituloPaso(),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.grisMedio,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 32),
              if (_paso == 1) _buildPasoDatos(),
              if (_paso == 2) _buildPasoPassword(),
            ],
          ),
        ),
      ),
    );
  }

  String _tituloPaso() {
    return _paso == 1 ? 'Activa tu cuenta' : 'Crea tu contraseña';
  }

  String _subtituloPaso() {
    return _paso == 1
        ? 'Tu arrendador ya registró un contrato a tu nombre. Ingresa el correo y el código que recibiste'
                : 'Último paso: define la contraseña con la que vas a ingresar';
  }

  Widget _buildPasoDatos() {
    return Form(
      key: _formKeyDatos,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _correoController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'ejemplo@correo.com',
              prefixIcon: Icon(Icons.mail_outline_rounded,
                  color: AppColors.grisMedio, size: 20),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa tu correo';
              if (!v.contains('@')) return 'Correo inválido';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _codigoController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              hintText: '123456',
              prefixIcon: Icon(Icons.lock_clock_outlined,
                  color: AppColors.grisMedio, size: 20),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _cargando ? null : _continuarConDatos,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.esmeralda,
            ),
            child: const Text('Continuar'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _cargando ? null : _reenviarCodigo,
            child: const Text('Reenviar código'),
          ),
        ],
      ),
    );
  }

  Widget _buildPasoPassword() {
    return Form(
      key: _formKeyPassword,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _passwordController,
            obscureText: !_verPassword,
            decoration: InputDecoration(
              hintText: 'Nueva contraseña',
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
                onPressed: () => setState(() => _verPassword = !_verPassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa una contraseña';
              if (v.length < 6) return 'Mínimo 6 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmarPasswordController,
            obscureText: !_verPassword,
            decoration: const InputDecoration(
              hintText: 'Confirmar contraseña',
              prefixIcon: Icon(Icons.lock_outline_rounded,
                  color: AppColors.grisMedio, size: 20),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _cargando ? null : _activarCuenta,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.esmeralda,
            ),
            child: _cargando
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text('Activar cuenta'),
          ),
        ],
      ),
    );
  }
}