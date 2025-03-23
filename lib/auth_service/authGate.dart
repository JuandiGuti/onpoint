import 'package:flutter/material.dart';
import 'package:onpoint/pages/LoginScreen.dart';
import 'package:onpoint/pages/HomeScreen.dart';
import 'package:onpoint/pages/AdminScreen.dart'; // Importar AdminScreen
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Escuchar cambios de sesión
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Mientras carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Obtener sesión actual
        final session = snapshot.hasData ? snapshot.data!.session : null;
        final email = session?.user?.email ?? "";

        if (session != null) {
          // Si el usuario es el administrador
          if (email == "byron.albizures@hpc.com.gt") {
            return const AdminScreen();
          } else {
            return const HomeScreen();
          }
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
