import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF252147),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E2B5F),
        title: const Text('Perfil', style: TextStyle(color: Colors.white70)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Card(
            color: const Color(0xFF2E2B5F),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 60, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user != null ? user.email! : 'Sin usuario',
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/');
                    },
                    child: const Text(
                      "Cerrar sesión",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
