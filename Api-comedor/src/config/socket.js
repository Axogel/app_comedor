import { Server } from 'socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import { redisConnection } from './redis.js';
import { pool } from './db.js';

let io;

export const initSocket = (httpServer) => {
  io = new Server(httpServer, {
    transports: ['websocket'],

    cors: {
      origin: "*",
      methods: ["GET", "POST"]
    }
  });

  const pubClient = redisConnection;
  const subClient = redisConnection.duplicate();

  io.adapter(createAdapter(pubClient, subClient));

  io.on('connection', async (socket) => {
    console.log(`🟢 Nuevo cliente conectado: ${socket.id}`);

    try {
      // Send active users count
      const currentActive = await redisConnection.get('active_users_count') || 0;
      socket.emit('queue_status', { activeUsers: parseInt(currentActive) });

      // Send the currently active turn (the last one called or being attended)
      const [rows] = await pool.query(
        "SELECT turn_number FROM orders WHERE status = 'called' OR status = 'attended' ORDER BY id DESC LIMIT 1"
      );

      if (rows.length > 0) {
        socket.emit('current_turn', {
          turnNumber: rows[0].turn_number,
          message: `El turno actual es ${rows[0].turn_number}`
        });
      }
    } catch (error) {
      console.error('Error al enviar estado inicial al socket:', error);
    }
  });

  return io;
};

export const getIO = () => {
  if (!io) throw new Error("Socket.io no ha sido inicializado!");
  return io;
};