import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardEmpleadoPage extends StatefulWidget {
  const DashboardEmpleadoPage({super.key});

  @override
  State<DashboardEmpleadoPage> createState() => _DashboardEmpleadoPageState();
}

class _DashboardEmpleadoPageState extends State<DashboardEmpleadoPage> {
  int _selectedTab = 0;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String? _profesionUsuario;
  bool _cargandoProfesion = true;

  final List<String> _tabs = ["Mis Trabajos", "Disponibles", "Historial"];

  @override
  void initState() {
    super.initState();
    _cargarProfesionUsuario();
  }

  // Cargar la profesión del usuario desde Firestore
  Future<void> _cargarProfesionUsuario() async {
    if (currentUser != null) {
      try {
        final doc =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(currentUser!.uid)
                .get();

        if (doc.exists) {
          setState(() {
            _profesionUsuario = doc.data()?['profesion'];
            _cargandoProfesion = false;
          });
        } else {
          setState(() {
            _cargandoProfesion = false;
          });
        }
      } catch (e) {
        print('Error al cargar profesión: $e');
        setState(() {
          _cargandoProfesion = false;
        });
      }
    } else {
      setState(() {
        _cargandoProfesion = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dashboard Empleado"),
            if (_profesionUsuario != null)
              Text(
                _profesionUsuario!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        backgroundColor: Colors.blue[700]?.withOpacity(0.9),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _cerrarSesion();
              } else if (value == 'profile') {
                _mostrarPerfil();
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('Mi Perfil'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Cerrar Sesión'),
                      ],
                    ),
                  ),
                ],
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    currentUser?.email?.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body:
          _cargandoProfesion
              ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/fondoazul.png', fit: BoxFit.cover),
                  const Center(child: CircularProgressIndicator()),
                ],
              )
              : Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/fondoazul.png', fit: BoxFit.cover),
                  SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Botones de pestañas con estilo redondeado
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(_tabs.length, (index) {
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          _selectedTab == index
                                              ? Colors.blue[700]
                                              : Colors.transparent,
                                      foregroundColor:
                                          _selectedTab == index
                                              ? Colors.white
                                              : Colors.blue[700],
                                      elevation: _selectedTab == index ? 4 : 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedTab = index;
                                      });
                                    },
                                    child: Text(
                                      _tabs[index],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: _buildTabContent(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildMisTrabajosTab();
      case 1:
        return _buildTrabajosDisponiblesTab();
      case 2:
        return _buildHistorialTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // Pestaña: Mis Trabajos (trabajos donde el empleado fue aceptado)
  Widget _buildMisTrabajosTab() {
    if (currentUser == null) {
      return const Center(child: Text("No estás autenticado"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('aplicaciones')
              .where('empleadoId', isEqualTo: currentUser!.uid)
              .where('estado', isEqualTo: 'aceptada')
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final aplicaciones = snapshot.data!.docs;
        if (aplicaciones.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.work_off,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No tienes trabajos asignados aún.",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Ve a la pestaña 'Disponibles' para aplicar a trabajos.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: aplicaciones.length,
            itemBuilder: (context, index) {
              final aplicacion =
                  aplicaciones[index].data() as Map<String, dynamic>;
              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('trabajos')
                        .doc(aplicacion['trabajoId'])
                        .get(),
                builder: (context, trabajoSnapshot) {
                  if (!trabajoSnapshot.hasData) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const ListTile(
                        leading: CircularProgressIndicator(),
                        title: Text("Cargando..."),
                      ),
                    );
                  }

                  if (!trabajoSnapshot.data!.exists) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.error, color: Colors.white),
                        ),
                        title: const Text("Trabajo eliminado"),
                        subtitle: const Text(
                          "Este trabajo ya no está disponible",
                        ),
                      ),
                    );
                  }

                  final trabajo =
                      trabajoSnapshot.data!.data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.work,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        trabajo['titulo'] ?? 'Sin título',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            trabajo['descripcion'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Empleador: ${trabajo['autorNombre'] ?? 'Desconocido'}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Profesión: ${trabajo['profesion'] ?? 'No especificada'}',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              trabajo['estado'] == 'activo'
                                  ? Colors.green
                                  : Colors.grey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          trabajo['estado'] == 'activo'
                              ? 'ACTIVO'
                              : 'FINALIZADO',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () => _mostrarDetallesTrabajo(trabajo, aplicacion),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // Pestaña: Trabajos Disponibles - FILTRADOS POR PROFESIÓN
  Widget _buildTrabajosDisponiblesTab() {
    if (_profesionUsuario == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning, size: 60, color: Colors.orange[400]),
            ),
            const SizedBox(height: 16),
            const Text(
              "No se pudo cargar tu profesión.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              "Verifica tu perfil o contacta soporte.",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('trabajos')
              .where('estado', isEqualTo: 'disponible')
              .where('profesion', isEqualTo: _profesionUsuario)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final trabajos = snapshot.data!.docs;
        if (trabajos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_off,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "No hay trabajos disponibles para $_profesionUsuario.",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Vuelve más tarde para ver nuevas oportunidades.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Ordenar manualmente por fecha si existe
        trabajos.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;
          final fechaA = dataA['fecha'] as Timestamp?;
          final fechaB = dataB['fecha'] as Timestamp?;

          if (fechaA == null && fechaB == null) return 0;
          if (fechaA == null) return 1;
          if (fechaB == null) return -1;

          return fechaB.compareTo(fechaA);
        });

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trabajos.length,
            itemBuilder: (context, index) {
              final trabajo = trabajos[index];
              final data = trabajo.data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.work_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    data['titulo'] ?? 'Sin título',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        data['descripcion'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          data['profesion'] ?? 'No especificada',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Empleador: ${data['autorNombre'] ?? 'Desconocido'}',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (data['fecha'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Publicado: ${_formatearFecha(data['fecha'] as Timestamp)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('aplicaciones')
                            .where('trabajoId', isEqualTo: trabajo.id)
                            .where('empleadoId', isEqualTo: currentUser?.uid)
                            .snapshots(),
                    builder: (context, appSnapshot) {
                      if (appSnapshot.hasData &&
                          appSnapshot.data!.docs.isNotEmpty) {
                        final aplicacion =
                            appSnapshot.data!.docs.first.data()
                                as Map<String, dynamic>;
                        final estado = aplicacion['estado'] as String;

                        Color color;
                        String texto;
                        switch (estado) {
                          case 'pendiente':
                            color = Colors.orange;
                            texto = 'PENDIENTE';
                            break;
                          case 'aceptada':
                            color = Colors.green;
                            texto = 'ACEPTADA';
                            break;
                          case 'rechazada':
                            color = Colors.red;
                            texto = 'RECHAZADA';
                            break;
                          default:
                            color = Colors.grey;
                            texto = 'DESCONOCIDO';
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            texto,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ElevatedButton(
                          onPressed: () => _aplicarATrabajo(trabajo.id, data),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Aplicar',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
                  onTap: () => _mostrarDetallesTrabajoDisponible(data),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Pestaña: Historial
  Widget _buildHistorialTab() {
    if (currentUser == null) {
      return const Center(child: Text("No estás autenticado"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('aplicaciones')
              .where('empleadoId', isEqualTo: currentUser!.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final aplicaciones = snapshot.data!.docs;
        if (aplicaciones.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.history, size: 60, color: Colors.grey[400]),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Aún no tienes historial de aplicaciones.",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Aplica a trabajos para ver tu historial aquí.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Ordenar manualmente por fecha si existe
        aplicaciones.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;
          final fechaA = dataA['fecha'] as Timestamp?;
          final fechaB = dataB['fecha'] as Timestamp?;

          if (fechaA == null && fechaB == null) return 0;
          if (fechaA == null) return 1;
          if (fechaB == null) return -1;

          return fechaB.compareTo(fechaA);
        });

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: aplicaciones.length,
            itemBuilder: (context, index) {
              final aplicacion =
                  aplicaciones[index].data() as Map<String, dynamic>;
              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('trabajos')
                        .doc(aplicacion['trabajoId'])
                        .get(),
                builder: (context, trabajoSnapshot) {
                  if (!trabajoSnapshot.hasData) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const ListTile(
                        leading: CircularProgressIndicator(),
                        title: Text("Cargando..."),
                      ),
                    );
                  }

                  final trabajo =
                      trabajoSnapshot.data!.data() as Map<String, dynamic>?;
                  if (trabajo == null) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        title: const Text("Trabajo eliminado"),
                        subtitle: Text(
                          "Aplicación: ${aplicacion['trabajoTitulo'] ?? 'Sin título'}",
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'ELIMINADO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  Color estadoColor;
                  IconData estadoIcon;
                  switch (aplicacion['estado']) {
                    case 'aceptada':
                      estadoColor = Colors.green;
                      estadoIcon = Icons.check_circle;
                      break;
                    case 'rechazada':
                      estadoColor = Colors.red;
                      estadoIcon = Icons.cancel;
                      break;
                    default:
                      estadoColor = Colors.orange;
                      estadoIcon = Icons.pending;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: estadoColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(estadoIcon, color: Colors.white, size: 24),
                      ),
                      title: Text(
                        trabajo['titulo'] ?? 'Sin título',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            trabajo['descripcion'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Empleador: ${trabajo['autorNombre'] ?? 'Desconocido'}',
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (aplicacion['fecha'] != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Aplicado: ${_formatearFecha(aplicacion['fecha'] as Timestamp)}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: estadoColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          aplicacion['estado']?.toString().toUpperCase() ??
                              'PENDIENTE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () => _mostrarDetallesTrabajo(trabajo, aplicacion),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // Función para aplicar a un trabajo
  Future<void> _aplicarATrabajo(
    String trabajoId,
    Map<String, dynamic> trabajoData,
  ) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No estás autenticado")));
      return;
    }

    try {
      // Verificar si ya aplicó a este trabajo
      final existeAplicacion =
          await FirebaseFirestore.instance
              .collection('aplicaciones')
              .where('trabajoId', isEqualTo: trabajoId)
              .where('empleadoId', isEqualTo: currentUser!.uid)
              .get();

      if (existeAplicacion.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Ya aplicaste a este trabajo"),
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Mostrar diálogo de confirmación
      final confirmar = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Confirmar Aplicación'),
              content: Text(
                '¿Estás seguro de que quieres aplicar al trabajo "${trabajoData['titulo']}"?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Aplicar'),
                ),
              ],
            ),
      );

      if (confirmar != true) return;

      // Crear la aplicación
      await FirebaseFirestore.instance.collection('aplicaciones').add({
        'trabajoId': trabajoId,
        'empleadoId': currentUser!.uid,
        'empleadoNombre':
            currentUser!.displayName ?? currentUser!.email ?? 'Anónimo',
        'empleadoEmail': currentUser!.email,
        'empleadorId': trabajoData['autorId'],
        'estado': 'pendiente',
        'fecha': FieldValue.serverTimestamp(),
        'trabajoTitulo': trabajoData['titulo'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("¡Aplicación enviada exitosamente!"),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al aplicar: $e"),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Mostrar detalles del trabajo
  void _mostrarDetallesTrabajo(
    Map<String, dynamic> trabajo,
    Map<String, dynamic> aplicacion,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(trabajo['titulo'] ?? 'Sin título'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Descripción: ${trabajo['descripcion'] ?? ''}'),
                  const SizedBox(height: 8),
                  Text('Profesión: ${trabajo['profesion'] ?? ''}'),
                  const SizedBox(height: 8),
                  Text('Empleador: ${trabajo['autorNombre'] ?? ''}'),
                  const SizedBox(height: 8),
                  Text(
                    'Estado del trabajo: ${trabajo['estado']?.toString().toUpperCase() ?? ''}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu aplicación: ${aplicacion['estado']?.toString().toUpperCase() ?? ''}',
                  ),
                  if (aplicacion['fecha'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Fecha de aplicación: ${_formatearFecha(aplicacion['fecha'] as Timestamp)}',
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  // Mostrar detalles del trabajo disponible
  void _mostrarDetallesTrabajoDisponible(Map<String, dynamic> trabajo) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(trabajo['titulo'] ?? 'Sin título'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Descripción: ${trabajo['descripcion'] ?? ''}'),
                  const SizedBox(height: 8),
                  Text(
                    'Profesión requerida: ${trabajo['profesion'] ?? 'No especificada'}',
                  ),
                  const SizedBox(height: 8),
                  Text('Empleador: ${trabajo['autorNombre'] ?? 'Desconocido'}'),
                  const SizedBox(height: 8),
                  Text(
                    'Estado: ${trabajo['estado']?.toString().toUpperCase() ?? ''}',
                  ),
                  if (trabajo['fecha'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Publicado: ${_formatearFecha(trabajo['fecha'] as Timestamp)}',
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _aplicarATrabajo(trabajo['id'] ?? '', trabajo);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Aplicar'),
              ),
            ],
          ),
    );
  }

  // Mostrar perfil del usuario
  void _mostrarPerfil() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Mi Perfil'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${currentUser?.email ?? 'No disponible'}'),
                const SizedBox(height: 8),
                Text('Nombre: ${currentUser?.displayName ?? 'No configurado'}'),
                const SizedBox(height: 8),
                Text('Profesión: ${_profesionUsuario ?? 'No especificada'}'),
                const SizedBox(height: 8),
                Text('Rol: Empleado'),
                const SizedBox(height: 8),
                Text('ID: ${currentUser?.uid ?? 'No disponible'}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  // Cerrar sesión
  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Cerrar Sesión'),
            content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Cerrar Sesión'),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      try {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, '/');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Formatear fecha
  String _formatearFecha(Timestamp timestamp) {
    final fecha = timestamp.toDate();
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}
