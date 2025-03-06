import 'package:flutter/material.dart';
import 'package:onpoint/pages/LoginScreen.dart';
import 'package:onpoint/pages/HomeScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      //listen to auth state changes
      stream: Supabase.instance.client.auth.onAuthStateChange,

      // build apropiate widget based on auth state
      builder: (context, snapshot) {
        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        //valid session currenttly
        final session = snapshot.hasData ? snapshot.data!.session : null;
        if (session != null) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
