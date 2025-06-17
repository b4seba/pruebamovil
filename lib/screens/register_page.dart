import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nombreCtrl = TextEditingController();
  final _rutCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _repeatPwCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _rutCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _passwordCtrl.dispose();
    _repeatPwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/fondoazul.png', fit: BoxFit.cover),
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
                      'Registro Empleador',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildTextField(
                      _nombreCtrl,
                      'Nombre completo',
                      Icons.person,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _rutCtrl,
                      'RUT',
                      Icons.branding_watermark_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _emailCtrl,
                      'Correo electrónico',
                      Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _telefonoCtrl,
                      'Número de teléfono',
                      Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _passwordCtrl,
                      'Contraseña',
                      Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _repeatPwCtrl,
                      'Repite la contraseña',
                      Icons.lock_outline,
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _registrarUsuario,
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
                        Navigator.pushNamed(context, '/register_empleado');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue[700],
                      ),
                      child: const Text("¿Eres un trabajador? Regístrate aquí"),
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

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      obscureText: obscureText,
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

  Future<void> _registrarUsuario() async {
    final nombre = _nombreCtrl.text.trim();
    final rut = _rutCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final telefono = _telefonoCtrl.text.trim();
    final pw = _passwordCtrl.text.trim();
    final pw2 = _repeatPwCtrl.text.trim();

    if (nombre.isEmpty ||
        rut.isEmpty ||
        email.isEmpty ||
        telefono.isEmpty ||
        pw.isEmpty ||
        pw2.isEmpty) {
      return _mostrarError("Por favor, completa todos los campos");
    }
    if (!email.contains('@')) {
      return _mostrarError("Correo electrónico no válido");
    }
    if (pw.length < 6) {
      return _mostrarError("La contraseña debe tener al menos 6 caracteres");
    }
    if (pw != pw2) {
      return _mostrarError("Las contraseñas no coinciden");
    }

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pw,
      );
      final u = cred.user!;

      await FirebaseFirestore.instance.collection('usuarios').doc(u.uid).set({
        'nombre': nombre,
        'rut': rut,
        'email': email,
        'telefono': telefono,
        'rol': 'empleador',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registro exitoso"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login_page');
    } on FirebaseAuthException catch (e) {
      _mostrarError(e.message ?? "Error desconocido");
    }
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }
}
