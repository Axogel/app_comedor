import { Queue, Worker } from 'bullmq';
import { pool } from '../config/db.js';
import { redisConnection } from '../config/redis.js';
import { getIO } from '../config/socket.js';

const expirationQueue = new Queue('turn-expiration', { connection: redisConnection });

const KEY_ACTIVE_COUNT = 'active_users_count'; 
const KEY_GLOBAL_SEQUENCE = 'global_sequence'; 
const MAX_CAPACITY = 100; 

const worker = new Worker('turn-expiration', async (job) => {
  const { orderId, turnNumber } = job.data;
  const io = getIO();

  console.log(`🕵️ Revisando expiración Turno #${turnNumber}...`);

  try {
    const [rows] = await pool.query('SELECT status FROM orders WHERE id = ?', [orderId]);

    if (rows.length > 0 && rows[0].status === 'called') {
      console.log(` Turno #${turnNumber} no llego el pana`);

      await pool.query("UPDATE orders SET status = 'expired' WHERE id = ?", [orderId]);
      await redisConnection.decr(KEY_ACTIVE_COUNT);
      
      io.emit('turn_expired', { 
        turnNumber, 
        message: `El turno ${turnNumber} ha expirado. ¡Se abre un cupo!`
      });

      const currentActive = await redisConnection.get(KEY_ACTIVE_COUNT);
      io.emit('queue_status', { activeUsers: currentActive });

    } else {
      console.log(`✅ Turno #${turnNumber} se salvó.`);
    }
  } catch (error) {
    console.error(`Error worker:`, error);
  }
}, { connection: redisConnection });

export const requestTurn = async (userId) => {
  const currentActive = await redisConnection.get(KEY_ACTIVE_COUNT) || 0;
  if (parseInt(currentActive) >= MAX_CAPACITY) {
    return { success: false, message: 'Fila llena.' };
  }

  const turnNumber = await redisConnection.incr(KEY_GLOBAL_SEQUENCE);
  await redisConnection.incr(KEY_ACTIVE_COUNT);

  const [result] = await pool.query(
    "INSERT INTO orders (user_id, turn_number, status) VALUES (?, ?, 'pending')",
    [userId, turnNumber]
  );

  const io = getIO();
  io.emit('queue_status', { activeUsers: parseInt(currentActive) + 1 });

  return { success: true, turn: turnNumber, orderId: result.insertId };
};

export const callTurn = async (orderId) => {
  const [rows] = await pool.query('SELECT turn_number, status FROM orders WHERE id = ?', [orderId]);
  
  if (rows.length === 0 || rows[0].status !== 'pending') {
    return { success: false, message: 'Turno no válido' };
  }

  await pool.query("UPDATE orders SET status = 'called', assigned_at = NOW() WHERE id = ?", [orderId]);

  await expirationQueue.add(
    'check-expiration',
    { orderId, turnNumber: rows[0].turn_number },
    { delay: 10 * 60 * 1000 } 
  );

  const io = getIO();
  io.emit('current_turn', { 
    turnNumber: rows[0].turn_number,
    message: `¡Turno ${rows[0].turn_number}, por favor acérquese!`
  });

  return { success: true, message: `Llamando al turno ${rows[0].turn_number}` };
};

export const attendTurn = async (orderId) => {
  await pool.query("UPDATE orders SET status = 'attended' WHERE id = ?", [orderId]);
  
  const io = getIO();
  io.emit('turn_attended', { orderId });

  return { success: true, message: 'Atendiendo usuario.' };
};

export const completeTurn = async (orderId) => {
  await pool.query("UPDATE orders SET status = 'completed', completed_at = NOW() WHERE id = ?", [orderId]);
  
  await redisConnection.decr(KEY_ACTIVE_COUNT);
  
  const io = getIO();
  const currentActive = await redisConnection.get(KEY_ACTIVE_COUNT);
  io.emit('queue_status', { activeUsers: currentActive });

  return { success: true, message: 'Orden finalizada.' };
};