import 'dart:io';

import 'package:flutter/material.dart';
import 'package:onpoint/auth_service/AuthService.dart';
import 'package:onpoint/pages/RegisterScreen.dart';
import 'package:onpoint/widgets/CustomButton.dart'; // Add this line to import CustomButton
import 'package:onpoint/widgets/ErrorDialog.dart'; // Add this line to import CustomButton

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

    if(email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(errorMessage: "Por favor, complete todos los campos."),
      );
      return;
    }

    try {
      await authservice.signInWithEmailPassword(email, password);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(errorMessage: "Verifique su correo y contraseña."),
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
            "Inicio de Sesión",
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
              controller: emailController,
              decoration: InputDecoration(labelText: "Correo Electrónico"),
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            //password field
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Contraseña"),
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 30),

            //login button
            PrimaryButton(text: "Ingresar", onPressed: login),

            const SizedBox(height: 10),

            // Sign up button
            PrimaryButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  ),
              text: "Registrarme",
            ),
            // Sign up button
          ],
        ),
      ),
    );
  }
}
