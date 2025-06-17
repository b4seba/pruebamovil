import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateJobPage extends StatefulWidget {
  const CreateJobPage({super.key});

  @override
  State<CreateJobPage> createState() => _CreateJobPageState();
}

class _CreateJobPageState extends State<CreateJobPage> {
  final TextEditingController _titulo = TextEditingController();
  final TextEditingController _descripcion = TextEditingController();
  String? _profesionSeleccionada;

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
    _titulo.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> crearTrabajo() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("No estás autenticado."),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final titulo = _titulo.text.trim();
    final descripcion = _descripcion.text.trim();

    if (titulo.isEmpty ||
        descripcion.isEmpty ||
        _profesionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Completa todos los campos."),
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('trabajos').add({
        'titulo': titulo,
        'descripcion': descripcion,
        'profesion': _profesionSeleccionada,
        'estado': 'disponible',
        'autorId': user.uid,
        'autorNombre': user.displayName ?? 'Anónimo',
        'fecha': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("¡Trabajo publicado exitosamente!"),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Trabajo"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
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
                    // Icono y título
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.work,
                        size: 64,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Crear Nuevo Trabajo',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Campo título
                    _buildTextField("Título del trabajo", _titulo, Icons.title),
                    const SizedBox(height: 16),

                    // Campo descripción
                    _buildTextField(
                      "Descripción detallada",
                      _descripcion,
                      Icons.description,
                      maxLines: 3,
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
                          hintText: "Selecciona la profesión requerida",
                          prefixIcon: Icon(Icons.badge),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor selecciona una profesión';
                          }
                          return null;
                        },
                        isExpanded: true,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón publicar
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: crearTrabajo,
                        icon: const Icon(Icons.send),
                        label: const Text("Publicar Trabajo"),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Información adicional con estilo mejorado
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Consejos para una buena publicación:",
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "• Sé específico en el título\n• Describe claramente lo que necesitas\n• Selecciona la profesión correcta\n• Los empleados de esa profesión verán tu trabajo",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
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

  Widget _buildTextField(
    String hint,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
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
        controller: controller,
        maxLines: maxLines,
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
