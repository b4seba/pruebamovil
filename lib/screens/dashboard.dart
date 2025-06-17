import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardEmpleadorPage extends StatefulWidget {
  const DashboardEmpleadorPage({super.key});

  @override
  State<DashboardEmpleadorPage> createState() => _DashboardEmpleadorPageState();
}

class _DashboardEmpleadorPageState extends State<DashboardEmpleadorPage> {
  int _selectedTab = 1;
  final _tabs = ["Activos", "Disponibles", "Historial"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard Empleador")),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_tabs.length, (i) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _selectedTab == i ? Colors.blue[800] : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => setState(() => _selectedTab = i),
                child: Text(_tabs[i]),
              );
            }),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildTab(_selectedTab)),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, "/createjob_page"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.blue[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text("Crear trabajo", style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildTab(int index) {
    late Query query;
    switch (index) {
      case 0:
        // Trabajos activos
        query = FirebaseFirestore.instance
            .collection('trabajos')
            .where('estado', isEqualTo: 'activo');
        break;
      case 1:
        // Trabajos disponibles
        query = FirebaseFirestore.instance
            .collection('trabajos')
            .where('estado', isEqualTo: 'disponible');
        break;
      case 2:
        // Historial (finalizados)
        query = FirebaseFirestore.instance
            .collection('trabajos')
            .where('estado', isEqualTo: 'finalizado');
        break;
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Text(
              index == 0
                  ? 'No tienes trabajos activos.'
                  : index == 1
                  ? 'No hay trabajos disponibles.'
                  : 'Aún no tienes historial.',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(data['titulo'] ?? 'Sin título'),
                subtitle: Text(data['descripcion'] ?? ''),
                trailing: Text(
                  data['estado']?.toString().toUpperCase() ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {},
              ),
            );
          },
        );
      },
    );
  }
}
