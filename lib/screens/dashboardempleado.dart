import 'package:flutter/material.dart';

class DashboardEmpleadoPage extends StatefulWidget {
  const DashboardEmpleadoPage({Key? key}) : super(key: key);

  @override
  State<DashboardEmpleadoPage> createState() => _DashboardEmpleadoPageState();
}

class _DashboardEmpleadoPageState extends State<DashboardEmpleadoPage> {
  int _selectedTab = 0;

  final List<String> _tabs = [
    "Trabajos activos",
    "Trabajos disponibles",
    "Historial"
  ];

  final List<String> _activeJobs = [];      
  final List<String> _availableJobs = [];  
  final List<String> _historyJobs = [];    

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Empleado"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                "https://example.com/user_photo.jpg",
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Botones de pestañas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_tabs.length, (index) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedTab == index
                      ? Colors.blue[800]
                      : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _selectedTab = index;
                  });
                },
                child: Text(_tabs[index]),
              );
            }),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildJobList(
          items: _activeJobs,
          emptyMessage: "No tienes trabajos activos.",
        );
      case 1:
        return _buildJobList(
          items: _availableJobs,
          emptyMessage: "No hay trabajos disponibles.",
        );
      case 2:
        return _buildJobList(
          items: _historyJobs,
          emptyMessage: "Aún no tienes historial de trabajos.",
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildJobList({
    required List<String> items,
    required String emptyMessage,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final job = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(job),
            subtitle: const Text("Detalles del trabajo"),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/job_detail',
                arguments: job,
              );
            },
          ),
        );
      },
    );
  }
}
