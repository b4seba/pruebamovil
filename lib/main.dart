import 'package:flutter/material.dart';
import 'package:pruebamovil/screens/new_page.dart';
import 'package:pruebamovil/screens/login_page.dart';
import 'package:pruebamovil/screens/register_page.dart';
import 'package:pruebamovil/screens/profile_page.dart';
import 'package:pruebamovil/screens/createjob_page.dart';
import 'package:pruebamovil/screens/register_empleado.dart';
import 'package:pruebamovil/screens/dashboard.dart';
import 'package:pruebamovil/screens/dashboardempleado.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        '/': (context) => const NewPage(),
        '/login_page': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/register_empleado': (context) => const RegisterEmpleadoPage(),
        '/dashboard': (context) => const DashboardEmpleadorPage(),
        '/dashboardempleado':(context) => const DashboardEmpleadoPage(), 
        '/profile': (context) => const ProfilePage(),
        '/createjob_page': (context) => const CreateJobPage(),
      },

      // …
    );
  }
}
