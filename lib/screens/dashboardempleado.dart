import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Clase principal del Dashboard para empleados.
/// Es un StatefulWidget porque su estado (pestaña seleccionada, profesión del usuario)
/// puede cambiar durante la vida del widget.
class DashboardEmpleadoPage extends StatefulWidget {
  const DashboardEmpleadoPage({super.key});

  @override
  State<DashboardEmpleadoPage> createState() => _DashboardEmpleadoPageState();
}

/// Estado asociado a DashboardEmpleadoPage.
/// Contiene la lógica y los datos mutables del widget.
class _DashboardEmpleadoPageState extends State<DashboardEmpleadoPage> {
  // Índice de la pestaña actualmente seleccionada (0: Mis Trabajos, 1: Disponibles, 2: Historial).
  int _selectedTab = 0;

  // Instancia del usuario actualmente autenticado. Es nulo si no hay usuario logueado.
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Variable para almacenar la profesión del usuario, cargada desde Firestore.
  String? _profesionUsuario;

  // Bandera para indicar si la profesión del usuario aún se está cargando.
  bool _cargandoProfesion = true;

  /// Método que se llama una vez cuando el estado se inserta en el árbol de widgets.
  /// Se utiliza para inicializar datos, como cargar la profesión del usuario.
  @override
  void initState() {
    super.initState();
    _cargarProfesionUsuario();
  }

  /// Carga la profesión del usuario autenticado desde la colección 'usuarios' en Firestore.
  /// Actualiza [_profesionUsuario] y [_cargandoProfesion] una vez que la operación finaliza.
  Future<void> _cargarProfesionUsuario() async {
    // Verifica si hay un usuario autenticado.
    if (currentUser != null) {
      try {
        // Obtiene el documento del usuario de Firestore usando su UID.
        final doc =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(currentUser!.uid)
                .get();

        // Si el documento existe, extrae la profesión y actualiza el estado.
        if (doc.exists) {
          setState(() {
            _profesionUsuario = doc.data()?['profesion'];
            _cargandoProfesion = false; // La carga ha terminado.
          });
        } else {
          // Si el documento no existe, la carga ha terminado sin profesión.
          setState(() {
            _cargandoProfesion = false;
          });
        }
      } catch (e) {
        // En caso de error, imprime el error y marca la carga como finalizada.
        print('Error al cargar profesión: $e');
        setState(() {
          _cargandoProfesion = false;
        });
      }
    } else {
      // Si no hay usuario, la carga ha terminado sin profesión.
      setState(() {
        _cargandoProfesion = false;
      });
    }
  }

  /// Construye la interfaz de usuario de la página del dashboard.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Permite que el cuerpo del Scaffold se extienda detrás de la AppBar.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dashboard Empleado"),
            // Muestra la profesión del usuario si ha sido cargada.
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
        backgroundColor: const Color(0xFF2C72B5),
        foregroundColor: Colors.white, // Color del texto y íconos de la AppBar.
        elevation: 0, // Sin sombra para la AppBar.
        actions: [
          // Menú desplegable para acciones de usuario (Perfil, Cerrar Sesión).
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
      body:
          _cargandoProfesion
              // Muestra un indicador de carga mientras la profesión se está cargando.
              ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/fondoazul.png', fit: BoxFit.cover),
                  const Center(child: CircularProgressIndicator()),
                ],
              )
              // Muestra el contenido principal del dashboard una vez que la profesión ha cargado.
              : Stack(
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
                              child:
                                  _buildTabContent(), // Contenido dinámico de la pestaña.
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
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
            icon: Icon(Icons.assignment_turned_in),
            label: 'Mis Trabajos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'Disponibles',
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
        return _buildMisTrabajosTab(); // Pestaña "Mis Trabajos".
      case 1:
        return _buildTrabajosDisponiblesTab(); // Pestaña "Disponibles".
      case 2:
        return _buildHistorialTab(); // Pestaña "Historial".
      default:
        return const SizedBox.shrink(); // Widget vacío por defecto.
    }
  }

  /// Construye la pestaña "Mis Trabajos".
  /// Muestra los trabajos donde el empleado ha sido aceptado.
  Widget _buildMisTrabajosTab() {
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
                'empleadoId',
                isEqualTo: currentUser!.uid,
              ) // Filtra por el ID del empleado actual.
              .where(
                'estado',
                isEqualTo: 'aceptada',
              ) // Filtra aplicaciones aceptadas.
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
                .docs; // Lista de documentos de aplicaciones aceptadas.

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
              final aplicacion =
                  aplicaciones[index].data() as Map<String, dynamic>;

              // Utiliza FutureBuilder para obtener los detalles del trabajo asociado a cada aplicación.
              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('trabajos')
                        .doc(aplicacion['trabajoId'])
                        .get(),
                builder: (context, trabajoSnapshot) {
                  // Muestra un indicador de carga si los datos del trabajo aún no están disponibles.
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

                  // Si el trabajo no existe (fue eliminado), muestra un mensaje.
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
                      trabajoSnapshot.data!.data()
                          as Map<String, dynamic>; // Datos del trabajo.

                  // Muestra la tarjeta de cada trabajo aceptado.
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
                          // Cambia el color del estado según si el trabajo está activo o finalizado.
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
                      // Al tocar la tarjeta, muestra los detalles del trabajo y la aplicación.
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

  /// Construye la pestaña "Trabajos Disponibles".
  /// Muestra los trabajos con estado 'disponible' y que coinciden con la profesión del usuario.
  Widget _buildTrabajosDisponiblesTab() {
    // Si la profesión del usuario no se pudo cargar, muestra un mensaje de advertencia.
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

    // Utiliza StreamBuilder para escuchar cambios en tiempo real en los trabajos.
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('trabajos')
              .where(
                'estado',
                isEqualTo: 'disponible',
              ) // Filtra trabajos disponibles.
              .where(
                'profesion',
                isEqualTo: _profesionUsuario,
              ) // Filtra por la profesión del usuario.
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

        // Si no hay trabajos disponibles para la profesión del usuario, muestra un mensaje.
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
                  // Muestra el estado de la aplicación o un botón para aplicar.
                  trailing: StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('aplicaciones')
                            .where('trabajoId', isEqualTo: trabajo.id)
                            .where('empleadoId', isEqualTo: currentUser?.uid)
                            .snapshots(),
                    builder: (context, appSnapshot) {
                      // Si ya existe una aplicación para este trabajo por el usuario actual.
                      if (appSnapshot.hasData &&
                          appSnapshot.data!.docs.isNotEmpty) {
                        final aplicacion =
                            appSnapshot.data!.docs.first.data()
                                as Map<String, dynamic>;
                        final estado = aplicacion['estado'] as String;

                        Color color;
                        String texto;
                        // Determina el color y texto del estado de la aplicación.
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

                        // Muestra el estado de la aplicación.
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

                      // Si no hay aplicación existente, muestra el botón "Aplicar".
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ElevatedButton(
                          onPressed:
                              () => _aplicarATrabajo(
                                trabajo.id,
                                data,
                              ), // Llama a la función para aplicar.
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
                  // Al tocar la tarjeta, muestra los detalles del trabajo disponible.
                  onTap:
                      () => _mostrarDetallesTrabajoDisponible(data, trabajo.id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Construye la pestaña "Historial".
  /// Muestra todas las aplicaciones del empleado (pendientes, aceptadas, rechazadas).
  Widget _buildHistorialTab() {
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
                'empleadoId',
                isEqualTo: currentUser!.uid,
              ) // Filtra por el ID del empleado actual.
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
                .docs; // Lista de documentos de todas las aplicaciones.

        // Si no hay aplicaciones en el historial, muestra un mensaje informativo.
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
              final aplicacion =
                  aplicaciones[index].data() as Map<String, dynamic>;

              // Utiliza FutureBuilder para obtener los detalles del trabajo asociado a cada aplicación.
              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('trabajos')
                        .doc(aplicacion['trabajoId'])
                        .get(),
                builder: (context, trabajoSnapshot) {
                  // Muestra un indicador de carga si los datos del trabajo aún no están disponibles.
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
                      trabajoSnapshot.data!.data()
                          as Map<String, dynamic>?; // Datos del trabajo.

                  // Si el trabajo no existe (fue eliminado), muestra un mensaje específico.
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

                  // Muestra la tarjeta de cada aplicación en el historial.
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
                      // Al tocar la tarjeta, muestra los detalles del trabajo y la aplicación.
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

  /// Función para permitir que un empleado aplique a un trabajo.
  /// Muestra una confirmación y luego guarda la aplicación en Firestore.
  Future<void> _aplicarATrabajo(
    String trabajoId,
    Map<String, dynamic> trabajoData,
  ) async {
    // Si no hay un usuario autenticado, muestra un SnackBar.
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No estás autenticado")));
      return;
    }

    try {
      // Verifica si el usuario ya aplicó a este trabajo para evitar duplicados.
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

      // Muestra un diálogo de confirmación antes de aplicar.
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
                  child: const Text('Aplicar'),
                ),
              ],
            ),
      );

      // Si el usuario cancela la aplicación, no hace nada.
      if (confirmar != true) return;

      // Crea un nuevo documento de aplicación en la colección 'aplicaciones'.
      await FirebaseFirestore.instance.collection('aplicaciones').add({
        'trabajoId': trabajoId,
        'empleadoId': currentUser!.uid,
        'empleadoNombre':
            currentUser!.displayName ?? currentUser!.email ?? 'Anónimo',
        'empleadoEmail': currentUser!.email,
        'empleadorId': trabajoData['autorId'],
        'estado':
            'pendiente', // El estado inicial de la aplicación es 'pendiente'.
        'fecha': FieldValue.serverTimestamp(), // Marca de tiempo del servidor.
        'trabajoTitulo':
            trabajoData['titulo'], // Guarda el título del trabajo para referencia fácil.
      });

      // Muestra un SnackBar de éxito.
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
      // Muestra un SnackBar con el error si la aplicación falla.
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

  /// Muestra un diálogo con los detalles de un trabajo y el estado de la aplicación del usuario.
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
                onPressed: () => Navigator.pop(context), // Cierra el diálogo.
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  /// Muestra un diálogo con los detalles de un trabajo disponible.
  /// Incluye un botón para aplicar al trabajo.
  void _mostrarDetallesTrabajoDisponible(
    Map<String, dynamic> trabajo,
    String trabajoId,
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
                onPressed: () => Navigator.pop(context), // Cierra el diálogo.
                child: const Text('Cerrar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el diálogo antes de aplicar.
                  _aplicarATrabajo(
                    trabajoId,
                    trabajo,
                  ); // Llama a la función para aplicar.
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
                Text('Profesión: ${_profesionUsuario ?? 'No especificada'}'),
                const SizedBox(height: 8),
                const Text('Rol: Empleado'), // Rol fijo para este dashboard.
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
