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
  final TextEditingController _profesion = TextEditingController();

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    _profesion.dispose();
    super.dispose();
  }

  Future<void> crearTrabajo() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No estás autenticado.")),
      );
      return;
    }

    final titulo = _titulo.text.trim();
    final descripcion = _descripcion.text.trim();
    final profesion = _profesion.text.trim();

    if (titulo.isEmpty || descripcion.isEmpty || profesion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('trabajos').add({
        'titulo': titulo,
        'descripcion': descripcion,
        'profesion': profesion,
        'estado': 'disponible',
        'autorId': user.uid,
        'autorNombre': user.displayName ?? 'Anónimo',
        'fecha': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF252147),
      appBar: AppBar(title: const Text("Crear Trabajo")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Icon(Icons.work, size: 64, color: Colors.white38),
              const SizedBox(height: 24),
              campoTexto("Título", _titulo, Icons.title),
              const SizedBox(height: 16),
              campoTexto("Descripción", _descripcion, Icons.description, maxLines: 3),
              const SizedBox(height: 16),
              campoTexto("Profesión deseada", _profesion, Icons.badge),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: crearTrabajo,
                  icon: const Icon(Icons.send),
                  label: const Text("Publicar Trabajo"),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white38,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget campoTexto(String hint, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
