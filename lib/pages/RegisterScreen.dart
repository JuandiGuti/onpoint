import 'package:flutter/material.dart';
import 'package:onpoint/auth_service/AuthService.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // get auth servise
  final authservice = AuthService();

  //text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repasswordController = TextEditingController();

  // Login function
  void register() async {
    final email = emailController.text;
    final password = passwordController.text;
    final repassword = repasswordController.text;

    if (password != repassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Las contraseñas no coinciden.")),
      );
      return;
    }

    try {
      await authservice.signUpWithEmailPassword(email, password);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Usuario registrado correctamente. Confirma tu correo. E iniciá sesión.",
          ),
        ),
      );

      Navigator.of(context).pop();
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
      appBar: AppBar(title: const Text("Registrarme")),
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

            //repassword field
            TextField(
              controller: repasswordController,
              decoration: const InputDecoration(
                labelText: "Repetir Contraseña",
              ),
            ),

            const SizedBox(height: 20),

            //login button
            ElevatedButton(
              onPressed: register,
              child: const Text("Registrarme"),
            ),
          ],
        ),
      ),
    );
  }
}
