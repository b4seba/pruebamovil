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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _profesionSeleccionada;
  bool _isLoading = false;

  // Lista de profesiones disponibles
  final List<String> _profesiones = [
    'Gasfiter',
    'Electricista',
    'Carpintero',
    'Plomero',
    'Pintor',
    'Albañil',
    'Jardinero',
    'Mecánico',
    'Soldador',
    'Técnico en Refrigeración',
    'Cerrajero',
    'Techador',
    'Instalador de Pisos',
    'Vidriería',
    'Limpieza',
    'Mudanzas',
    'Delivery',
    'Cuidado de Mascotas',
    'Niñera',
    'Cuidado de Adultos Mayores',
    'Profesor Particular',
    'Diseñador Gráfico',
    'Programador',
    'Fotógrafo',
    'Chef/Cocinero',
    'Mesero',
    'Bartender',
    'Seguridad',
    'Chofer',
    'Otro',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registrarEmpleado() async {
    if (_nombreController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _profesionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor completa todos los campos")),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La contraseña debe tener al menos 6 caracteres"),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Crear usuario en Firebase Auth
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      // Actualizar el nombre del usuario
      await userCredential.user?.updateDisplayName(
        _nombreController.text.trim(),
      );

      // Guardar información adicional en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
            'nombre': _nombreController.text.trim(),
            'email': _emailController.text.trim(),
            'profesion': _profesionSeleccionada,
            'rol': 'trabajador',
            'fechaRegistro': FieldValue.serverTimestamp(),
            'activo': true,
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Registro exitoso! Bienvenido"),
          backgroundColor: Colors.green,
        ),
      );

      // Navegar al dashboard del empleado
      Navigator.pushReplacementNamed(context, '/dashboardempleado');
    } on FirebaseAuthException catch (e) {
      String mensaje = "Error en el registro";
      switch (e.code) {
        case 'weak-password':
          mensaje = "La contraseña es muy débil";
          break;
        case 'email-already-in-use':
          mensaje = "Este email ya está registrado";
          break;
        case 'invalid-email':
          mensaje = "Email inválido";
          break;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                      'Registro Empleado',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildTextField(
                      _nombreController,
                      'Nombre completo',
                      Icons.person,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      _emailController,
                      'Correo electrónico',
                      Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Dropdown de profesiones
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _profesionSeleccionada,
                        decoration: const InputDecoration(
                          hintText: "Selecciona tu profesión",
                          prefixIcon: Icon(Icons.work),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items:
                            _profesiones.map((String profesion) {
                              return DropdownMenuItem<String>(
                                value: profesion,
                                child: Text(profesion),
                              );
                            }).toList(),
                        onChanged: (String? nuevaProfesion) {
                          setState(() {
                            _profesionSeleccionada = nuevaProfesion;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      _passwordController,
                      'Contraseña',
                      Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      _confirmPasswordController,
                      'Repite la contraseña',
                      Icons.lock_outline,
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _registrarEmpleado,
                        icon:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Icon(Icons.person_add),
                        label: Text(
                          _isLoading ? "Registrando..." : "Registrar",
                        ),
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
                        Navigator.pushNamed(context, '/register');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue[700],
                      ),
                      child: const Text("¿Eres un empleador? Regístrate aquí"),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(50)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
