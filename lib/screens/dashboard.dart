import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardEmpleadorPage extends StatefulWidget {
  const DashboardEmpleadorPage({super.key});

  @override
  State<DashboardEmpleadorPage> createState() => _DashboardEmpleadorPageState();
}

class _DashboardEmpleadorPageState extends State<DashboardEmpleadorPage> {
  int _selectedTab = 1;
  final _tabs = ["Activos", "Disponibles", "Aplicaciones", "Historial"];
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Dashboard Empleador"),
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
      body: Stack(
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_tabs.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _selectedTab == i
                                      ? Colors.blue[700]
                                      : Colors.transparent,
                              foregroundColor:
                                  _selectedTab == i
                                      ? Colors.white
                                      : Colors.blue[700],
                              elevation: _selectedTab == i ? 4 : 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () => setState(() => _selectedTab = i),
                            child: Text(
                              _tabs[i],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
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
                      child: _buildTab(_selectedTab),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Botón crear trabajo con estilo consistente
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed:
                        () => Navigator.pushNamed(context, "/createjob_page"),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text("Crear trabajo"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildTab(int index) {
    if (currentUser == null) {
      return const Center(child: Text("No estás autenticado"));
    }

    late Query query;
    switch (index) {
      case 0:
        // Trabajos activos (con empleado asignado)
        query = FirebaseFirestore.instance
            .collection('trabajos')
            .where('autorId', isEqualTo: currentUser!.uid)
            .where('estado', isEqualTo: 'activo');
        break;
      case 1:
        // Trabajos disponibles
        query = FirebaseFirestore.instance
            .collection('trabajos')
            .where('autorId', isEqualTo: currentUser!.uid)
            .where('estado', isEqualTo: 'disponible');
        break;
      case 2:
        // Aplicaciones - caso especial
        return _buildAplicacionesTab();
      case 3:
        // Historial (finalizados)
        query = FirebaseFirestore.instance
            .collection('trabajos')
            .where('autorId', isEqualTo: currentUser!.uid)
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
                    index == 0
                        ? Icons.work_off
                        : index == 1
                        ? Icons.work_outline
                        : Icons.history,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  index == 0
                      ? 'No tienes trabajos activos.'
                      : index == 1
                      ? 'No hay trabajos disponibles.'
                      : 'Aún no tienes historial.',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  index == 1
                      ? 'Crea un nuevo trabajo usando el botón de abajo.'
                      : 'Los trabajos aparecerán aquí cuando estén disponibles.',
                  style: const TextStyle(color: Colors.grey),
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
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
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
                      color: _getEstadoColor(data['estado']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getEstadoIcon(data['estado']),
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
                          'Profesión: ${data['profesion'] ?? 'No especificada'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (data['empleadoAsignado'] != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Empleado: ${data['empleadoAsignado']}',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getEstadoColor(data['estado']),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data['estado']?.toString().toUpperCase() ?? '',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (index == 1) // Solo para trabajos disponibles
                        StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('aplicaciones')
                                  .where('trabajoId', isEqualTo: docs[i].id)
                                  .where('estado', isEqualTo: 'pendiente')
                                  .snapshots(),
                          builder: (context, appSnapshot) {
                            if (appSnapshot.hasData &&
                                appSnapshot.data!.docs.isNotEmpty) {
                              return Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${appSnapshot.data!.docs.length} aplicaciones',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                    ],
                  ),
                  onTap: () => _mostrarDetallesTrabajo(docs[i].id, data),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Pestaña de aplicaciones - SIN orderBy para evitar índices compuestos
  Widget _buildAplicacionesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('aplicaciones')
              .where('empleadorId', isEqualTo: currentUser!.uid)
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
                    Icons.assignment_turned_in,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No hay aplicaciones aún.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Las aplicaciones de empleados aparecerán aquí.",
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

          return fechaB.compareTo(fechaA); // Más reciente primero
        });

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: aplicaciones.length,
            itemBuilder: (context, index) {
              final aplicacion = aplicaciones[index];
              final data = aplicacion.data() as Map<String, dynamic>;

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
                      color: _getEstadoColor(data['estado']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      data['estado'] == 'aceptada'
                          ? Icons.check
                          : data['estado'] == 'rechazada'
                          ? Icons.close
                          : Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    data['trabajoTitulo'] ?? 'Sin título',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          'Aplicante: ${data['empleadoNombre'] ?? 'Desconocido'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Email: ${data['empleadoEmail'] ?? ''}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (data['fecha'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Aplicado: ${_formatearFecha(data['fecha'] as Timestamp)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getEstadoColor(data['estado']),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data['estado']?.toString().toUpperCase() ??
                              'PENDIENTE',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing:
                      data['estado'] == 'pendiente'
                          ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  onPressed:
                                      () => _aceptarAplicacion(
                                        aplicacion.id,
                                        data,
                                      ),
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  tooltip: 'Aceptar',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  onPressed:
                                      () => _rechazarAplicacion(aplicacion.id),
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  tooltip: 'Rechazar',
                                ),
                              ),
                            ],
                          )
                          : null,
                  onTap: () => _mostrarDetallesAplicacion(data),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getEstadoColor(String? estado) {
    switch (estado) {
      case 'activo':
        return Colors.green;
      case 'disponible':
        return Colors.blue;
      case 'finalizado':
        return Colors.grey;
      case 'aceptada':
        return Colors.green;
      case 'rechazada':
        return Colors.red;
      case 'pendiente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getEstadoIcon(String? estado) {
    switch (estado) {
      case 'activo':
        return Icons.work;
      case 'disponible':
        return Icons.work_outline;
      case 'finalizado':
        return Icons.done;
      default:
        return Icons.work_outline;
    }
  }

  // Aceptar aplicación
  Future<void> _aceptarAplicacion(
    String aplicacionId,
    Map<String, dynamic> aplicacionData,
  ) async {
    // Mostrar diálogo de confirmación con estilo consistente
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Aceptar Aplicación'),
            content: Text(
              '¿Estás seguro de que quieres aceptar a ${aplicacionData['empleadoNombre']} para este trabajo?',
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
                child: const Text('Aceptar'),
              ),
            ],
          ),
    );

    if (confirmar != true) return;

    try {
      // Actualizar la aplicación a aceptada
      await FirebaseFirestore.instance
          .collection('aplicaciones')
          .doc(aplicacionId)
          .update({'estado': 'aceptada'});

      // Actualizar el trabajo a activo y asignar empleado
      await FirebaseFirestore.instance
          .collection('trabajos')
          .doc(aplicacionData['trabajoId'])
          .update({
            'estado': 'activo',
            'empleadoAsignado': aplicacionData['empleadoNombre'],
            'empleadoId': aplicacionData['empleadoId'],
          });

      // Rechazar todas las demás aplicaciones para este trabajo
      final otrasAplicaciones =
          await FirebaseFirestore.instance
              .collection('aplicaciones')
              .where('trabajoId', isEqualTo: aplicacionData['trabajoId'])
              .where('estado', isEqualTo: 'pendiente')
              .get();

      for (var doc in otrasAplicaciones.docs) {
        if (doc.id != aplicacionId) {
          await doc.reference.update({'estado': 'rechazada'});
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("¡Aplicación aceptada exitosamente!"),
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
          content: Text("Error al aceptar aplicación: $e"),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Rechazar aplicación
  Future<void> _rechazarAplicacion(String aplicacionId) async {
    // Mostrar diálogo de confirmación con estilo consistente
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Rechazar Aplicación'),
            content: const Text(
              '¿Estás seguro de que quieres rechazar esta aplicación?',
            ),
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
                child: const Text('Rechazar'),
              ),
            ],
          ),
    );

    if (confirmar != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('aplicaciones')
          .doc(aplicacionId)
          .update({'estado': 'rechazada'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Aplicación rechazada"),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al rechazar aplicación: $e"),
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
  void _mostrarDetallesTrabajo(String trabajoId, Map<String, dynamic> trabajo) {
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
                  Text(
                    'Estado: ${trabajo['estado']?.toString().toUpperCase() ?? ''}',
                  ),
                  if (trabajo['empleadoAsignado'] != null) ...[
                    const SizedBox(height: 8),
                    Text('Empleado asignado: ${trabajo['empleadoAsignado']}'),
                  ],
                  if (trabajo['fecha'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Creado: ${_formatearFecha(trabajo['fecha'] as Timestamp)}',
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              if (trabajo['estado'] == 'activo')
                TextButton(
                  onPressed: () => _finalizarTrabajo(trabajoId),
                  child: const Text('Finalizar Trabajo'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  // Mostrar detalles de la aplicación
  void _mostrarDetallesAplicacion(Map<String, dynamic> aplicacion) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Aplicación - ${aplicacion['trabajoTitulo'] ?? 'Sin título'}',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aplicante: ${aplicacion['empleadoNombre'] ?? 'Desconocido'}',
                ),
                const SizedBox(height: 8),
                Text('Email: ${aplicacion['empleadoEmail'] ?? ''}'),
                const SizedBox(height: 8),
                Text(
                  'Estado: ${aplicacion['estado']?.toString().toUpperCase() ?? ''}',
                ),
                if (aplicacion['fecha'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Fecha de aplicación: ${_formatearFecha(aplicacion['fecha'] as Timestamp)}',
                  ),
                ],
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

  // Finalizar trabajo
  Future<void> _finalizarTrabajo(String trabajoId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Finalizar Trabajo'),
            content: const Text(
              '¿Estás seguro de que quieres finalizar este trabajo?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Finalizar'),
              ),
            ],
          ),
    );

    if (confirmar != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('trabajos')
          .doc(trabajoId)
          .update({'estado': 'finalizado'});

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("¡Trabajo finalizado exitosamente!"),
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
          content: Text("Error al finalizar trabajo: $e"),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
                Text('Rol: Empleador'),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
