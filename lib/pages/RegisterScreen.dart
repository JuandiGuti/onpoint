import 'package:flutter/material.dart';
import 'package:onpoint/auth_service/AuthService.dart';
import 'package:onpoint/widgets/CustomButton.dart';
import 'package:onpoint/widgets/ErrorDialog.dart';

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

    if (email.isEmpty || password.isEmpty || repassword.isEmpty) {
      showDialog(
        context: context,
        builder:
            (context) =>
                ErrorDialog(errorMessage: "Todos los campos son requeridos."),
      );
      return;
    }

    if (password != repassword) {
      showDialog(
        context: context,
        builder:
            (context) =>
                ErrorDialog(errorMessage: "Las contraseñas no coinciden."),
      );
      return;
    }
    if (email.contains("@hpc.com.gt") == false) {
      showDialog(
        context: context,
        builder:
            (context) => ErrorDialog(
              errorMessage:
                  "Por favor, ingrese un correo válido dentro de la empresa.",
            ),
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
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      showDialog(
        context: context,
        builder:
            (context) => ErrorDialog(
              errorMessage: "Error al registrar usuario. Intente más tarde.",
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            "Registrarme",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(40),
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),

            //logo
            Center(
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Bordes redondeados
                  child: Image.asset(
                    'assets/images/logo.png', // Nueva ruta correcta
                  ),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.30),

            //email field
            TextField(
              style: Theme.of(context).textTheme.bodyMedium,
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

            //register button
            PrimaryButton(text: "Registrarme", onPressed: register),
          ],
        ),
      ),
    );
  }
}
