import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../auth/presentation/login_screen.dart'; // Ajusta la ruta si es necesario
import 'views/dashboard_view.dart';
import 'views/reservation_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variable para controlar qué pantalla estamos viendo
  int _indiceActual = 0;

  // Lista de las vistas que acabamos de crear
  final List<Widget> _vistas = [
    const DashboardView(),
    const ReservationView(),
  ];

  // Función de Logout (la misma que ya tenías)
  void _logout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt_token');
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comedor Universitario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      // El body cambia dinámicamente según el índice seleccionado
      body: _vistas[_indiceActual],
      
      // La barra de navegación inferior
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceActual,
        onDestinationSelected: (int nuevoIndice) {
          setState(() {
            _indiceActual = nuevoIndice;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Reservar',
          ),
        ],
      ),
    );
  }
}