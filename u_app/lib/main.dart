import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Importamos tu pantalla nueva

void main() {
  runApp(const UniversityApp());
}

class UniversityApp extends StatelessWidget {
  const UniversityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Quita la etiqueta "Debug"
      title: 'Acceso U',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const LoginScreen(), // <--- Aquí le decimos que inicie en el Login
    );
  }
}