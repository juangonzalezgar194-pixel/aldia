import 'package:flutter/material.dart';
import 'package:aldia/theme/app_theme.dart';
import 'package:aldia/widgets/aldia_logo.dart';
import 'package:aldia/screens/registro_screen.dart';
import 'package:aldia/screens/dashboard_screen.dart';
import 'package:aldia/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _verPassword = false;
  bool _cargando = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);

    final usuario = await ApiService.login(
      _correoController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _cargando = false);

    if (usuario != null) {
      if (mounted) {
        final esArrendador = true;
        final rol = esArrendador ? RolUsuario.arrendador : RolUsuario.arrendatario;
        final nombre = usuario['nombre'] ?? _correoController.text.split('@').first;
        final int usuarioId = usuario['id'] ?? 0;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(
              rol: rol,
              nombreUsuario: nombre,
              usuarioId: usuarioId,
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo o contraseña incorrectos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisClaro,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: _buildForm(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D1A3A5C),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          children: [
            const AlDiaLogo(size: 80, showText: true),
            const SizedBox(height: 28),
            const Text(
              'Iniciar sesión',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.azulPrincipal,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ingresa tus datos para continuar',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.grisMedio,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          _labelCampo('Correo electrónico'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _correoController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'ejemplo@correo.com',
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                color: AppColors.grisMedio,
                size: 20,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa tu correo';
              if (!v.contains('@')) return 'Correo inválido';
              return null;
            },
          ),
          const SizedBox(height: 20),
          _labelCampo('Contraseña'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: !_verPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _iniciarSesion(),
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.grisMedio,
                size: 20,
              ),
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
              if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
              if (v.length < 6) return 'Mínimo 6 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColors.azulMedio,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _cargando ? null : _iniciarSesion,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.esmeralda,
              disabledBackgroundColor: AppColors.esmeralda.withOpacity(0.6),
            ),
            child: _cargando
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text('Ingresar'),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.azulClaro)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '¿No tienes cuenta?',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grisMedio,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.azulClaro)),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegistroScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              side: const BorderSide(color: AppColors.azulMedio, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              foregroundColor: AppColors.azulPrincipal,
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Nunito',
              ),
            ),
            child: const Text('Crear cuenta nueva'),
          ),
        ],
      ),
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