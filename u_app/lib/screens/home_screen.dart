import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final String matricula;

  const HomeScreen({super.key, required this.matricula});

  @override
  Widget build(BuildContext context) {
    // Obtenemos la hora actual para mostrarla
    final horaActual = TimeOfDay.now().format(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Círculo verde animado (simple)
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, size: 100, color: Colors.green),
              ),
              SizedBox(height: 40),
              
              Text(
                "ACCESO CONCEDIDO",
                style: GoogleFonts.poppins(
                  fontSize: 26, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.green[800]
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Asistencia Registrada",
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
              ),
              
              SizedBox(height: 40),
              
              // Tarjeta de datos
              Container(
                margin: EdgeInsets.symmetric(horizontal: 40),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200)
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Estudiante:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(matricula),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Hora:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(horaActual, style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 60),
              
              IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                // FORMA CORRECTA: Navegar hacia el Login (crearlo de nuevo)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()), // Asegúrate de importar login_screen.dart
                );
              },
              color: Colors.indigo,)
            ],
          ),
        ),
      ),
    );
  }
}