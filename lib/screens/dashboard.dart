import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Clase principal del Dashboard para Empleadores.
/// Es un StatefulWidget porque su estado (pestaña seleccionada)
/// puede cambiar durante la vida del widget.
class DashboardEmpleadorPage extends StatefulWidget {
  const DashboardEmpleadorPage({super.key});

  @override
  State<DashboardEmpleadorPage> createState() => _DashboardEmpleadorPageState();
}

/// Estado asociado a DashboardEmpleadorPage.
/// Contiene la lógica y los datos mutables del widget.
class _DashboardEmpleadorPageState extends State<DashboardEmpleadorPage> {
  // Índice de la pestaña actualmente seleccionada (0: Activos, 1: Disponibles, 2: Aplicaciones, 3: Historial).
  // Se inicializa en 1 para que "Disponibles" sea la pestaña por defecto.
  int _selectedTab = 1;

  // Instancia del usuario actualmente autenticado. Es nulo si no hay usuario logueado.
  final User? currentUser = FirebaseAuth.instance.currentUser;

  /// Construye la interfaz de usuario de la página del dashboard.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Permite que el cuerpo del Scaffold se extienda detrás de la AppBar.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Dashboard Empleador"), // Título de la AppBar.
        backgroundColor: const Color(
          0xFF2C72B5,
        ), // Color semi-transparente para la AppBar.
        foregroundColor: Colors.white, // Color del texto y íconos de la AppBar.
        elevation: 0, // Sin sombra para la AppBar.
        actions: [
          // Menú desplegable para acciones de usuario (Perfil, Cerrar Sesión).
          PopupMenuButton<String>(
            onSelected: (value) {
              // Navega a la acción seleccionada.
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
                    // Muestra la primera letra del email del usuario o 'U' si no hay email.
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
          Image.asset(
            'assets/fondoazul.png',
            fit: BoxFit.cover,
          ), // Imagen de fondo.
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Elimina el Container de pestañas aquí
                // const SizedBox(height: 16), // Elimina este también
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
      // Botón flotante para crear un nuevo trabajo.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navega a la página para crear un nuevo trabajo.
          Navigator.pushNamed(context, '/createjob_page');
        },
        label: const Text('Crear trabajo'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat, // Centra el botón flotante.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        selectedItemColor: const Color(0xFF2C72B5),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Activos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Disponibles'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            label: 'Aplicaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
      ),
    );
  }

  /// Retorna el widget correspondiente al contenido de la pestaña seleccionada.
  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildActivosTab(); // Pestaña "Activos".
      case 1:
        return _buildDisponiblesTab(); // Pestaña "Disponibles".
      case 2:
        return _buildAplicacionesTab(); // Pestaña "Aplicaciones".
      case 3:
        return _buildHistorialTab(); // Pestaña "Historial".
      default:
        return const SizedBox.shrink(); // Widget vacío por defecto.
    }
  }

  /// Construye la pestaña "Activos".
  /// Muestra los trabajos creados por el empleador con estado 'activo'.
  Widget _buildActivosTab() {
    // Si no hay un usuario autenticado, muestra un mensaje.
    if (currentUser == null) {
      return const Center(child: Text("No estás autenticado"));
    }

    // Utiliza StreamBuilder para escuchar cambios en tiempo real en los trabajos.
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('trabajos')
              .where(
                'autorId',
                isEqualTo: currentUser!.uid,
              ) // Filtra por el ID del empleador actual.
              .where(
                'estado',
                isEqualTo: 'activo',
              ) // Filtra trabajos con estado 'activo'.
              .snapshots(),
      builder: (context, snapshot) {
        // Manejo de errores del Stream.
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        // Muestra un indicador de carga mientras se esperan los datos.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final trabajos =
            snapshot.data!.docs; // Lista de documentos de trabajos activos.

        // Si no hay trabajos activos, muestra un mensaje informativo.
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
                    Icons.pending_actions,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No tienes trabajos activos en este momento.",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Los trabajos aceptados por empleados aparecerán aquí.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Permite "tirar para refrescar" la lista.
        return RefreshIndicator(
          onRefresh: () async {
            setState(
              () {},
            ); // Fuerza una reconstrucción para refrescar los datos.
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trabajos.length,
            itemBuilder: (context, index) {
              final trabajo = trabajos[index];
              final data = trabajo.data() as Map<String, dynamic>;

              // Muestra la tarjeta de cada trabajo activo.
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
                      Icons.check_circle_outline,
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
                            color: Colors.orange[800],
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
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Empleado: ${data['empleadoNombre'] ?? 'Pendiente'}', // Muestra el nombre del empleado asignado.
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
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          Colors.green, // Siempre verde para trabajos activos.
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ACTIVO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Al tocar la tarjeta, muestra los detalles del trabajo activo.
                  onTap: () => _mostrarDetallesTrabajo(data, trabajo.id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Construye la pestaña "Disponibles".
  /// Muestra los trabajos creados por el empleador con estado 'disponible'.
  Widget _buildDisponiblesTab() {
    // Si no hay un usuario autenticado, muestra un mensaje.
    if (currentUser == null) {
      return const Center(child: Text("No estás autenticado"));
    }

    // Utiliza StreamBuilder para escuchar cambios en tiempo real en los trabajos.
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('trabajos')
              .where(
                'autorId',
                isEqualTo: currentUser!.uid,
              ) // Filtra por el ID del empleador actual.
              .where(
                'estado',
                isEqualTo: 'disponible',
              ) // Filtra trabajos con estado 'disponible'.
              .snapshots(),
      builder: (context, snapshot) {
        // Manejo de errores del Stream.
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        // Muestra un indicador de carga mientras se esperan los datos.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final trabajos =
            snapshot.data!.docs; // Lista de documentos de trabajos disponibles.

        // Si no hay trabajos disponibles, muestra un mensaje informativo.
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
                    Icons.info_outline,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No tienes trabajos disponibles actualmente.",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Crea un nuevo trabajo para que aparezca aquí.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Ordena los trabajos manualmente por fecha (más recientes primero).
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

        // Permite "tirar para refrescar" la lista.
        return RefreshIndicator(
          onRefresh: () async {
            setState(
              () {},
            ); // Fuerza una reconstrucción para refrescar los datos.
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trabajos.length,
            itemBuilder: (context, index) {
              final trabajo = trabajos[index];
              final data = trabajo.data() as Map<String, dynamic>;

              // Utiliza StreamBuilder para contar las aplicaciones pendientes para cada trabajo.
              return StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('aplicaciones')
                        .where('trabajoId', isEqualTo: trabajo.id)
                        .where('estado', isEqualTo: 'pendiente')
                        .snapshots(),
                builder: (context, appSnapshot) {
                  // Muestra un indicador de carga si los datos de aplicaciones aún no están disponibles.
                  if (!appSnapshot.hasData) {
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

                  final pendientesCount =
                      appSnapshot
                          .data!
                          .docs
                          .length; // Número de aplicaciones pendientes.

                  // Muestra la tarjeta de cada trabajo disponible.
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
                          const SizedBox(height: 8),
                          // Muestra el número de aplicaciones pendientes si es mayor que 0.
                          if (pendientesCount > 0)
                            Text(
                              'Aplicaciones pendientes: $pendientesCount',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
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
                              Colors
                                  .blue, // Siempre azul para trabajos disponibles.
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'DISPONIBLE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Al tocar la tarjeta, muestra los detalles del trabajo disponible.
                      onTap: () => _mostrarDetallesTrabajo(data, trabajo.id),
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

  /// Construye la pestaña "Aplicaciones".
  /// Muestra todas las aplicaciones recibidas para los trabajos del empleador.
  Widget _buildAplicacionesTab() {
    // Si no hay un usuario autenticado, muestra un mensaje.
    if (currentUser == null) {
      return const Center(child: Text("No estás autenticado"));
    }

    // Utiliza StreamBuilder para escuchar cambios en tiempo real en las aplicaciones.
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('aplicaciones')
              .where(
                'empleadorId',
                isEqualTo: currentUser!.uid,
              ) // Filtra por el ID del empleador actual.
              .snapshots(),
      builder: (context, snapshot) {
        // Manejo de errores del Stream.
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        // Muestra un indicador de carga mientras se esperan los datos.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final aplicaciones =
            snapshot
                .data!
                .docs; // Lista de documentos de aplicaciones recibidas.

        // Si no hay aplicaciones, muestra un mensaje informativo.
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
                  child: Icon(Icons.inbox, size: 60, color: Colors.grey[400]),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No has recibido aplicaciones aún.",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Publica trabajos para empezar a recibir solicitudes.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Ordena las aplicaciones manualmente por fecha (más recientes primero).
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

        // Permite "tirar para refrescar" la lista.
        return RefreshIndicator(
          onRefresh: () async {
            setState(
              () {},
            ); // Fuerza una reconstrucción para refrescar los datos.
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: aplicaciones.length,
            itemBuilder: (context, index) {
              final aplicacionDoc = aplicaciones[index];
              final aplicacion = aplicacionDoc.data() as Map<String, dynamic>;

              Color estadoColor;
              IconData estadoIcon;
              // Determina el color y el ícono según el estado de la aplicación.
              switch (aplicacion['estado']) {
                case 'aceptada':
                  estadoColor = Colors.green;
                  estadoIcon = Icons.check_circle;
                  break;
                case 'rechazada':
                  estadoColor = Colors.red;
                  estadoIcon = Icons.cancel;
                  break;
                default: // 'pendiente' o cualquier otro estado.
                  estadoColor = Colors.orange;
                  estadoIcon = Icons.pending;
              }

              // Muestra la tarjeta de cada aplicación.
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
                    aplicacion['trabajoTitulo'] ?? 'Sin título de trabajo',
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
                        'Aplicante: ${aplicacion['empleadoNombre'] ?? 'Desconocido'}',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Email: ${aplicacion['empleadoEmail'] ?? 'No disponible'}',
                      ),
                      if (aplicacion['fecha'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Fecha de aplicación: ${_formatearFecha(aplicacion['fecha'] as Timestamp)}',
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
                  // Al tocar la tarjeta, muestra los detalles de la aplicación y el trabajo.
                  onTap:
                      () => _mostrarDetallesAplicacion(
                        aplicacion,
                        aplicacionDoc
                            .id, // Pasa el ID del documento de la aplicación.
                      ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Construye la pestaña "Historial".
  /// Muestra los trabajos creados por el empleador con estado 'finalizado'.
  Widget _buildHistorialTab() {
    // Si no hay un usuario autenticado, muestra un mensaje.
    if (currentUser == null) {
      return const Center(child: Text("No estás autenticado"));
    }

    // Utiliza StreamBuilder para escuchar cambios en tiempo real en los trabajos.
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('trabajos')
              .where(
                'autorId',
                isEqualTo: currentUser!.uid,
              ) // Filtra por el ID del empleador actual.
              .where(
                'estado',
                isEqualTo: 'finalizado',
              ) // Filtra trabajos con estado 'finalizado'.
              .snapshots(),
      builder: (context, snapshot) {
        // Manejo de errores del Stream.
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        // Muestra un indicador de carga mientras se esperan los datos.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final trabajos =
            snapshot.data!.docs; // Lista de documentos de trabajos finalizados.

        // Si no hay trabajos en el historial, muestra un mensaje informativo.
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
                  child: Icon(Icons.history, size: 60, color: Colors.grey[400]),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No tienes historial de trabajos finalizados.",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Los trabajos completados aparecerán aquí.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Permite "tirar para refrescar" la lista.
        return RefreshIndicator(
          onRefresh: () async {
            setState(
              () {},
            ); // Fuerza una reconstrucción para refrescar los datos.
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trabajos.length,
            itemBuilder: (context, index) {
              final trabajo = trabajos[index];
              final data = trabajo.data() as Map<String, dynamic>;

              // Muestra la tarjeta de cada trabajo finalizado.
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
                      color:
                          Colors.grey, // Color gris para trabajos finalizados.
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.archive,
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
                            color: Colors.orange[800],
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
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Empleado: ${data['empleadoNombre'] ?? 'No asignado'}',
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
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          Colors
                              .grey, // Siempre gris para trabajos finalizados.
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'FINALIZADO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Al tocar la tarjeta, muestra los detalles del trabajo finalizado.
                  onTap: () => _mostrarDetallesTrabajo(data, trabajo.id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Muestra un diálogo con los detalles de un trabajo.
  /// Incluye un botón para eliminar el trabajo si es "disponible".
  /// Permite finalizar un trabajo si es "activo".
  void _mostrarDetallesTrabajo(Map<String, dynamic> trabajo, String trabajoId) {
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
                    'Profesión: ${trabajo['profesion'] ?? 'No especificada'}',
                  ),
                  const SizedBox(height: 8),
                  Text('Autor: ${trabajo['autorNombre'] ?? 'Desconocido'}'),
                  const SizedBox(height: 8),
                  Text(
                    'Estado: ${trabajo['estado']?.toString().toUpperCase() ?? ''}',
                  ),
                  if (trabajo['empleadoNombre'] != null &&
                      trabajo['estado'] == 'activo') ...[
                    const SizedBox(height: 8),
                    Text('Empleado asignado: ${trabajo['empleadoNombre']}'),
                    const SizedBox(height: 8),
                    Text('Email Empleado: ${trabajo['empleadoEmail']}'),
                  ],
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
                onPressed: () => Navigator.pop(context), // Cierra el diálogo.
                child: const Text('Cerrar'),
              ),
              // Botón para eliminar el trabajo, visible solo si el trabajo está "disponible".
              if (trabajo['estado'] == 'disponible')
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    ); // Cierra el diálogo antes de eliminar.
                    _eliminarTrabajo(
                      trabajoId,
                    ); // Llama a la función para eliminar el trabajo.
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Eliminar Trabajo'),
                ),
              // Botón para finalizar el trabajo, visible solo si el trabajo está "activo".
              if (trabajo['estado'] == 'activo')
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    ); // Cierra el diálogo antes de finalizar.
                    _finalizarTrabajo(
                      trabajoId,
                    ); // Llama a la función para finalizar el trabajo.
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Finalizar Trabajo'),
                ),
            ],
          ),
    );
  }

  /// Muestra un diálogo con los detalles de una aplicación recibida.
  /// Permite al empleador aceptar o rechazar la aplicación si está 'pendiente'.
  void _mostrarDetallesAplicacion(
    Map<String, dynamic> aplicacion,
    String aplicacionId,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Aplicación para: ${aplicacion['trabajoTitulo'] ?? 'Sin título'}',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aplicante: ${aplicacion['empleadoNombre'] ?? 'Desconocido'}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: ${aplicacion['empleadoEmail'] ?? 'No disponible'}',
                  ),
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
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Detalles del Trabajo (referencia):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // FutureBuilder para obtener los detalles del trabajo asociado a la aplicación.
                  FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('trabajos')
                            .doc(aplicacion['trabajoId'])
                            .get(),
                    builder: (context, trabajoSnapshot) {
                      if (trabajoSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (trabajoSnapshot.hasError) {
                        return Text(
                          'Error al cargar trabajo: ${trabajoSnapshot.error}',
                        );
                      }
                      if (!trabajoSnapshot.hasData ||
                          !trabajoSnapshot.data!.exists) {
                        return const Text(
                          'Trabajo asociado no encontrado o eliminado.',
                        );
                      }

                      final trabajoData =
                          trabajoSnapshot.data!.data() as Map<String, dynamic>;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Título del trabajo: ${trabajoData['titulo'] ?? 'N/A'}',
                          ),
                          Text(
                            'Profesión: ${trabajoData['profesion'] ?? 'N/A'}',
                          ),
                          Text(
                            'Estado del trabajo: ${trabajoData['estado'] ?? 'N/A'}',
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Cierra el diálogo.
                child: const Text('Cerrar'),
              ),
              // Muestra botones de acción solo si la aplicación está 'pendiente'.
              if (aplicacion['estado'] == 'pendiente') ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    ); // Cierra el diálogo antes de rechazar.
                    _rechazarAplicacion(
                      aplicacionId,
                      aplicacion['trabajoId'],
                    ); // Llama a la función para rechazar.
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Rechazar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    ); // Cierra el diálogo antes de aceptar.
                    _aceptarAplicacion(
                      aplicacionId,
                      aplicacion,
                    ); // Llama a la función para aceptar.
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Aceptar'),
                ),
              ],
            ],
          ),
    );
  }

  /// Función para eliminar un trabajo.
  /// Muestra un diálogo de confirmación y luego elimina el trabajo de Firestore.
  Future<void> _eliminarTrabajo(String trabajoId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Confirmar Eliminación'),
            content: const Text(
              '¿Estás seguro de que quieres eliminar este trabajo? Todas las aplicaciones asociadas también se eliminarán.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // Cancelar.
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true), // Confirmar.
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      try {
        // Elimina el trabajo de la colección 'trabajos'.
        await FirebaseFirestore.instance
            .collection('trabajos')
            .doc(trabajoId)
            .delete();

        // Elimina todas las aplicaciones asociadas a este trabajo.
        final aplicacionesSnapshot =
            await FirebaseFirestore.instance
                .collection('aplicaciones')
                .where('trabajoId', isEqualTo: trabajoId)
                .get();

        for (final doc in aplicacionesSnapshot.docs) {
          await doc.reference.delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Trabajo eliminado exitosamente."),
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
            content: Text("Error al eliminar trabajo: $e"),
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

  /// Función para finalizar un trabajo.
  /// Cambia el estado del trabajo a 'finalizado' y las aplicaciones a 'finalizada'.
  Future<void> _finalizarTrabajo(String trabajoId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Confirmar Finalización'),
            content: const Text(
              '¿Estás seguro de que quieres marcar este trabajo como finalizado?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // Cancelar.
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true), // Confirmar.
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Finalizar'),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      try {
        // Actualiza el estado del trabajo a 'finalizado'.
        await FirebaseFirestore.instance
            .collection('trabajos')
            .doc(trabajoId)
            .update({'estado': 'finalizado'});

        // Actualiza todas las aplicaciones asociadas a este trabajo a 'finalizada'.
        final aplicacionesSnapshot =
            await FirebaseFirestore.instance
                .collection('aplicaciones')
                .where('trabajoId', isEqualTo: trabajoId)
                .get();

        for (final doc in aplicacionesSnapshot.docs) {
          await doc.reference.update({'estado': 'finalizada'});
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Trabajo marcado como finalizado."),
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
  }

  /// Acepta una aplicación para un trabajo.
  /// Cambia el estado de la aplicación a 'aceptada', el trabajo a 'activo',
  /// y rechaza las demás aplicaciones pendientes para el mismo trabajo.
  Future<void> _aceptarAplicacion(
    String aplicacionId,
    Map<String, dynamic> aplicacion,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Confirmar Aceptación'),
            content: const Text(
              '¿Estás seguro de que quieres aceptar esta aplicación? El trabajo se marcará como activo y se rechazarán otras aplicaciones pendientes para este trabajo.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // Cancelar.
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true), // Confirmar.
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

    if (confirmar == true) {
      try {
        // Actualiza la aplicación seleccionada a 'aceptada'.
        await FirebaseFirestore.instance
            .collection('aplicaciones')
            .doc(aplicacionId)
            .update({'estado': 'aceptada'});

        // Actualiza el trabajo a 'activo' y asigna el empleado.
        await FirebaseFirestore.instance
            .collection('trabajos')
            .doc(aplicacion['trabajoId'])
            .update({
              'estado': 'activo',
              'empleadoId': aplicacion['empleadoId'],
              'empleadoNombre': aplicacion['empleadoNombre'],
              'empleadoEmail': aplicacion['empleadoEmail'],
            });

        // Rechaza otras aplicaciones pendientes para el mismo trabajo.
        final otrasAplicaciones =
            await FirebaseFirestore.instance
                .collection('aplicaciones')
                .where('trabajoId', isEqualTo: aplicacion['trabajoId'])
                .where('estado', isEqualTo: 'pendiente')
                .get();

        for (final doc in otrasAplicaciones.docs) {
          if (doc.id != aplicacionId) {
            await doc.reference.update({'estado': 'rechazada'});
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Aplicación aceptada y trabajo activado."),
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
  }

  /// Rechaza una aplicación.
  /// Cambia el estado de la aplicación a 'rechazada'.
  Future<void> _rechazarAplicacion(
    String aplicacionId,
    String trabajoId,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Confirmar Rechazo'),
            content: const Text(
              '¿Estás seguro de que quieres rechazar esta aplicación?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // Cancelar.
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true), // Confirmar.
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

    if (confirmar == true) {
      try {
        await FirebaseFirestore.instance
            .collection('aplicaciones')
            .doc(aplicacionId)
            .update({'estado': 'rechazada'});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Aplicación rechazada."),
            backgroundColor: Colors.orange,
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
  }

  /// Muestra un diálogo con la información del perfil del usuario actual.
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
                const Text('Rol: Empleador'), // Rol fijo para este dashboard.
                const SizedBox(height: 8),
                Text('ID: ${currentUser?.uid ?? 'No disponible'}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Cierra el diálogo.
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  /// Cierra la sesión del usuario actual y navega a la pantalla de inicio.
  Future<void> _cerrarSesion() async {
    // Muestra un diálogo de confirmación antes de cerrar sesión.
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
                onPressed: () => Navigator.pop(context, false), // Cancelar.
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true), // Confirmar.
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

    // Si el usuario confirma, procede a cerrar sesión.
    if (confirmar == true) {
      try {
        await FirebaseAuth.instance.signOut(); // Cierra la sesión de Firebase.
        Navigator.pushReplacementNamed(context, '/'); // Navega a la ruta raíz.
      } catch (e) {
        // Muestra un SnackBar con el error si el cierre de sesión falla.
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

  /// Formatea un objeto Timestamp de Firestore a una cadena de fecha y hora legible.
  /// Ejemplo: "18/06/2025 19:38"
  String _formatearFecha(Timestamp timestamp) {
    final fecha =
        timestamp.toDate(); // Convierte el Timestamp a un objeto DateTime.
    // Formatea la fecha y hora.
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}
