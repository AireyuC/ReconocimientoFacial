import 'package:flutter/material.dart'; // <--- Corregido 'importar' por 'import'
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _matriculaController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final _storage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    // Al iniciar, intentamos entrar directo si ya hay datos guardados
    _intentarLoginBiometricoAutomatico();
  }

  // FUNCIÓN 1: LOGIN BIOMÉTRICO (Al abrir la app)
  Future<void> _intentarLoginBiometricoAutomatico() async {
    // 1. Verificar si hay datos guardados previamente
    String? matricula = await _storage.read(key: 'matricula');
    String? password = await _storage.read(key: 'password');

    // Si no hay datos, paramos aquí (el usuario debe escribir manualmente)
    if (matricula == null || password == null) return;

    // 2. Verificar si el hardware soporta biometría
    bool puedeBiometria = await _auth.canCheckBiometrics;
    if (!puedeBiometria) return;

    try {
      // 3. PEDIR ROSTRO / HUELLA
      bool autenticado = await _auth.authenticate(
        localizedReason: 'Mirá la cámara o usa tu huella',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      // 4. Si el rostro es correcto, llenamos los campos y entramos
      if (autenticado) {
        _matriculaController.text = matricula;
        _passwordController.text = password;
        
        // Llamamos al login pasando 'true' para indicar que fue automático
        _realizarLoginAlServidor(esBiometrico: true);
      }
    } catch (e) {
      print("Error biométrico: $e");
    }
  }

  // ------------------------------------------------------------------
  // FUNCIÓN 2: PREGUNTAR AL USUARIO 
  Future<void> _preguntarSiQuiereGuardarDatos() async {
    bool puede = await _auth.canCheckBiometrics;
    if (!puede) return; 

    if (!mounted) return;
    
    bool? acepta = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Activar Acceso Rápido"),
        content: Text("¿Quieres vincular tu huella/rostro a la cuenta ${_matriculaController.text}?"), // Muestra la matrícula
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Dijo NO
            child: const Text("No, usar contraseña"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // Dijo SI
            child: const Text("Sí, activar"),
          ),
        ],
      ),
    );

    if (acepta == true) {
      // Dijo SI: Guardamos/Sobreescribimos los datos nuevos
      await _storage.write(key: 'matricula', value: _matriculaController.text);
      await _storage.write(key: 'password', value: _passwordController.text);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Biometría Activada para este usuario!"), backgroundColor: Colors.green),
      );
    } else {
      // Dijo NO: Borramos cualquier dato viejo para evitar confusiones
      // Así la próxima vez no intentará entrar con la cuenta anterior.
      await _storage.deleteAll();
    }
  }

  // ------------------------------------------------------------------
  // FUNCIÓN 3: LOGIN AL SERVIDOR 
  Future<void> _realizarLoginAlServidor({bool esBiometrico = false}) async {
    setState(() { _cargando = true; });

    final authService = AuthService();
    
    // Login contra Django
    String? error = await authService.login(
      _matriculaController.text, 
      _passwordController.text
    );

    if (!mounted) return;
    setState(() { _cargando = false; });

    if (error == null) {
      // --- ÉXITO ---
      
      // Si entramos MANUALMENTE, verificamos si necesitamos actualizar la biometría
      if (!esBiometrico) {
        // Leemos quién estaba guardado antes
        String? matriculaGuardada = await _storage.read(key: 'matricula');
        
        // PREGUNTAR SI:
        // 1. No hay nadie guardado (matriculaGuardada == null)
        // 2. O El usuario que acaba de entrar es DIFERENTE al guardado
        if (matriculaGuardada != _matriculaController.text) {
           await _preguntarSiQuiereGuardarDatos();
        }
      }

      // Vamos a la pantalla de Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(matricula: _matriculaController.text)),
      );
    } else {
      // --- ERROR ---
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error"), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_scanner, size: 80, color: Colors.indigo),
              const SizedBox(height: 20),
              Text('Sistema de Asistencia', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo[900])),
              const SizedBox(height: 40),

              if (_cargando)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("Verificando identidad en servidor..."),
                  ],
                )
              else 
                Column(
                  children: [
                    TextField(
                      controller: _matriculaController,
                      decoration: const InputDecoration(labelText: 'Matrícula', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 30),
                    
                    // Botón Manual
                    ElevatedButton(
                      onPressed: () => _realizarLoginAlServidor(esBiometrico: false),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.indigo),
                      child: const Text('INGRESAR MANUALMENTE', style: TextStyle(color: Colors.white)),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Botón Reintentar Biometría
                    TextButton.icon(
                      onPressed: _intentarLoginBiometricoAutomatico,
                      icon: const Icon(Icons.face),
                      label: const Text("Reintentar Biometría"),
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}