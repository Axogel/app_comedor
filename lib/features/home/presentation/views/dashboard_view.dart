import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // --- Variables de Estado ---
  int _turnoActual = 0;
  int _miTurno = 102; // Aún en duro, lo cambiaremos cuando conectemos la reserva
  int _clientesActivos = 0;
  String _estadoSocket = 'Conectando...';
  String _ultimoMensaje = '';

  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _conectarSocket();
  }

  void _conectarSocket() {
    // 1. Configuramos la conexión (Ajusta la IP a la de tu máquina en la red local)
    socket = IO.io('http://192.168.32.1:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    // 2. Eventos de Conexión
    socket.onConnect((_) {
      if (mounted) {
        setState(() {
          _estadoSocket = '🟢 Conectado';
        });
      }
      print('✅ Conectado a Socket.io desde Flutter');
    });

    socket.onDisconnect((_) {
      if (mounted) {
        setState(() {
          _estadoSocket = '🔴 Desconectado';
        });
      }
      print('❌ Desconectado de Socket.io');
    });

    // --- EVENTOS DEL BACKEND (Basados en tu HTML) ---

    // 3. Escuchar el cambio de turno: 'current_turn'
    socket.on('current_turn', (data) {
      print('📢 current_turn recibido: $data');
      if (mounted) {
        setState(() {
          // data es un Map (JSON). Accedemos a turnNumber y message
          _turnoActual = data['turnNumber'] ?? _turnoActual;
          _ultimoMensaje = data['message'] ?? 'Turno llamado';
        });
      }
    });

    // 4. Escuchar cantidad de clientes: 'queue_status'
    socket.on('queue_status', (data) {
      print('👥 queue_status recibido: $data');
      if (mounted) {
        setState(() {
          _clientesActivos = data['activeUsers'] ?? _clientesActivos;
        });
      }
    });

    // 5. Escuchar si un turno expiró: 'turn_expired'
    socket.on('turn_expired', (data) {
      if (mounted) {
        setState(() {
          _ultimoMensaje = 'Turno ${data['turnNumber']} expirado';
        });
        // Si el turno que expiró es el nuestro, podríamos mostrar una alerta
        if (data['turnNumber'] == _miTurno) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Tu turno ha expirado!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
    
    // 6. Escuchar si están atendiendo: 'turn_attended'
    socket.on('turn_attended', (data) {
       if (mounted) {
        setState(() {
          _ultimoMensaje = 'Atendiendo orden ${data['orderId']}...';
        });
      }
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int turnosFaltantes = _miTurno - _turnoActual;
    if (turnosFaltantes < 0) turnosFaltantes = 0;

    return SingleChildScrollView( // Usamos SingleChildScrollView por si la pantalla es pequeña
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Indicador de estado del Socket (Como en tu HTML)
          Container(
             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
             decoration: BoxDecoration(
               color: Theme.of(context).colorScheme.surfaceVariant,
               borderRadius: BorderRadius.circular(20),
             ),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Icon(Icons.wifi, size: 16),
                 const SizedBox(width: 8),
                 Text('Socket: $_estadoSocket', style: const TextStyle(fontWeight: FontWeight.bold)),
               ],
             ),
          ),
          const SizedBox(height: 20),

          // Fila superior: Saldo y Cola (Inspirado en tu HTML)
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.blue.withOpacity(0.2), // Se adapta mejor al modo oscuro
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: const [
                        Text('Saldo (Tokens)', style: TextStyle(fontSize: 14)),
                        SizedBox(height: 8),
                        Text('150', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Card(
                  color: Colors.orange.withOpacity(0.2),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('En espera', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        Text('$_clientesActivos', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Tarjeta Principal del Contador
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  const Text('TURNO ACTUAL', style: TextStyle(fontSize: 16, letterSpacing: 2)),
                  const SizedBox(height: 10),
                  Text(
                    _turnoActual == 0 ? '--' : '#$_turnoActual', 
                    style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold)
                  ),
                  
                  // Mensaje de estado (lastMessage de tu HTML)
                  if (_ultimoMensaje.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      child: Text(
                        _ultimoMensaje, 
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const Divider(height: 30),
                  
                  Text('Tu turno: #$_miTurno', style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 10),
                  Text(
                    'Faltan $turnosFaltantes turnos', 
                    style: TextStyle(
                      fontSize: 18, 
                      color: turnosFaltantes <= 5 && turnosFaltantes > 0 ? Colors.red : Colors.grey,
                      fontWeight: turnosFaltantes <= 5 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}