import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordRepeatController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _rutController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _passwordRepeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/fondoazul.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/logo.png', height: 100),
                    const SizedBox(height: 16),
                    const Text(
                      'Registrar Usuario',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Nombre
                    TextField(
                      controller: _nombreController,
                      decoration: _inputDecoration('Nombre completo', Icons.person),
                    ),
                    const SizedBox(height: 16),

                    // RUT
                    TextField(
                      controller: _rutController,
                      decoration: _inputDecoration('RUT', Icons.branding_watermark_rounded),
                    ),
                    const SizedBox(height: 16),

                    // Correo
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration('Correo electrónico', Icons.email),
                    ),
                    const SizedBox(height: 16),

                    // Teléfono
                    TextField(
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration('Número de teléfono', Icons.phone),
                    ),
                    const SizedBox(height: 16),

                    // Contraseña
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _inputDecoration('Contraseña', Icons.lock),
                    ),
                    const SizedBox(height: 16),

                    // Repetir contraseña
                    TextField(
                      controller: _passwordRepeatController,
                      obscureText: true,
                      decoration: _inputDecoration('Repite la contraseña', Icons.lock_outline),
                    ),
                    const SizedBox(height: 24),

                    // Botón registrar
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          _registrarUsuario(
                            _nombreController.text.trim(),
                            _rutController.text.trim(),
                            _emailController.text.trim(),
                            _telefonoController.text.trim(),
                            _passwordController.text.trim(),
                            _passwordRepeatController.text.trim(),
                          );
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text("Registrar"),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue[400],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                      TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register_empleado');
                      },
                      child: const Text(
                        "¿Eres un trabajador? Registrate aquí",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _registrarUsuario(
    String nombre,
    String rut,
    String email,
    String telefono,
    String password,
    String repetirPassword,
  ) async {
    if (nombre.isEmpty || rut.isEmpty || email.isEmpty || telefono.isEmpty || password.isEmpty || repetirPassword.isEmpty) {
      _mostrarError("Por favor, completa todos los campos");
      return;
    }

    if (!email.contains('@')) {
      _mostrarError("Correo electrónico no válido");
      return;
    }

    if (password.length < 6) {
      _mostrarError("La contraseña debe tener al menos 6 caracteres");
      return;
    }

    if (password != repetirPassword) {
      _mostrarError("Las contraseñas no coinciden");
      return;
    }

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = credential.user;

      if (user != null) {
        await user.updateDisplayName(nombre);
        await user.reload();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registro exitoso"),
            backgroundColor: Color.fromARGB(255, 0, 255, 85),
          ),
        );

        Navigator.pushReplacementNamed(context, '/');
      }
    } on FirebaseAuthException catch (e) {
      _mostrarError(e.message ?? "Error desconocido");
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }
}
