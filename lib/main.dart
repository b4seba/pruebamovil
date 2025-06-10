import 'package:flutter/material.dart';
import 'package:pruebamovil/screens/new_page.dart';
import 'package:pruebamovil/screens/login_page.dart';
import 'package:pruebamovil/screens/register_page.dart';
import 'package:pruebamovil/screens/profile_page.dart';
import 'package:pruebamovil/screens/createjob_page.dart';
import 'package:pruebamovil/screens/register_empleado.dart';
import 'package:pruebamovil/screens/dashboard.dart';


import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main () async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      initialRoute: '/',
      routes: {
        // Acá están todas las rutas. 
        // Esta es como el "main"
        '/': (context) => const NewPage(),
        // Acá el login
        '/login_page': (context) => const LoginPage(),
        // Acá el register
        '/register': (context) => const RegisterPage(),
        // Acá el perfil. Es cuando el usuario va a su cuenta aprentando el icono
        '/profile': (context) => const ProfilePage(),
        // Acá para crear trabajos. Es el botón de crear trabajo del dashboard
        '/createjob_page' : (context) => const CreateJobPage(),
        // Otro registro. EL registro del empleado, sirve para tener en cuenta la profesión
        '/register_empleado' : (context) => const RegisterEmpleadoPage(),
        // Dashboard. Lo que verán luego de logearse
        '/dashboard' : (context) => const DashboardPage()
        

      },
    );
  }
}



