import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/home_screen.dart';
void main() async {
  // Aseguramos lol que los plugins (como secure_storage) se inicien bien
  WidgetsFlutterBinding.ensureInitialized();

  // Revisamos si existe el token antes de dibujar la primera pantalla
  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'jwt_token');

  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
return MaterialApp(
      title: 'App Comedor',
      debugShowCheckedModeBanner: false,
      
      // 1. TEMA CLARO (El que ya tenías)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light, // Le decimos que este es el claro
        ),
        useMaterial3: true,
      ),

      // 2. TEMA OSCURO (La magia sucede aquí)
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 43, 223, 255),
          brightness: Brightness.dark, // ¡Le decimos que genere colores oscuros!
        ),
        useMaterial3: true,
      ),

      // 3. EL INTERRUPTOR (¿Cuál usar?)
      themeMode: ThemeMode.dark, // <--- Esto fuerza a que TODA la app sea oscura
      
      // EL GUARDIA DE SEGURIDAD
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}