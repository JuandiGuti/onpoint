import 'package:flutter/material.dart';
import 'package:onpoint/auth_service/AuthService.dart';
import 'package:onpoint/pages/RegisterScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // get auth servise
  final authservice = AuthService();

  //text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Login function
  void login() async {
    final email = emailController.text;
    final password = passwordController.text;

    try {
      await authservice.signInWithEmailPassword(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inicio de Sesión")),
      body: Container(
        padding: const EdgeInsets.all(40),
        child: ListView(
          children: [
            //email field
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Correo Electronico",
              ),
            ),

            //password field
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Contraseña"),
            ),

            const SizedBox(height: 20),

            //el boton no tiene el equema de colores
            //login button
            ElevatedButton(
              onPressed: login,
              child: const Text("Iniciar Sesión"),
            ),

            const SizedBox(height: 20),

            // Sign up button
            Center(
              child: GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    ),
                child: const Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Color.fromARGB(255, 0, 140, 255),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
