import 'package:flutter/material.dart';
import 'package:onpoint/auth_service/authGate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // set up supabase client !
  await Supabase.initialize(
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJqZ3VvdmF4eW5ud2l0cGl1YXVtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA4MDcyMzIsImV4cCI6MjA1NjM4MzIzMn0.EkNyLjIGZJgTf9hkCnAqmNWFMODj9wdnTeU7YtCzTxA",
    url: "https://bjguovaxynnwitpiuaum.supabase.co",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnPoint',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthGate(),
    );
  }
}
