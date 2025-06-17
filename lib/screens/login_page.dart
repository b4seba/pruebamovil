import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                      "NeighborJob",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Email
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Correo electrónico",
                        prefixIcon: const Icon(Icons.email),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Contraseña",
                        prefixIcon: const Icon(Icons.lock),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón de inicio de sesión
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _fnIniciarSesion,
                        icon: const Icon(Icons.login),
                        label: const Text("Iniciar sesión"),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue[400],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Registro
                    TextButton(
                      onPressed:
                          () => Navigator.pushNamed(context, '/register'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue[700],
                      ),
                      child: const Text("¿No tienes cuenta? Regístrate"),
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

  Future<void> _fnIniciarSesion() async {
    final email = _emailCtrl.text.trim();
    final pass = _passwordCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      return _showError('Completa todos los campos');
    }

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      final uid = cred.user!.uid;

      // Leemos el documento del usuario
      final docSnap = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (!docSnap.exists) {
        return _showError('Usuario no encontrado.');
      }

      final data = docSnap.data()!;
      final role = data['rol'] as String?;

      // Redirigimos porl ol
      if (role == 'trabajador') {
        Navigator.pushReplacementNamed(context, '/dashboardempleado');
      } else if (role == 'empleador') {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        _showError('Rol de usuario desconocido.');
      }
    } on TimeoutException {
      _showError("Error de conexión con Firestore. Intenta de nuevo.");
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _showError('Usuario no encontrado');
          break;
        case 'wrong-password':
          _showError('Contraseña incorrecta');
          break;
        default:
          _showError('Error al iniciar sesión');
      }
    } catch (e) {
      _showError("Error inesperado. Revisa la consola.");
      print(e);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }
}
