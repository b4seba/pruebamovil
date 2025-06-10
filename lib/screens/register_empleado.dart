import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterEmpleadoPage extends StatefulWidget {
  const RegisterEmpleadoPage({super.key});

  @override
  State<RegisterEmpleadoPage> createState() => _RegisterEmpleadoPageState();
}

class _RegisterEmpleadoPageState extends State<RegisterEmpleadoPage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _profesionController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordRepeatController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _rutController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _profesionController.dispose();
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
                      'Registro de Trabajador',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _textField(_nombreController, 'Nombre completo', Icons.person),
                    const SizedBox(height: 16),
                    _textField(_rutController, 'RUT', Icons.branding_watermark_rounded),
                    const SizedBox(height: 16),
                    _textField(_emailController, 'Correo electrónico', Icons.email, TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _textField(_telefonoController, 'Número de teléfono', Icons.phone, TextInputType.phone),
                    const SizedBox(height: 16),
                    _textField(_passwordController, 'Contraseña', Icons.lock),
                    const SizedBox(height: 16),
                    _textField(_passwordRepeatController, 'Repite la contraseña', Icons.lock_outline),
                    const SizedBox(height: 16),
                    _textField(_profesionController, 'Profesión', Icons.work),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          _registrarTrabajador(
                            _nombreController.text.trim(),
                            _rutController.text.trim(),
                            _emailController.text.trim(),
                            _telefonoController.text.trim(),
                            _profesionController.text.trim(),
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
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, '/register');
                      },
                      child: const Text(
                        "¿No eres trabajador? Volver al registro normal",
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

  Widget _textField(
    TextEditingController controller,
    String hint,
    IconData icon, [
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  ]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _registrarTrabajador(
    String nombre,
    String rut,
    String email,
    String telefono,
    String profesion,
    String password,
    String repetirPassword,
  ) async {
    if (nombre.isEmpty || rut.isEmpty || email.isEmpty || telefono.isEmpty || profesion.isEmpty || password.isEmpty || repetirPassword.isEmpty) {
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

        // Guardar en Firestore si usas Firestore
        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
          'nombre': nombre,
          'rut': rut,
          'email': email,
          'telefono': telefono,
          'rol': 'trabajador',
          'profesion': profesion,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

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
